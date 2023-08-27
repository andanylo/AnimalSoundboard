//
//  CollectionViewModel.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 26.06.2023.
//

import Foundation
import UIKit

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
    
    
    func createSnapshot(cellModels: [AnimalCellModel]) -> NSDiffableDataSourceSnapshot<ViewController.Section, AnimalCellModel>{
        var snapshot = NSDiffableDataSourceSnapshot<ViewController.Section, AnimalCellModel>()
        snapshot.appendSections([.favorites, .main, .wild, .farm, .insects, .birds, .cats, .dogs])
        let favoriteModels = cellModels.filter({$0.animalInfo?.favorite == true})
        snapshot.appendItems(favoriteModels, toSection: .favorites)
        
        let sections: [ViewController.Section] = [.main, .wild, .farm, .insects, .birds, .cats, .dogs]
        for section in sections{
            let sectionModels = cellModels.filter({($0.animalInfo?.info?.group_id == section.rawValue || (section == .main && $0.animalInfo?.info == nil)) && $0.animalInfo?.favorite == false})
            snapshot.appendItems(sectionModels, toSection: section)
        }
        
        return snapshot
        
        
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
        let sectionModels = cellModels.filter({$0.originalSection == model.originalSection})

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
            snapshot.appendItems([model], toSection: model.originalSection)
            
            let sectionIndex = sectionModels.firstIndex(of: model)
            if sectionModels.count > 1 && sectionIndex ?? 0 < sectionModels.count - 1{
                snapshot.moveItem(model, beforeItem: sectionModels[(sectionIndex ?? 0) + 1])
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
