//
//  AnimalInfoCreator.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 26.06.2023.
//

import Foundation


///Animal info creator class
class AnimalInfoCreator{
    
    ///Create animal info
    private static func createAnimalInfo(fileFetch: FilesFetcher.FileFetch) -> AnimalInfo{
        let animalInfo = AnimalInfo(fileFetch: fileFetch)
        return animalInfo
    }
    
    ///Create animal infos
    static func createAnimalInfos(filesFetch: [FilesFetcher.FileFetch]) -> [AnimalInfo]{
        var animalInfos: [AnimalInfo] = []
        for fetch in filesFetch {
            animalInfos.append(createAnimalInfo(fileFetch: fetch))
        }
        return animalInfos
    }
    
}
