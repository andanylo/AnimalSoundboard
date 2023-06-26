//
//  CollectionViewModel.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 26.06.2023.
//

import Foundation

///Collection view model that manipulates collection view status
class CollectionViewModel{
    
    weak var viewController: ViewController?
    
    
    ///Original animal cell models fetched from file fetcher
    var animalCellModels: [AnimalCellModel] = []
    
    ///Animal cell models to display in collection view
    private var displayedAnimalCellModels: [AnimalCellModel]{
        get{
            return animalCellModels
        }
    }
    
    
    init(rootViewController: ViewController){
        self.viewController = rootViewController
    }
    
    
    ///Fetches files from main bundle and creates cell models from that
    func fetchAndCreateAnimalCellModels(completion: @escaping([AnimalCellModel]) -> Void){
        FilesFetcher.fetchFiles { files in
            let animalInfos = AnimalInfoCreator.createAnimalInfos(filesFetch: files)
            var animalCellModels: [AnimalCellModel] = []
            for animalInfo in animalInfos{
                animalCellModels.append(AnimalCellModel(animalInfo: animalInfo))
            }
            
            completion(animalCellModels)
        }
    }
}
