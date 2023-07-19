//
//  CustomPickerView.swift
//  Meme Soundboard
//
//  Created by Danil Andriuschenko on 25.08.2022.
//  Copyright © 2022 Danil Andriuschenko. All rights reserved.
//

import Foundation
import UIKit


///Custom Picker main view for Custom Picker which contains Navigation View Controller and other child controllers
class CustomPickerView: UIView{
    
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        return blurView
    }()
    var actions: [[CustomAction]] = []
    
    /// Calculates the height of the view including headers and cell sizes based on current actions
    /// > Warning:  Maximum height is 350 pixels
    /// - Parameters: Custom actions
    /// - Returns: The height of the child view controller
    func sizeForController(actions: [[CustomAction]]) -> CGFloat{
        var numberOfActions = 0
        actions.forEach({$0.forEach({_ in numberOfActions += 1})})
        
        var sizeOfCells: CGFloat = 0.0
        
        for array in actions {
            for action in array{
                sizeOfCells += action.subtitle == nil ? 44 : 54
            }
        }
        
        
        let x = sizeOfCells + max(CGFloat(actions.count - 1), 0.0) * 8.0
        let y = CGFloat(350)
        return min(x, y)
    }
    
    
    
    
    init(actions: [[CustomAction]]){
        super.init(frame: CGRect.zero)
        self.actions = actions
        
        self.backgroundColor = .clear
       
        
        
        self.clipsToBounds = false
        
        self.layer.cornerRadius = 15
        self.layer.shadowRadius = 7
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize.zero
        
        self.addSubview(blurEffectView)
        blurEffectView.clipsToBounds = true
        
        blurEffectView.layer.cornerRadius = 15
        
        blurEffectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        blurEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        blurEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        blurEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        
    }
    
    
    ///Changes the theme of the view
    func changeTheme(){
       
        blurEffectView.effect = UIBlurEffect(style: .extraLight)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    ///Y Position with maximum height if needed
    enum CustomPickerViewYMode{
        case top(CGFloat?)
        case bottom(CGFloat?)
        
    }
    ///X Position
    enum CustomPickerViewXMode{
        case left
        case right
        case center
    }
}
