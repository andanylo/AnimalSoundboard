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
    
    
    ///Stop all button
    lazy var stopAllButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Stop all", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSize(width: 0.5, height: 1)
        button.layer.shadowOpacity = 0.6
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.addTarget(self, action: #selector(stopAll), for: .touchUpInside)
        
        return button
    }()
    
    
    ///Search view on top
    lazy var searchView: SearchView = {
        return SearchView(frame: CGRect.zero)
    }()
    
    
    ///Calculated search view height with safe are
    private var searchViewHeight: CGFloat{
        get{
            return self.view.safeAreaInsets.top + 60
        }
        
    }
    
    var topConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint?
    
    @objc func stopAll(){
        PlayerManager.shared.stopAllSounds(soundManager: nil)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnimalCellModel>?
    
    override func viewDidLayoutSubviews() {
        if heightConstraint?.constant != searchViewHeight{
            heightConstraint?.constant = searchViewHeight
            collectionView.contentInset.top = searchView.frame.height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        SoundHandler.shared.viewController = self
        
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
            for cellModel in cellModels {
                cellModel.viewController = self
            }
            guard let snapshot = self?.createSnapshot(cellModels: cellModels) else{
                return
            }
            DispatchQueue.main.async {
                self?.dataSource?.apply(snapshot, animatingDifferences: true)
            }
        }
        
        
        self.view.addSubview(stopAllButton)
        
        stopAllButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        stopAllButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        stopAllButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        
        
        ///Search view on top
        self.view.addSubview(searchView)
        
        
        searchView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        heightConstraint = self.searchView.heightAnchor.constraint(equalToConstant: searchViewHeight)
        heightConstraint?.isActive = true
        
        
        topConstraint = searchView.topAnchor.constraint(equalTo: self.view.topAnchor)
        topConstraint?.isActive = true
        
        
        
        self.view.layoutIfNeeded()
        
        
        ///On search text change
        searchView.textDidChange = { [weak self] searchText in
            self?.collectionViewModel.displayedFilterName = searchText
            guard let snapshot = self?.createSnapshot(cellModels: self?.collectionViewModel.displayedAnimalCellModels ?? []) else{
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
    
    
    private var lastScroll: CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        
        
        ///Show the search bar if scrolled past the top
        ///
        guard scrollView.isDragging else{
            lastScroll = contentOffset
            return
        }
        
        let delta = contentOffset - lastScroll
        let constant = topConstraint.constant - delta
        let searchTopConstraint = max(constant < 0 ? constant : 0, -searchView.frame.height)
        
       
        ///CONST >= (-HEIGHT) - hide
        ///CONST <= 0 - show
        //show search bar
        if topConstraint.constant != searchTopConstraint && scrollView.contentOffset.y + scrollView.frame.height < scrollView.contentSize.height && searchView.searchBar.text?.isEmpty != false{
            if delta < 0{
                topConstraint.constant = searchTopConstraint
                //collectionView.contentInset.top = searchView.frame.height - self.view.safeAreaInsets.top + topConstraint.constant
            }
            else{
                if scrollView.contentOffset.y >= -searchView.frame.height {
                    topConstraint.constant = searchTopConstraint
                    //collectionView.contentInset.top = searchView.frame.height - self.view.safeAreaInsets.top + topConstraint.constant
                }
            }

            self.view.layoutIfNeeded()
        }
        lastScroll = contentOffset
    }
    
    
    



}

extension ViewController: UICollectionViewDelegate{
    
}
