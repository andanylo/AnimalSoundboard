//
//  PlayerManager.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 01.07.2023.
//

import Foundation
import AVFoundation
///Player manager to manage avaudioplayers
class PlayerManager{
 
    static let shared = PlayerManager()
    
    private var numberInOverloaded = 0
    
    var players: [Sound] = []
    
    init(){
        for _ in 0..<PlayerLimiter.maxSoundCount{
            players.append(Sound())
        }
    }
    
    //Check if manager contains playing players
    func hasPlayingPlayers() -> Bool{
        return players.contains(where: {$0.isPlaying})
    }
    
    //Mute or unmute sounds
    func muteOrUnmutePlayers(mute: Bool){
        for i in players{
            i.player.volume = mute == true ? 0 : 1
        }
    }
    
    
    //Find player to play
    func findPlayerToPlay() -> Sound?{
//        if DataStorage.shared.currMode == Modes.Once.rawValue{
//            return nodes.first
//        }
        let contains = players.contains(where: {!$0.isPlaying})
        if contains{
            return players.first(where: {!$0.isPlaying})
        }
        let node = players[numberInOverloaded]
        numberInOverloaded = numberInOverloaded < (PlayerLimiter.maxSoundCount - 1) ? (numberInOverloaded + 1) : 0
        return node
    }
    
    
    //Stop all players with or without soundManager
    func stopAllSounds(soundManager: SoundManager?){
        let newNodes = players.sorted(by: {$0.player.currentTime > $1.player.currentTime })
        for node in newNodes{
            
            if soundManager == nil{
                node.forceStop()
               
            }
            else if soundManager != nil && soundManager === node.soundManager{
                node.forceStop()
            }
        }
    }
    
    
    
    
}
class PlayerLimiter{
    
    
    static var maxSoundCount: Int{
        get{
            return 30
        }
    }
}
