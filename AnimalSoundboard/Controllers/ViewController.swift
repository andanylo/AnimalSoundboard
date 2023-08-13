//
//  ViewController.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 14.06.2023.
//

import UIKit
import Photos

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
        collectionViewLayout.headerReferenceSize = CGSize(width: self.view.frame.width, height: 30)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(AnimalCell.self, forCellWithReuseIdentifier: CollectionViewIdentifiers.cell.rawValue)
        collectionView.register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewIdentifiers.header.rawValue)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 60, right: 5)
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
    
    var stopButtonBottomConstraint: NSLayoutConstraint!
    
    
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
    
    var dataSource: UICollectionViewDiffableDataSource<Section, AnimalCellModel>?
    
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
        
        self.dataSource?.supplementaryViewProvider = { collectionView, type, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewIdentifiers.header.rawValue, for: indexPath) as? Header else{
                return Header(frame: CGRect.zero)
            }
            header.start(section: indexPath.section == 0 ? .favorites : .main)
            return header
        }
        
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnimalCellModel>()
        snapshot.appendSections([.favorites, .main])
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
                self?.dataSource?.apply(snapshot, animatingDifferences: false)
            }
        }
        
        
        self.view.addSubview(stopAllButton)
        
        stopButtonBottomConstraint = stopAllButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        stopButtonBottomConstraint.isActive = true
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
        case favorites
        case main
    }
    
    enum CollectionViewIdentifiers: String{
        case cell = "Cell"
        case header = "Header"
    }
    
    ///Creates new snapshot to update collection view
    func createSnapshot(cellModels: [AnimalCellModel]) -> NSDiffableDataSourceSnapshot<Section, AnimalCellModel>{
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnimalCellModel>()
        snapshot.appendSections([.favorites,.main])
        let favoriteModels = cellModels.filter({$0.animalInfo?.favorite == true})
        
        snapshot.appendItems(favoriteModels, toSection: .favorites)
        let mainModels = cellModels.filter({$0.animalInfo?.favorite == false})
        snapshot.appendItems(mainModels, toSection: .main)
        
        return snapshot
    }
    var isHidden = false
    
    ///Animate stop button bottom constraint
    func animateStopButtonBottomConstraint(hide: Bool){
        if isHidden != hide{
            isHidden = hide
            stopButtonBottomConstraint.constant = hide ? 150 : -5
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private var lastScroll: CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        
        
        ///Show the search bar if scrolled past the top
        ///
//        guard scrollView.isDragging else{
//            lastScroll = contentOffset
//            return
//        }
        if scrollView.isDragging{
            self.animateStopButtonBottomConstraint(hide: true)
            
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
                    searchView.searchBar.resignFirstResponder()
                    //collectionView.contentInset.top = searchView.frame.height - self.view.safeAreaInsets.top + topConstraint.constant
                }
            }

            self.view.layoutIfNeeded()
        }
        
        lastScroll = contentOffset
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.animateStopButtonBottomConstraint(hide: false)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.animateStopButtonBottomConstraint(hide: false)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.animateStopButtonBottomConstraint(hide: false)
    }
    
    ///Presents activity controller
    func presentActivityController(urls: [URL], sender: UIView){
        DispatchQueue.main.async {
            let activitiyvc = UIActivityViewController(activityItems: urls, applicationActivities: nil)
            activitiyvc.completionWithItemsHandler = { (a,b,c,d) in
                if b == true{
                    do{
                        for i in urls{
                            try FileManager.default.removeItem(at: i)
                        }
                        let alert = UIAlertController(title: "Success", message: "You have successfully shared this sound.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    catch{
                        
                    }
                }
                else if d != nil{
                    
                    if PHPhotoLibrary.authorizationStatus() != .authorized{
                        let alert = UIAlertController(title: "Can't save video", message: "To save this video, you must allow photos access.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Open 'Settings'", style: .default, handler: {_ in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! , options: [:], completionHandler: nil)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            activitiyvc.popoverPresentationController?.sourceView = sender
            self.present(activitiyvc, animated: true, completion: nil)
        }
    }
    



}

extension ViewController: UICollectionViewDelegate{
    
}
