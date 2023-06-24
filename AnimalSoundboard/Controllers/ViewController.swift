//
//  ViewController.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 14.06.2023.
//

import UIKit

class ViewController: UIViewController {

    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Hello"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.widthAnchor.constraint(equalToConstant: label.frame.size.width).isActive = true
        label.heightAnchor.constraint(equalToConstant: label.frame.size.height).isActive = true
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }


}

