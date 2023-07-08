//
//  Sound.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 01.07.2023.
//

import Foundation
import AVFoundation
class Sound{
    var player: Player = Player()
    weak var soundManager: SoundManager?{
        didSet{
            if let oldSoundManager = oldValue, !(oldSoundManager === soundManager){
                oldSoundManager.clearRemovedSound(sound: self, forced: false)
            }
        }
    }
    
    var isForceStopped = false
    var isPlaying: Bool {
        get{
            return player.isPlaying
        }
    }
    
    
    func clear(){
        //forceStop()
        player = Player()
        isForceStopped = false
        soundManager = nil
    }
    
    func forceStop(){
        isForceStopped = true
        player.stop()
        
    }
    
    
    ///Constructs player
    func constructPlayer(completion: ((_ errors: Bool) -> Void)?){
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let url = self.soundManager?.animalInfo?.url else{
                completion?(true)
                return
            }
            
            let changed = url != self.player.url
            if changed {
                do{
                    self.player = try Player(contentsOf: url)
                    self.player.delegate = self.soundManager?.soundHander
                    self.player.volume = 1.0
                }
                catch{
                    completion?(true)
                }
            }
            completion?(false)
            
        }
            
        
    }
    
    func play(){
        guard self.soundManager?.animalInfo?.url == player.url else{
            return
        }
        do{
            try setAudioSetting()
            player.prepareToPlay()
            player.play()
            
        }
        catch{
            
        }
        
        
        
    }
    
    
    func setAudioSetting() throws{
        
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try AVAudioSession.sharedInstance().setActive(true)
    }
}

class Player: AVAudioPlayer{
    override func stop() {
        super.stop()
        
        self.delegate?.audioPlayerDidFinishPlaying?(self, successfully: false)
    }
}
