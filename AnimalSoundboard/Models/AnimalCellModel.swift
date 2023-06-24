//
//  AnimalCellModel.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation

///Cell model for a reusable cell
class AnimalCellModel{
    
    ///Identifier that have a unique name in order to identify a model
    var identifier: String = ""
    
    ///Animal sound object that has an url and sound manager to play a sound
    var animalSound: AnimalSound?
    
    ///Displayed name on a cell
    lazy var displayedName: String = {
        return animalSound?.url.lastPathComponent ?? ""
    }()
    
    init(identifier: String){
        self.identifier = identifier
    }
}
