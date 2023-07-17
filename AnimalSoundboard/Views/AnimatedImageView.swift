//
//  UIImage+Gif.swift
//  Meme Soundboard
//
//  Created by Danil Andriuschenko on 1/30/19.
//  Copyright © 2019 Danil Andriuschenko. All rights reserved.
//

import UIKit




class AnimatedImageView: UIImageView{
    
    
    var model: AnimatedImageViewModel?{
        didSet{
            if oldValue?.animatedImageView === self{
                oldValue?.unbindImageView()
            }
            if model != nil{
                model?.bindWithImageView(imageView: self)
            }
        }
    }
    
    var animatingImgs: Bool = false
    
    //Start animation
    override func startAnimating() {
        //Set current frame based on current player time
        guard let model = self.model else{
            return
        }
        model.returnCurrentFrame(completion: { frame in
            model.setCurrentImage(frame: frame )
        })
        
        
        animatingImgs = true

        
        VideoTimerModel.shared.addAnimateImageModel(model: model)
        
        
    }
    //Stop animation
    override func stopAnimating() {

        if let model = self.model {
            VideoTimerModel.shared.didFinishAnimating(model: model)
        }
        
        
        //reset current frame index
        model?.currentFrameIndex = -1
        self.image = nil
        

        
        animatingImgs = false
        
        
    }
    
    //Change frame based on audio player
    func changeFrame() {
        model?.changeFrame()
    }
    
    
    
    
//    private func setModelImage(animated: Bool){
//        model?.bindWithImageView(imageView: self)
//
//
//        //Set preview image
//        if !self.animatingImgs {
//
//            self.alpha = 0
//            self.model?.setCurrentImage(frame: 0)
//
//            if animated{
//                UIView.animate(withDuration: 0.33, delay: 0, options: [.transitionCrossDissolve]) {
//                    self.alpha = 1
//                }
//            }
//            else{
//                self.alpha = 1
//            }
//        }
//    }
    
    //Start gif
    func loadGif() {
        self.stopAnimating()

        //if animating gif set image on calculated frame number
        if model?.animalInfo?.soundManager.lastPlayingSound?.player.currentTime ?? 0 > 0{
            guard let model = self.model else{
                return
            }
            
            model.returnCurrentFrame(completion: { frame in
                model.setCurrentImage(frame: frame )
            })

        }
        
      
        
        
        self.startAnimating()
        
        
    }
  
    
    //Change timer interval after speed changed
    func didChangeSpeed(){
        if self.animatingImgs{

            self.changeFrame()
        }
        
    }
    
    //Clear imageView
    func DeInitialization(){
        self.stopAnimating()
        
        self.image = nil
        self.animationImages = nil
        self.animationDuration = 0.0
    }
    init(model: AnimatedImageViewModel){
        super.init(frame: CGRect.zero)
        self.model = model
        self.model?.bindWithImageView(imageView: self)
        //setModelImage(animated: false)
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    deinit {
       
    }
}
