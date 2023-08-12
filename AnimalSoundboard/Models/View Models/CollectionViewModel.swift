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
            return animalCellModels.filter({displayedFilterName == nil || displayedFilterName?.isEmpty == true ? true : $0.displayedName.contains(displayedFilterName!)})
        }
    }
    
    var displayedFilterName: String? = nil
    
    
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
    
    ///Manage favorite cell model
    func manageFavorite(model: AnimalCellModel, isFavorited: Bool){
        guard let dataSource = model.viewController?.dataSource, let cellModels = model.viewController?.collectionViewModel.displayedAnimalCellModels else{
            return
        }
        
        
        
        var snapshot = dataSource.snapshot()
        
        let favoritedModels = cellModels.filter({$0.animalInfo?.favorite == true})
        let notFavoritedModels = cellModels.filter({$0.animalInfo?.favorite == false})

        if isFavorited{
            
            snapshot.deleteItems([model])
            snapshot.appendItems([model], toSection: .favorites)
            
            let favoritedIndex = favoritedModels.firstIndex(of: model)
            
            if favoritedModels.count > 1 && favoritedIndex ?? 0 < favoritedModels.count - 1{
                snapshot.moveItem(model, beforeItem: favoritedModels[(favoritedIndex ?? 0) + 1])
            }
        }
        else{
            snapshot.deleteItems([model])
            snapshot.appendItems([model], toSection: .main)
            
            let notFavoritedIndex = notFavoritedModels.firstIndex(of: model)
            if  notFavoritedModels.count > 1 && notFavoritedIndex ?? 0 < notFavoritedModels.count - 1{
                snapshot.moveItem(model, beforeItem: notFavoritedModels[(notFavoritedIndex ?? 0) + 1])
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
