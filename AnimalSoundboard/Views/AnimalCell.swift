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
    }
    var animalCellModel: AnimalCellModel?
    
    ///Name label
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    func start(with: AnimalCellModel){
        self.animalCellModel = with
        
        self.contentView.backgroundColor = .black
        
        
        if nameLabel.superview == nil{
            self.contentView.addSubview(nameLabel)
            
            nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        }
        
        nameLabel.text = animalCellModel?.displayedName
        nameLabel.sizeToFit()
    }
}
