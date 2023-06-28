//
//  ViewController.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 14.06.2023.
//

import UIKit

class ViewController: UIViewController {

    ///Collection view to display animal cells
    lazy var collectionViewModel: CollectionViewModel = {
        let model = CollectionViewModel(rootViewController: self)
        return model
    }()
    
    ///Collection view
    lazy var collectionView: UICollectionView = {
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = collectionViewModel.itemSize
        collectionViewLayout.minimumLineSpacing = 5
        collectionViewLayout.minimumInteritemSpacing = 5
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(AnimalCell.self, forCellWithReuseIdentifier: CollectionViewIdentifiers.cell.rawValue)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        collectionView.bounces = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnimalCellModel>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: {  collectionView, indexPath, model in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewIdentifiers.cell.rawValue, for: indexPath) as? AnimalCell else{
                return UICollectionViewCell()
            }
            
            cell.start(with: model)
            
            return cell
        })
        
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnimalCellModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems([])
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        collectionViewModel.fetchAndCreateAnimalCellModels { [weak self] cellModels in
            guard let snapshot = self?.createSnapshot(cellModels: cellModels) else{
                return
            }
            DispatchQueue.main.async {
                
                self?.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
    }
    
    enum Section{
        case main
    }
    
    enum CollectionViewIdentifiers: String{
        case cell = "Cell"
    }
    
    ///Creates new snapshot to update collection view
    func createSnapshot(cellModels: [AnimalCellModel]) -> NSDiffableDataSourceSnapshot<Section, AnimalCellModel>{
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnimalCellModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cellModels)
        return snapshot
    }
    
    
    ///Create animal cell models from scrath
//    func createAnimalCellModels() -> [AnimalCellModel]{
//
//    }


}

extension ViewController: UICollectionViewDelegate{
    
}
