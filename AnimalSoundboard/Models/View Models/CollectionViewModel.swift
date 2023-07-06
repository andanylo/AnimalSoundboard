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
    
    
    ///Item size
    var itemSize: CGSize{
        get{
            let thirdofscreen = ((viewController?.view.frame.width ?? 600) - 10) / 3
            return CGSize(width: thirdofscreen - 4, height: thirdofscreen - 4)
        }
    }
    
    ///Original animal cell models fetched from file fetcher
    private var animalCellModels: [AnimalCellModel] = []
    
    ///Animal cell models to display in collection view
    var displayedAnimalCellModels: [AnimalCellModel]{
        get{
            return animalCellModels
        }
    }
    
    
    init(rootViewController: ViewController){
        self.viewController = rootViewController
    }
    
    
    ///Fetches files from main bundle and creates cell models from that
    func fetchAndCreateAnimalCellModels(completion: @escaping([AnimalCellModel]) -> Void){
        FilesFetcher.fetchFiles { [weak self] files in
            let animalInfos = AnimalInfoCreator.createAnimalInfos(filesFetch: files)
            var animalCellModels: [AnimalCellModel] = []
            for animalInfo in animalInfos{
                animalCellModels.append(AnimalCellModel(animalInfo: animalInfo))
            }
            self?.animalCellModels = animalCellModels
            completion(animalCellModels)
        }
    }
}
