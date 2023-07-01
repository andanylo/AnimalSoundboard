//
//  SoundHandler.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 01.07.2023.
//

import Foundation
class SoundHandler: SoundDelegate{
    func didStopPlaying(soundManager: SoundManager, forced: Bool) {
        <#code#>
    }
    
    func willPlaySound(soundManager: SoundManager) {
        <#code#>
    }
    
    func didStartPlaying(soundManager: SoundManager) {
        <#code#>
    }
    
    static let shared = SoundHandler()
    
    weak var viewController: ViewController?
}


protocol SoundDelegate: AnyObject {
    func didStopPlaying(soundManager: SoundManager, forced: Bool)
    func willPlaySound(soundManager: SoundManager)
    func didStartPlaying(soundManager: SoundManager)
}
