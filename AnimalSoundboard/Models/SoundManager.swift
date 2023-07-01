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

    weak var soundHander: SoundHandler?
    private var player: AVAudioPlayer = AVAudioPlayer()
    
    func play(){
        guard let url = self.animalInfo?.url else{
            return
        }
    }
    
    init(animalInfo: AnimalInfo? = nil) {
        self.animalInfo = animalInfo
    }
}
