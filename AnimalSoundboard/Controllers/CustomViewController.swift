//
//  CustomViewController.swift
//  Meme Soundboard
//
//  Created by Danil Andriuschenko on 26.08.2022.
//  Copyright © 2022 Danil Andriuschenko. All rights reserved.
//

import Foundation
import UIKit
struct CustomAction{
    var title: String!
    var subtitle: String?
    var isSelected: Bool = false
    var imageName: String?
    var didClick: ((CustomPicker, CustomActionCell) -> Void)?
    var style: CustomActionStyle = .defaultStyle

}
enum CustomActionStyle{
    case defaultStyle
    case destructionStyle
    case transitionStyle
    case checkmarkStyle
    case backStyle
}
class CustomViewController: UIViewController{
    var tableView: UITableView?
    var titleString: String?
    
    
    var actions: [[CustomAction]]!
    
    weak var parentPicker: CustomPicker?
    override func viewDidLoad() {

        tableView = UITableView()
        tableView?.backgroundColor = .clear//DataStorage.shared.SettingsValue.currentMode == .white ? UIColor.white : UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
        tableView?.sectionFooterHeight = 0
        tableView?.sectionHeaderHeight = 0
        tableView?.register(CustomActionCell.self, forCellReuseIdentifier: "CustomCellAction")
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        //tableView?.isScrollEnabled = false
        
        self.view.addSubview(tableView!)
        tableView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView?.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView?.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorColor = DataStorage.shared.SettingsValue.currentMode == .white ? .lightGray : .black

        if #available(iOS 15.0, *) {
            tableView?.sectionHeaderTopPadding = 0
        }
    }
   
    func setTheme(){
        tableView?.separatorColor = DataStorage.shared.SettingsValue.currentMode == .white ? .lightGray : .black
        tableView?.reloadData()

    }
    override func viewDidAppear(_ animated: Bool) {
        
        tableView?.bounces = tableView!.contentSize.height > self.view.frame.size.height ? true : false
    }
}

extension CustomViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return actions[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return actions.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellAction") as? CustomActionCell{
            cell.start(customAction: actions[indexPath.section][indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return actions[indexPath.section][indexPath.row].subtitle == nil ? 44 : 54
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section > 0 ? 8 : 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section <= 0{
            let emptyView = UIView()
            emptyView.backgroundColor = .clear
        }
        let view = UIView()
        view.backgroundColor = DataStorage.shared.SettingsValue.currentMode == .dark ? .black : .lightGray
        view.alpha = 0.3
        view.frame.size.height = 8
        
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .clear
        return view//UIView(frame: CGRect.zero)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CustomActionCell, let picker = self.parentPicker{
            if cell.customAction?.style == .defaultStyle || cell.customAction?.style == .destructionStyle{
                picker.dismiss(animated: true) {
                    cell.customAction?.didClick?(picker, cell)
                }
            }
            else if cell.customAction?.style == .backStyle{
                parentPicker?.popViewController()
            }
            else if cell.customAction?.style != .checkmarkStyle{
                cell.customAction?.didClick?(picker, cell)
            }
            else{
                cell.customAction?.didClick?(picker, cell)
                tableView.reloadData()
                picker.dismiss(animated: true)
                
            }
        }
    }
}
