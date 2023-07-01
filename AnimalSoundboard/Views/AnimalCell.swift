//
//  AnimalCell.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 27.06.2023.
//

import Foundation
import UIKit
class AnimalCell: UICollectionViewCell{
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.animalCellModel = nil
        self.nameLabel.removeFromSuperview()
        
        self.previewImageView.removeFromSuperview()
    }
    var animalCellModel: AnimalCellModel?
    
    ///Name label
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .black)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    //
    lazy var previewImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    func start(with: AnimalCellModel){
        self.animalCellModel = with
        
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 15
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.clipsToBounds = true
        
        if previewImageView.superview == nil{
            self.contentView.addSubview(previewImageView)
            
            previewImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            previewImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            previewImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            previewImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        }
        if animalCellModel?.previewImage == nil{
            animalCellModel?.loadImageAsynchronically(completion: { image in
                DispatchQueue.main.async {
                    self.previewImageView.image = image
                }
            })
        }
        
        
        if nameLabel.superview == nil{
            self.contentView.addSubview(nameLabel)
            
            nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 5).isActive = true
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
            nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5).isActive = true
        }
        
        nameLabel.text = animalCellModel?.displayedName
        nameLabel.sizeToFit()
        
        
        let tapGestureRecognizer = 
        self.contentView.addGestureRecognizer(<#T##gestureRecognizer: UIGestureRecognizer##UIGestureRecognizer#>)
        
        
    }
}
