//
//  ViewController.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 14.06.2023.
//

import UIKit

class ViewController: UIViewController {

//    lazy var collectionView: UICollectionView = {
//        
//    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        
        FilesFetcher.fetchFiles { files in
            print(files)
        }
    }
    
    ///Create animal cell models from scrath
//    func createAnimalCellModels() -> [AnimalCellModel]{
//
//    }


}

