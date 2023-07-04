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
        
    }
    
    func willPlaySound(soundManager: SoundManager?) {
        
    }
    
    func didStartPlaying(soundManager: SoundManager?) {
        
    }
    
    static let shared = SoundHandler()
    
    weak var viewController: ViewController?
}



extension SoundHandler: AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
}


protocol SoundDelegate: AnyObject {
    func didStopPlaying(soundManager: SoundManager?, forced: Bool)
    func willPlaySound(soundManager: SoundManager?)
    func didStartPlaying(soundManager: SoundManager?)
}
