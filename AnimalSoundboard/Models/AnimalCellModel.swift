//
//  AnimalCellModel.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation

///Cell model for a reusable cell
class AnimalCellModel: Hashable{
    static func == (lhs: AnimalCellModel, rhs: AnimalCellModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    ///Identifier that have a unique name in order to identify a model
    var identifier: String = ""
    
    ///Animal info object that has an url and sound manager to play a sound
    var animalInfo: AnimalInfo?
    
    var displayedName: String{
        get{
            return animalInfo?.name ?? ""
        }
    }
    
    init(identifier: String){
        self.identifier = identifier
    }
    
    init(animalInfo: AnimalInfo){
        self.identifier = animalInfo.url.path
        self.animalInfo = animalInfo
    }
}
