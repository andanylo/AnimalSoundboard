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
        //searchbar.showsCancelButton = true
        searchbar.searchTextField.clearButtonMode = .whileEditing
        searchbar.searchTextField.placeholder = "Enter the name of the sound here"
        searchbar.searchBarStyle = .minimal
        searchbar.delegate = self
        searchbar.sizeToFit()
        searchbar.translatesAutoresizingMaskIntoConstraints = false
        return searchbar
    }()
    
    
    var textDidChange: ((String) -> Void)?
    
    
    
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


extension SearchView: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        textDidChange?(searchText)
    }
}
