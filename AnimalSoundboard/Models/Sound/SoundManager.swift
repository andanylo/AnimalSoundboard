//
//  SoundPlayer.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation
import AVFoundation
///Sound manager class that manages the sound playback
class SoundManager{
    
    weak var animalInfo: AnimalInfo?

    weak var soundHander: SoundHandler? = SoundHandler.shared
    var lastPlayingSound: Sound?
    
    ///Clear sound and call finish handler
    func clearRemovedSound(sound: Sound, forced: Bool){
        guard sound.player.url != nil else{
            return
        }
        
        ///Call handler and clear
        if sound === lastPlayingSound{
            soundHander?.didStopPlaying(soundManager: self, forced: forced)
            lastPlayingSound = nil
        }
    }
    
    //Has playing sounds
    func hasPlayingSounds() -> Bool{
        return lastPlayingSound != nil
    }
   
    
    
    func removeSound(sound: Sound, forced: Bool){
        clearRemovedSound(sound: sound, forced: forced)
        sound.clear()
    }
    
    ///Did finish callback
    func didFinish(sound: Sound){
        
        //If sound was force stopped, remove it
//        if sound.isForceStopped {
            removeSound(sound: sound, forced: sound.isForceStopped)
//        }
//        else if ("Repeat" == "Repea"){
//
//        }
//        else{
//            removeSound(sound: sound, forced: sound.isForceStopped)
//        }
    }
    
    func play(){
        guard let url = self.animalInfo?.url else{
            return
        }
        
        let shouldPlayInOtherPlayer = true//lastPlayingSound == nil//!(DataStorage.shared.currMode != Modes.Multiple.rawValue && DataStorage.shared.currMode != Modes.Simple.rawValue && lastPlayingSound != nil)
        
        var sound: Sound?
        
        if shouldPlayInOtherPlayer{
            sound = PlayerManager.shared.findPlayerToPlay()
            lastPlayingSound = sound
        }
        else{
            sound = lastPlayingSound
        }
        
        sound?.soundManager = self
        
        
        if let sound = sound{
            sound.constructPlayer { [weak self] errors in
                guard errors == false else{
                    sound.soundManager?.removeSound(sound: sound, forced: true)
                    return
                }
                
                sound.play()
                
                sound.soundManager?.soundHander?.didStartPlaying(soundManager: sound.soundManager ?? self)
            }
            
            
            sound.soundManager?.soundHander?.willPlaySound(soundManager: sound.soundManager ?? self)
        }
        
    }
    
    ///Get players currently playing from the blockSound
    func getPlayingPlayers() -> [Sound]?{
        return PlayerManager.shared.players.filter({$0.player.url == animalInfo?.url && $0.isPlaying})
    }
    
    init(animalInfo: AnimalInfo? = nil) {
        self.animalInfo = animalInfo
    }
}
