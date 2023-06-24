//
//  AnimalSound.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation

///An animal sound class that contains path for a sound, name
class AnimalSound{
    
    ///Url for a sound
    var url: URL
    
    ///Sound manager to play a sound
    lazy var soundManager: SoundManager = {
        return SoundManager(animalSound: self)
    }()
    
    init(url: URL){
        self.url = url
        
        self.name = url.lastPathComponent
    }
    
    
}
