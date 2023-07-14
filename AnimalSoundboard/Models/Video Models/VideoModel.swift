//
//  VideoModel.swift
//  Meme Soundboard
//
//  Created by Danil Andriuschenko on 22.12.2022.
//  Copyright © 2022 Danil Andriuschenko. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


///Video model representing a model for animated image view
class VideoModel: AnimatedImageViewModel{
    
    private let saveIntoCache = false
    
    /// A variable that indicates if the model is binded with image view
    var isBinded: Bool{
        get{
            return self.animatedImageView != nil
        }
    }
    
    private var isReadingAssetReader: Bool = false
    
    let renderer = UIGraphicsImageRenderer(size:  CGSize(width: 200, height: 200))
    
    ///Returns avassetreader that reads images from mp4 files
    var assetReader: AVAssetReader?
    
    ///Create asset reader and add reader output
    func createAssetReader() -> AVAssetReader?{
        
        if let assetTrack = self.assetVideoTrack, let assetReader = try? AVAssetReader(asset: asset){
            let assetReaderOutputSettings = [
                kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_24RGB)
            ] as [String : Any]
            let assetReaderOutput = AVAssetReaderTrackOutput(track: assetTrack, outputSettings: assetReaderOutputSettings)
            assetReaderOutput.alwaysCopiesSampleData = false
            if assetReader.canAdd(assetReaderOutput){
                assetReader.add(assetReaderOutput)
            }
            else{
                return nil
            }

            return assetReader
        }
        return nil
    }
    
    ///Returns asset object for mp4 file
    lazy var asset: AVAsset = {
        return AVAsset(url: URL(fileURLWithPath: self.animatedFilePath))
    }()
    ///Returns track for an asset
    lazy var assetVideoTrack: AVAssetTrack? = {
        return asset.tracks(withMediaType: .video).first
    }()
    

    var didChangeCurrentTime: ((TimeInterval) -> Void)?
    var numberOfFrames: Int = -1
    
    private var currentProcessedFrameIndex: Int = -1
    private var alreadyFetching = false
    
    ///Start reading asset reader
    func startReadingAssetReaderIfNeeded() throws{
        
        guard let assetReader = assetReader else{
            throw AssetError.noOutput
        }
        
        guard assetReader.status != .reading else {
            throw AssetError.alreadyReading
        }
        
        //Reset current processed frame
        self.currentProcessedFrameIndex = -1
        if assetReader.status != .unknown {
            assetReader.cancelReading()
            
            //Create new assetReader
            self.assetReader = createAssetReader()
            self.assetReader?.startReading()
        }
        else{
            
            assetReader.startReading()
        }
        
        
    }
    
    
    ///Calculate number of frames inside video
    func fetchNumberOfFrames() -> Int{
        
        //Create new asset so that it would not intersect the one that process the frames
        guard let newAsset = createAssetReader(), let assetReaderOutput = newAsset.outputs.first as? AVAssetReaderTrackOutput, isBinded else{
            return numberOfFrames
        }
        
        newAsset.startReading()
        
        var count = 0
        while true{
            guard isBinded else{
                return -1
            }
            
            let sample = assetReaderOutput.copyNextSampleBuffer()
            if sample == nil{
                break
            }
            count += 1
        }
        
        return count
    }
    
    ///Reset reader method that cancels reading asset and resets current frame index
    func resetReader(){
        if assetReader?.status != .unknown{
            assetReader?.cancelReading()
        }
        self.currentProcessedFrameIndex = -1
    }
    
    ///Get all frames and assinging number of frames asynchronously
    func fetchAllSamplesBuffers(completion: @escaping([CMSampleBuffer], Int, Error?) -> Void){
        guard isBinded else{
            return
        }
        
        
        
        dispatchQueue.async {
            
            self.resetReader()
            
            try? self.startReadingAssetReaderIfNeeded()
            
            guard let assetReaderOutput = self.assetReader?.outputs.first as? AVAssetReaderTrackOutput, self.assetReader?.status == .reading else{
                return
            }
            
            var samples: [CMSampleBuffer] = []
            self.currentProcessedFrameIndex = -1
            while true{
                if let sample = assetReaderOutput.copyNextSampleBuffer(){
                    
                    samples.append(sample)
                    self.currentProcessedFrameIndex += 1
                }
                else{
                    break
                }
            }
            
            completion(samples, samples.count, nil)
            
        }
        
    }
    

    
    ///Returns all sample buffers from current processed frame till needed frame index
    func fetchFrames(till frameIndex: Int, completion: @escaping(_ frames: [UIImage],_ from: Int,_ till: Int) -> Void){
        guard isBinded else{
            return
        }
        alreadyFetching = true
        
        dispatchQueue.async {
            if self.currentProcessedFrameIndex > frameIndex{
                self.resetReader()
            }
            try? self.startReadingAssetReaderIfNeeded()
            
        
            guard let _ = self.assetReader?.outputs.first as? AVAssetReaderTrackOutput, self.assetReader?.status == .reading else{
                self.alreadyFetching = false
                return
            }
            var frames: [UIImage] = []
            let from = self.currentProcessedFrameIndex
            guard frameIndex < self.numberOfFrames else{
                self.alreadyFetching = false
                return
            }
            
           
            while self.currentProcessedFrameIndex < frameIndex && self.assetReader?.status == .reading{
                guard let output = self.assetReader?.outputs.first as? AVAssetReaderTrackOutput else{
                    self.alreadyFetching = false
                    return
                }
                
                if self.assetReader == nil || !self.isBinded{
                    self.alreadyFetching = false
                    return
                }
                
                if let sample = output.copyNextSampleBuffer(), let frame = sample.image(){
                
                    
                    frames.append(frame)
                    
                    CMSampleBufferInvalidate(sample)
                    
                    self.currentProcessedFrameIndex += 1
                }
                else{
                    break
                }
            }
            completion(frames, from, frameIndex)
        }
    }
    
    
    
    
    
    ///Get frame from frame number
    override func getFrame(frameNumber: Int, completion: @escaping(UIImage?) -> Void) {
        let object = self.frames.object(forKey: NSNumber(value: frameNumber))
        
        if object == nil{
            
            
            guard self.alreadyFetching == false else{
                return
            }
            
            
            
            fetchFrames(till: frameNumber) {[weak self] frames, from, till in
           
                self?.alreadyFetching = false
                var indexCounter = from
                
                //Save to cache copied buffers if reversed
                if self?.saveIntoCache == true{
                    for i in frames{
                        
                        self?.frames.setObject(i, forKey: NSNumber(value: indexCounter))
                        indexCounter += 1
                    }
                }
                
                
                if let lastFrame = frames.last{
                    let img = autoreleasepool{ () -> UIImage? in
                        let img = self?.renderer.image(actions: { ctx in
                            lastFrame.draw(at: CGPoint.zero)
                        })
                        
                        return img
                    }
                    
                    completion(img)
                }
                
            }
            
          
        }
        else{
            
            if let object = object{
                
                let img = autoreleasepool{ () -> UIImage? in
                    let img = self.renderer.image(actions: { ctx in
                        object.draw(at: CGPoint.zero)
                    })
                    
                    return img
                }
                

                completion(img)
            }
        }
        
    }
    
    ///Return snumber of frames in video
    ///- Warning: Call asynchronously
    override func getNumberOfFrames(completion: @escaping (Int) -> Void) {
        
        if numberOfFrames == -1{
            
            dispatchQueue.async {
                let number = self.fetchNumberOfFrames()
                self.numberOfFrames = number
                completion(number)
            }
            
        }
        else{
            completion(numberOfFrames)
        }
    }
    

    enum AssetError: Error{
        case noOutput
        case alreadyReading
    }
    

    
    override func bindWithImageView(imageView: AnimatedImageView) {
        super.bindWithImageView(imageView: imageView)
        
        
        dispatchQueue.async {
            _ = self.assetVideoTrack
            if self.assetReader == nil{
                self.assetReader = self.createAssetReader()
            }
        }
        DispatchQueue.global(qos: .background).async{
            if self.numberOfFrames < 0{
                self.getNumberOfFrames { [weak self] num in
                    self?.numberOfFrames = num
                }
            }
        }
    
    
    }
    
    


    override func clear() {
        super.clear()
        self.frames.removeAllObjects()
        self.currentProcessedFrameIndex = -1
        dispatchQueue.async {
            if self.assetReader?.status == .reading{
                self.assetReader?.cancelReading()
            }
        }
        
        //assetImageGenerator = nil
    }
    
    
    
    override func unbindImageView() {
        super.unbindImageView()
        
        self.didChangeCurrentTime = nil
    }
}


extension CMSampleBuffer {
    ///Retruns uiimage from sample
    func image(orientation: UIImage.Orientation = .up, scale: CGFloat = 1.0) -> UIImage? {
        if let buffer = CMSampleBufferGetImageBuffer(self) {
            
            let ciImage = CIImage(cvImageBuffer: buffer)

            return UIImage(ciImage: ciImage, scale: scale, orientation: orientation)
        }

        return nil
    }
}

extension CVImageBuffer{
    func image(orientation: UIImage.Orientation = .up, scale: CGFloat = 1.0) -> UIImage?{
        let ciImage = CIImage(cvImageBuffer: self)
        return UIImage(ciImage: ciImage, scale: scale, orientation: orientation)
    }
}

