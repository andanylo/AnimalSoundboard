//
//  Header.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 11.08.2023.
//

import Foundation
import UIKit



class Header: UICollectionReusableView{
    
    var section: ViewController.Section?
    
    lazy var label: UILabel = {
        let lab = UILabel()
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.textColor = .black
        lab.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return lab
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.removeFromSuperview()
    }
    
    func start(section: ViewController.Section){
        self.section = section
        
        if label.superview == nil{
            self.addSubview(label)
            
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        label.text = section == .favorites ? "Favorites" : "Library"
        
    }
    
    
    
}
