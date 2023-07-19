//
//  CustomActionCell.swift
//  Meme Soundboard
//
//  Created by Danil Andriuschenko on 26.08.2022.
//  Copyright © 2022 Danil Andriuschenko. All rights reserved.
//

import Foundation
import UIKit
class CustomActionCell: UITableViewCell{
    var customAction: CustomAction?
    
    var titleLabel = UILabel()
    var subtitleLabel = UILabel()
    
    var checkmarkImageView: UIImageView?
    var iconImageView: UIImageView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.accessoryType = .none
        self.contentView.subviews.forEach({$0.removeFromSuperview()})
        
        titleLabel.removeFromSuperview()
        subtitleLabel.removeFromSuperview()
        checkmarkImageView?.removeFromSuperview()
        iconImageView?.removeFromSuperview()
    
    }
    func start(customAction: CustomAction){
        self.separatorInset = UIEdgeInsets.zero
        self.selectionStyle = .none
        
        self.customAction = customAction
        self.backgroundColor = .clear
        
       
        titleLabel = UILabel()
        titleLabel.text = customAction.title
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        titleLabel.textAlignment = .left
        titleLabel.textColor = customAction.style == .destructionStyle ? UIColor.red : (DataStorage.shared.SettingsValue.currentMode == .white ? UIColor.black : UIColor.white)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        

        
        if customAction.imageName != nil{
            iconImageView = UIImageView()
            iconImageView?.translatesAutoresizingMaskIntoConstraints = false
            iconImageView?.contentMode = .scaleAspectFit
            iconImageView?.image = UIImage(named: customAction.imageName!)?.withRenderingMode(.alwaysTemplate)
            iconImageView?.tintColor = customAction.style == .destructionStyle ? .red : (DataStorage.shared.SettingsValue.currentMode == .dark ? UIColor.white : UIColor.black)
            self.contentView.addSubview(iconImageView!)
            
            iconImageView?.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            iconImageView?.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
            iconImageView?.widthAnchor.constraint(equalToConstant: 18).isActive = true
            
        }
        
        if customAction.isSelected {
            checkmarkImageView = UIImageView()
            checkmarkImageView?.translatesAutoresizingMaskIntoConstraints = false
            checkmarkImageView?.contentMode = .scaleAspectFit
            checkmarkImageView?.image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
            checkmarkImageView?.tintColor =  (DataStorage.shared.SettingsValue.currentMode == .dark ? UIColor.white : UIColor.black)
            self.contentView.addSubview(checkmarkImageView!)
            
            checkmarkImageView?.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
            checkmarkImageView?.widthAnchor.constraint(equalToConstant: 15).isActive = true
            checkmarkImageView?.heightAnchor.constraint(equalToConstant: 15).isActive = true
            checkmarkImageView?.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        }
        if customAction.style == .transitionStyle{
            self.accessoryType = .disclosureIndicator
        }
        
        
        
        if customAction.subtitle != nil{
            subtitleLabel = UILabel()
            subtitleLabel.text = customAction.subtitle
            subtitleLabel.font = UIFont.systemFont(ofSize: 9, weight: .light)
            subtitleLabel.textColor = DataStorage.shared.SettingsValue.currentMode == .white ? UIColor.black : UIColor.white
            subtitleLabel.lineBreakMode = .byWordWrapping
            subtitleLabel.numberOfLines = 0
            subtitleLabel.textAlignment = .left
            

            let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.spacing = 2
            self.contentView.addSubview(stackView)
            stackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: customAction.style == .checkmarkStyle ? 40 : 15).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        }
        else{
            self.contentView.addSubview(titleLabel)
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: customAction.style == .checkmarkStyle ? 40 : 15).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        }
    
    }
}
