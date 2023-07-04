//
//  Sound.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 01.07.2023.
//

import Foundation
import AVFoundation
class Sound{
    var player: AVAudioPlayer = AVAudioPlayer()
    weak var soundManager: SoundManager?
    
    var isForceStopped = false
    var isPlaying: Bool {
        get{
            return player.isPlaying
        }
    }
    
    
    func clear(){
        forceStop()
        player = AVAudioPlayer()
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
                    self.player = try AVAudioPlayer(contentsOf: url)
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
        
        player.prepareToPlay()
        player.play()
    }
    
}
