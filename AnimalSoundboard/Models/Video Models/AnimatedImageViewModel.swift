//
//  ImageViewAnimation.swift
//  Meme Soundboard
//
//  Created by Danil Andriuschenko on 20.12.2022.
//  Copyright © 2022 Danil Andriuschenko. All rights reserved.
//

import Foundation
import UIKit
//Image view animation model that stores block sound, image view reference and paths of image and animated file
class AnimatedImageViewModel{
    enum AnimationType{
        case gif
        case video
    }
    
    var type: AnimationType?
    var frames = NSCache<NSNumber, UIImage>()
    
    //Weak reference to a Block Sound object
    weak var animalInfo: AnimalInfo?
    //Weak reference of animated image view
    weak var animatedImageView: AnimatedImageView?
    
    //Did change frame handler
    var didChangeFrame: ((Int) -> Void)?
    
    //Current frame variable that calls did change frame handler on change
    var currentFrameIndex = -1 {
        didSet {
            if currentFrameIndex >= 0{
                didChangeFrame?(currentFrameIndex)
            }
        }
    }
    
    lazy var dispatchQueue: DispatchQueue = {
        return DispatchQueue(label: (animalInfo?.name ?? "defaultVideo") + "Video", qos: .default)
    }()
    
    var animatedFilePath: String = String()
    
    
    
    //Preview image
//    var previewImage: UIImage?{
//        get{
//            var image = ImageCache.shared.getImage(imagePath: imagePath)
//            if image == nil{
//                image = UIImage(contentsOfFile: imagePath)
//                if image != nil{
//                    ImageCache.shared.setImage(imagePath: imagePath, image: image!)
//                }
//            }
//            return image
//        }
//    }
    
    //Set path of animated file
    init(animatedFilePath: String, animalInfo: AnimalInfo){
        self.animatedFilePath = animatedFilePath
        self.animalInfo = animalInfo
        
        
        if self.animatedFilePath.suffix(4) == ".gif"{
            self.type = .gif
        }
        else if self.animatedFilePath.suffix(4) == ".mp4"{
            self.type = .video
        }
    }
    
    
    ///Clear model
    func clear(){
        self.frames.removeAllObjects()
    }
    
    ///Change frame based on calculations
    func changeFrame() {
       
        dispatchQueue.async {
            
            self.returnCurrentFrame { [weak self] frame in
              
                self?.getNumberOfFrames(completion: { [weak self] numberOfFrames in
                    
                    guard numberOfFrames > 1, frame >= 0 else {
                        self?.animatedImageView?.stopAnimating()
                        return
                    }
                    
                    
                    //If current frame index is not the same as new one change frame (set image)
                    if frame != self?.currentFrameIndex {
                        self?.currentFrameIndex = frame
                    }
                    

                })
            }
        }
        
        
    }
    
    
    ///Returns an image based on frame number
    func getFrame(frameNumber: Int, completion: @escaping(UIImage?) -> Void){
        
    }
    
    
    ///Bind with image view and set did change frame handler
    func bindWithImageView(imageView: AnimatedImageView){
        self.animatedImageView = imageView
        
        //Did change current frame number; set image
        self.didChangeFrame = { [weak self] currentFrame in
            
            guard currentFrame >= 0 && self?.animalInfo?.soundManager.lastPlayingSound?.player.duration ?? 0 > 0 && self?.animatedImageView?.animatingImgs == true else{
                return
            }
            self?.dispatchQueue.async {
                
                self?.getFrame(frameNumber: currentFrame, completion: { [weak self] image in
                    DispatchQueue.main.async {
                        if self?.animatedImageView?.animatingImgs == true{
                            self?.animatedImageView?.image = image
                            print(self?.animatedImageView?.image)
                        }
                    }
                })
            }
            
        }
    }
    
    func unbindImageView(){
        self.animatedImageView = nil
    }
    
    //Set current image based on frame
    func setCurrentImage(frame: Int){
        guard self.animatedImageView?.animatingImgs == false else{
            return
        }
        dispatchQueue.async {
            self.getFrame(frameNumber: frame) { [weak self] image in
                DispatchQueue.main.async {
                    self?.animatedImageView?.image = image
                }
            }
        }
    }
    
    
    //Returns current frame of gif based on player's current time and duration
    func returnCurrentFrame(completion: @escaping(Int) -> Void){
        dispatchQueue.async {
            
            self.getNumberOfFrames { [weak self] frameNumber in
                guard let playerTime = self?.animalInfo?.soundManager.lastPlayingSound?.player.currentTime,
                      let duration = self?.animalInfo?.soundManager.lastPlayingSound?.player.duration, duration > 0 else{
                          completion(0)
                    return
                }
                
                let frameNum = max(0, min(frameNumber - 1, Int(Double((playerTime / duration) * Double(frameNumber)).rounded())))
                completion(frameNum)
            }
        }
    }
    
    //Returns current frame of gif based on given current time and duration
    func returnCurrentFrame(currentTime: Double, completion: @escaping(Int) -> Void){

        dispatchQueue.async {
            self.getNumberOfFrames { [weak self] frameNumber in
                guard let duration = self?.animalInfo?.soundManager.lastPlayingSound?.player.duration, duration > 0, frameNumber > 0 else{
                    completion(0)
                    return
                }
                let frame = max(0, min(frameNumber - 1, Int(Double((currentTime / duration) * Double(frameNumber)).rounded())))
                completion(frame)
            }
        }
        
    }
    
    //Return the time interval for gif to change the image
    func returnTimePerFrame(completion: @escaping(Double) -> Void){
        
        dispatchQueue.async {
            self.getNumberOfFrames { [weak self] frameNumber in
                guard let duration = self?.animalInfo?.soundManager.lastPlayingSound?.player.duration, duration > 0, frameNumber > 0 else{
                    completion(0.05)
                    return
                }
                
                let durationOfAnimation = duration /// Double(ControlValues.shared.speed)
                completion(durationOfAnimation / Double(frameNumber))
            }
        }
        
    }
    
    func getNumberOfFrames(completion: @escaping (Int) -> Void){

    }
    
    
    func setCurrentPausedImage() {
    }
    

}
