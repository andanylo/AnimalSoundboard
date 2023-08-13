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
        lab.textColor = .darkGray
        lab.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return lab
    }()
    
    lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .darkGray
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        label.removeFromSuperview()
        icon.removeFromSuperview()
    }
    
    func start(section: ViewController.Section){
        self.section = section
        
        if label.superview == nil{
            self.addSubview(label)
            
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        label.text = section == .favorites ? "Favorites" : "Animal library"
        
        
        if icon.superview == nil{
            self.addSubview(icon)
            
            icon.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5).isActive = true
            icon.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        }
        
        icon.image = UIImage(systemName: section == .favorites ? "star" : "books.vertical")
        
    }
    
    
    
}
