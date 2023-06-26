//
//  SoundPlayer.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation

///Sound manager class that manages the sound playback
class SoundManager{
    
    weak var animalInfo: AnimalInfo?
    
    init(animalInfo: AnimalInfo? = nil) {
        self.animalInfo = animalInfo
    }
}
