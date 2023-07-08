//
//  SoundHandler.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 01.07.2023.
//

import Foundation
import AVFoundation
class SoundHandler: NSObject, SoundDelegate{
    func didStopPlaying(soundManager: SoundManager?, forced: Bool) {
        guard let playingCell = findPlayingCell(soundManager: soundManager) else{
            return
        }
        
        DispatchQueue.main.async{

            playingCell.didStopPlaying(forced: forced)
        }
    }
    
    func willPlaySound(soundManager: SoundManager?) {
        
        guard let playingCell = findPlayingCell(soundManager: soundManager) else{
            return
        }
        playingCell.willStartPlaying()
    }
    
    func didStartPlaying(soundManager: SoundManager?) {
        DispatchQueue.main.async {
            guard let playingCell = self.findPlayingCell(soundManager: soundManager) else{
                return
            }
            
            playingCell.didStartPlaying()
        }
        
    }
    
    func findPlayingCell(soundManager: SoundManager?) -> AnimalCell?{
        guard let visibleCells = viewController?.collectionView.visibleCells as? [AnimalCell] else{
            return nil
        }
        
        return visibleCells.first(where: {$0.animalCellModel?.animalInfo === soundManager?.animalInfo})
    }
    
    static let shared = SoundHandler()
    
    weak var viewController: ViewController?
    
    func stop(player: AVAudioPlayer){
    
        guard let sound = PlayerManager.shared.players.first(where: {$0.player === player}) else{
            return
        }
        
    
        
        sound.soundManager?.didFinish(sound: sound)
    }
    
    
    
}



extension SoundHandler: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finsihed")
        
        guard let sound = PlayerManager.shared.players.first(where: {$0.player === player}) else{
            return
        }
        
        sound.soundManager?.didFinish(sound: sound)
    }
}


protocol SoundDelegate: AnyObject {
    func didStopPlaying(soundManager: SoundManager?, forced: Bool)
    func willPlaySound(soundManager: SoundManager?)
    func didStartPlaying(soundManager: SoundManager?)
}
