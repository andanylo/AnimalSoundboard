//
//  GIFTimerModel.swift
//  Meme Soundboard
//
//  Created by Danil Andriuschenko on 08.02.2022.
//  Copyright © 2022 Danil Andriuschenko. All rights reserved.
//

import Foundation


///Class with the animation timer, that fires methods to change frame of GIFs
class VideoTimerModel{
    
    static let shared = VideoTimerModel()
    private let dispatchQueue = DispatchQueue(label: "com.andanylo.GIFTimerModel")
    
    var interval: Double = 0.015//0.03
    
    ///Timer that fires methods to change a frame
    var timer: Timer?
    
    ///Array of image animated models, which need to change current frame
    private var _linkedImageModels: [AnimatedImageViewModel] = []
    private var linkedImageModels: [AnimatedImageViewModel]{
        get{dispatchQueue.sync{_linkedImageModels}}
        set{dispatchQueue.sync{self._linkedImageModels = newValue}}
    }
    
    
    func stopTimer(){
        linkedImageModels.removeAll()
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer(with: AnimatedImageViewModel){
        linkedImageModels.append(with)
        startTimer()
    }
    
    func startTimer(){
        timer?.invalidate()
        
        //Start timer
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] _ in
            
            if let linkedModels = self?.linkedImageModels{
                for model in linkedModels {
                    if model.animatedImageView != nil && model.animatedImageView?.animatingImgs == true{
                        model.animatedImageView?.changeFrame()
                    }
                }
            }
        })
        
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    
    
    func didFinishAnimating(model: AnimatedImageViewModel){
        
        if let index = linkedImageModels.firstIndex(where: {$0 === model}){
            linkedImageModels.remove(at: index)
        }
        if linkedImageModels.isEmpty{
            timer?.invalidate()
            timer = nil
        }

    }
    
    func addAnimateImageModel(model: AnimatedImageViewModel){
        if linkedImageModels.isEmpty{
            startTimer(with: model)
        }
        else{
            linkedImageModels.append(model)
        }
    }
    
    
}
