//
//  AnimalCell.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 27.06.2023.
//

import Foundation
import UIKit
import AVFoundation
class AnimalCell: UICollectionViewCell{
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.animalCellModel = nil
        self.nameLabel.removeFromSuperview()
        
        self.previewImageView.removeFromSuperview()
        self.stopButton.removeFromSuperview()
        
        self.animatedImageView?.image = nil
        self.animatedImageView?.DeInitialization()
        
        self.animatedImageView?.model?.animatedImageView = nil
        self.animatedImageView?.model = nil
        
        self.animatedImageView?.removeFromSuperview()
        
        self.nameLabel.isHidden = false
        
        self.contentView.removeGestureRecognizer(tapGestureRecognizer)
        self.contentView.removeGestureRecognizer(longGestureRecognizer)
        self.layer.removeAllAnimations()
        
    }
    var animalCellModel: AnimalCellModel?
    
    ///Name label
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .black)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    
    var animatedImageView: AnimatedImageView?
    
    ///Preview image
    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    ///Stop button
    lazy var stopButton: UIButton = {
        let stopButton =  UIButton(type: .custom)
        
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(stopSound), for: .touchUpInside)
        stopButton.setImage(UIImage(named: "Pause"), for: .normal)
        
        return stopButton
    }()
    
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(playFromPlayer))
        return gesture
    }()
    
    
    lazy var longGestureRecognizer: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(presentOptions))
        return gesture
    }()
    
    func start(with: AnimalCellModel){
        self.animalCellModel = with
        
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.clipsToBounds = true
        ///Set preview image view
        if previewImageView.superview == nil{
            self.contentView.addSubview(previewImageView)
            
            previewImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            previewImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            previewImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            previewImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        }
        if animalCellModel?.previewImage == nil{
            animalCellModel?.loadImageAsynchronically(completion: { image in
                DispatchQueue.main.async {
                    self.previewImageView.image = image
                }
            })
        }
        else if let image = animalCellModel?.previewImage{
            DispatchQueue.main.async {
                self.previewImageView.image = image
            }
        }
        
        
        ///Set animated image view
        if let model = animalCellModel?.animatedImageViewModel{
            if animatedImageView?.superview == nil {
                if animatedImageView == nil{
                    animatedImageView = AnimatedImageView(model: model)
                    animatedImageView?.contentMode = .scaleAspectFit
                    animatedImageView?.translatesAutoresizingMaskIntoConstraints = false
                }
                else{
                    animatedImageView?.model = model
                }
                
                self.contentView.addSubview(animatedImageView!)
                animatedImageView?.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
                animatedImageView?.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                animatedImageView?.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
                animatedImageView?.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            }
        }
        
        ///Set label
        if nameLabel.superview == nil{
            self.contentView.addSubview(nameLabel)
            
            nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
            nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5).isActive = true
        }
        
        nameLabel.text = animalCellModel?.displayedName
        nameLabel.sizeToFit()
        
        
        self.contentView.addGestureRecognizer(tapGestureRecognizer)
        
        if animalCellModel?.animalInfo?.soundManager.hasPlayingSounds() == true{
            self.animate()
            self.enterPlayState()
        }
        
        self.contentView.addGestureRecognizer(longGestureRecognizer)
        
        
    }
    
    ///Present options window
    @objc func presentOptions(){
        guard let animalCellModel = animalCellModel, let animalInfo = animalCellModel.animalInfo else{
            return
        }
        var actions: [[CustomAction]] = [
            [CustomAction(title: !animalInfo.favorite ? "Add to favorites" : "Remove from favorites", imageName: !animalInfo.favorite ? "star" : "star.slash", didClick: { [weak self] _,_ in
                if !animalInfo.favorite {
                    animalCellModel.addToFavorites()
                }
                else{
                    animalCellModel.removeFromFavorites()
                }
                DispatchQueue.main.async {
                    let addedToFavorites = animalInfo.favorite
                    animalCellModel.viewController?.collectionViewModel.manageFavorite(model: animalCellModel, isFavorited: addedToFavorites)
                   // animalCellModel.viewController?.dataSource?.apply(<#T##snapshot: NSDiffableDataSourceSnapshot<ViewController.Section, AnimalCellModel>##NSDiffableDataSourceSnapshot<ViewController.Section, AnimalCellModel>#>)
                }
            })]
        
        ]
        
        if self.animalCellModel?.animalInfo?.video == nil{
            actions[0].append(CustomAction(title: "Share an audio", imageName: "square.and.arrow.up", didClick: { [weak self] _, _ in
                self?.Share(type: .audio)
            }))
        }
        else{
            actions[0].append(CustomAction(title: "Share", didClick: { [weak self] picker, _ in
                var newActions: [CustomAction] = []
                
                newActions.append(CustomAction(title: "Share an audio", subtitle: nil, isSelected: false, imageName: "speaker.wave.3", didClick: { (_, _) in
                    self?.Share(type: .audio)
                }, style: .defaultStyle))
                
                newActions.append(CustomAction(title: "Share a video", subtitle: nil, isSelected: false, imageName: "play.rectangle", didClick: { (_, _) in
                    self?.Share(type: .video)
                }, style: .defaultStyle))
                
                picker.presentOtherController(title: "Share '\(self?.animalCellModel?.displayedName ?? "")'", actions: [newActions])
            }, style: .transitionStyle))
        }
        
        
        let customPicker = CustomPicker(title: "", actions: actions, sourceFrame: self.superview?.convert(self.frame, to: self.animalCellModel?.viewController?.navigationController?.view))
        customPicker.priorityWidth = 250

        customPicker.modalPresentationStyle = .custom
        customPicker.transitioningDelegate = Animator.shared
        self.animalCellModel?.viewController?.present(customPicker, animated: true)
    }
    
    
    enum ShareType{
        case video
        case audio
    }
    
    ///Share a sound and present an activity controller
    func Share(type: ShareType){
        guard let animalCellModel = self.animalCellModel else{
            return
        }
        animalCellModel.share(type: type) { [weak self] urls in
            guard let self = self else{
                return
            }
            self.animalCellModel?.viewController?.presentActivityController(urls: urls, sender: self)
        }
    }
    
    func enterPlayState(){
        DispatchQueue.main.async {
            self.stopButtonStatus(hide: false)
            self.nameLabel.isHidden = self.animatedImageView?.model != nil
            self.animatedImageView?.loadGif()
        }
    }
    
    
    func stopButtonStatus(hide: Bool){
        if hide{
            self.stopButton.removeFromSuperview()
        }
        else{
            self.contentView.addSubview(self.stopButton)
            
            stopButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -7).isActive = true
            stopButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 7).isActive = true
            
            let heightButton = min(43, self.frame.height / 3)
            
            
            stopButton.heightAnchor.constraint(equalToConstant: heightButton).isActive = true
            stopButton.widthAnchor.constraint(equalTo: stopButton.heightAnchor, multiplier: 0.625).isActive = true
        }
    }
    
    @objc func stopSound(){
        guard let animalInfo = self.animalCellModel?.animalInfo else{
            return
        }
        
        PlayerManager.shared.stopAllSounds(soundManager: animalInfo.soundManager)
    }
    
    
    @objc func playFromPlayer(){
        animalCellModel?.animalInfo?.soundManager.play()
    }
    
    ///Will start playing
    func willStartPlaying(){
        impulseAnimation()
        stopButtonStatus(hide: false)
        
        
        ///Hide name label
        if animalCellModel?.animatedImageViewModel != nil{
            nameLabel.isHidden = true
            ///Start animating, set first frame
            ///Set first image
            guard let model = self.animatedImageView?.model else{
                return
            }
            
            model.dispatchQueue.async {
                model.getNumberOfFrames(completion: { numberOfFrames in
                    model.setCurrentImage(frame: 0)
                })
            }
        }
        
        
        
    }
    
    
    ///Did start playing
    func didStartPlaying(){
        animatedImageView?.loadGif()
    }
    
    ///Did stop playing
    func didStopPlaying(forced: Bool){
        DispatchQueue.main.async {
            self.animatedImageView?.stopAnimating()
            self.stopButtonStatus(hide: true)
            self.nameLabel.isHidden = false
        }
        if forced == true{
            self.stopAnimation()
        }
        else{
            self.backToNormalAnimation()
        }
        
        
        
    }
    
    
    //MARK: - Animations
    ///Animate after the click of the cell
    func impulseAnimation(){
        self.layer.removeAllAnimations()
        let animatePulsing = CABasicAnimation(keyPath: "transform.scale")
        animatePulsing.fromValue = 1.0
        animatePulsing.toValue = 0.945
        animatePulsing.duration = 0.09
        animatePulsing.autoreverses = true
        animatePulsing.isRemovedOnCompletion = false
        animatePulsing.delegate = self
        self.layer.add(animatePulsing, forKey: "pulse")
    }
    
    ///Animate after the stop button clicked
    func stopAnimation(){
        self.layer.removeAllAnimations()
        let stopAnimation = CABasicAnimation(keyPath: "transform.scale")
        stopAnimation.fromValue = 1.0
        stopAnimation.toValue = 0.945
        stopAnimation.duration = 0.09
        stopAnimation.autoreverses = true
        self.layer.add(stopAnimation, forKey: "stop")
    }
    
    ///Animate cell during the play of the sound
    func animate(){
        if self.layer.animation(forKey: "transform") != nil{
            self.layer.removeAnimation(forKey: "transform")
        }
        let animateTransform = CABasicAnimation(keyPath: "transform.scale")
        animateTransform.fromValue = 1
        animateTransform.toValue = 0.965
        animateTransform.duration = 0.20
        animateTransform.autoreverses = true
        animateTransform.repeatCount = .infinity
        self.layer.add(animateTransform, forKey: "transform")
    }
    
    ///Animate tranformation back to normal state
    func backToNormalAnimation(){
        
        guard let fromValue = self.layer.presentation()?.value(forKeyPath: "transform.scale") as? Double else{
            return
        }
        
        self.layer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = fromValue
        animation.toValue = 1
        animation.duration = 0.15
        animation.repeatCount = 1
        self.layer.add(animation, forKey: "backToNormal")
    }
    
}

extension AnimalCell: CAAnimationDelegate{
    //Animation did stop
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //Resume impulse animation if playing on highlight stop
        if anim is CAAnimationGroup && animalCellModel?.animalInfo?.soundManager.hasPlayingSounds() == true {
            animate()
        }
        
        //Animate random sound
        if anim == self.layer.animation(forKey: "pulse") && flag == true{
            self.layer.removeAnimation(forKey: "pulse")
            animate()
        }
    }
}
