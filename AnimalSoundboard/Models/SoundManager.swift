//
//  SoundPlayer.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation

///Sound manager class that manages the sound playback
class SoundManager{
    
    weak var animalSound: AnimalSound?
    
    init(animalSound: AnimalSound? = nil) {
        self.animalSound = animalSound
    }
}
