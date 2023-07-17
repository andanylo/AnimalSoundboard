//
//  SearchView.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 17.07.2023.
//

import Foundation
import UIKit

class SearchView: UIView{
    ///Search bar
    lazy var searchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.showsCancelButton = true
        searchbar.searchBarStyle = .minimal
        searchbar.sizeToFit()
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        return searchbar
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(searchBar)
        
        searchBar.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: searchBar.frame.height).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
}
