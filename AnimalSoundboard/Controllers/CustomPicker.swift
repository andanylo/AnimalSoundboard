//
//  CustomPicker.swift
//  Meme Soundboard
//
//  Created by Danil Andriuschenko on 13.06.2020.
//  Copyright © 2020 Danil Andriuschenko. All rights reserved.
//

import Foundation
import UIKit

class CustomPicker: UIViewController{
  
    
    var heightAnchor:NSLayoutConstraint?
    var actions: [[CustomAction]]?{
        get{
            return currentViewController?.actions
        }
    }
    
    var sourceFrame: CGRect?
    var mainView: CustomPickerView!
    private var NavController: UINavigationController?
    var currentViewController: CustomViewController?{
        get{
            return NavController?.topViewController as? CustomViewController
        }
    }
    
    
    var mainViewXPosition: CustomPickerView.CustomPickerViewXMode?
    var mainViewYPosition: CustomPickerView.CustomPickerViewYMode?
 
    init(title: String, actions: [[CustomAction]], sourceFrame: CGRect?) {
        super.init(nibName: nil, bundle: nil)
        let newViewController = CustomViewController()
        newViewController.actions = actions
        newViewController.titleString = title
        newViewController.parentPicker = self
        
        mainView = CustomPickerView(actions: actions)
        self.sourceFrame = sourceFrame ?? CGRect.zero
        
        self.NavController = UINavigationController(rootViewController: newViewController)
        self.NavController?.setNavigationBarHidden(true, animated: false)
        self.NavController?.view.backgroundColor = .clear
        self.NavController?.view.translatesAutoresizingMaskIntoConstraints = false
        
       
    }
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        if #available(iOS 13.0, *) {
//            if self.traitCollection.userInterfaceStyle == .dark{
//                DataStorage.shared.SettingsValue.changeTheme(theme: .dark)
//            }
//            else{
//                DataStorage.shared.SettingsValue.changeTheme(theme: .white)
//            }
//        }
//        setTheme()
//    }
//
    ///Presents new view controller with new actions
    func presentOtherController(title: String, actions: [[CustomAction]]){
        
        let backButtonAction = CustomAction(title: "Back", subtitle: nil, isSelected: false, imageName: "arrow.left", didClick: nil, style: .backStyle)
        
        var newActions = actions
        newActions.append([backButtonAction])
        
        let newViewController = CustomViewController()
        newViewController.titleString = title
        newViewController.actions = newActions
        newViewController.parentPicker = self
        
        animateNewContent {
            
            
            self.mainView.actions = newViewController.actions
            self.mainView.frame.size.height = self.mainView.sizeForController(actions: newViewController.actions)
            self.heightAnchor?.constant = self.mainView.frame.size.height
            
            self.setConstraintsForMainView()
            self.view.layoutIfNeeded()
            
            self.NavController?.pushViewController(newViewController, animated: false)
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for i in touches{
            let location = i.location(in: self.view)
            
            if let viewTouch = self.view.hitTest(location, with: nil){
                if viewTouch.restorationIdentifier == "background" || viewTouch === stickView{
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    @objc func didCancel(sender: UIButton){
        sender.backgroundColor = UIColor.white
        self.dismiss(animated: true, completion: nil)
    }
    @objc func touchDown(sender: UIButton){
        sender.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    }
    @objc func touchUpOut(sender: UIButton){
        sender.backgroundColor = UIColor.white
    }
    func setTheme(){
        currentViewController?.setTheme()
        let barTintColor = UIColor.white
        
        if #available(iOS 15.0, *) {
            NavController?.navigationBar.standardAppearance.backgroundColor = barTintColor
            NavController?.navigationBar.scrollEdgeAppearance?.backgroundColor = barTintColor
        }
        else{
            NavController?.navigationBar.barTintColor =  barTintColor
        }
        
        self.mainView.changeTheme()
        
        NavController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        NavController?.navigationBar.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        NavController?.addCustomBottomLine(color: currentViewController?.tableView?.separatorColor ?? UIColor.white)
        
    }
    
    
    ///Animates new content (when new view controller is pushed)
    private func animateNewContent(didHide: @escaping () -> Void){

        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut]) {
            self.mainView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        } completion: { _ in
            didHide()
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseOut], animations: {
                self.mainView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
            
        }

    }

    public var priorityWidth: CGFloat?
    
    ///Pop ups the navigation view top controller
    func popViewController(){
        
        animateNewContent {
            self.NavController?.popViewController(animated: false)
            
            self.mainView.actions = self.currentViewController?.actions ?? [[]]
            self.mainView.frame.size.height = self.mainView.sizeForController(actions: self.mainView.actions)
            self.heightAnchor?.constant = self.mainView.frame.size.height
            
            self.setConstraintsForMainView()
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    //Change positions if needed
    func setConstraintsForMainView(){
        mainView.removeFromSuperview()
        
        
        let height = mainView.sizeForController(actions: mainView.actions)
        let x = calculateCustomPickerViewXPosition(senderFrame: self.sourceFrame ?? CGRect.zero, customPickerViewWidth: mainView.bounds.width)
        let y = calculateCustomPickerViewYPosition(senderFrame: self.sourceFrame ?? CGRect.zero, customPickerViewHeight: height)
        

        self.mainViewXPosition = x
        self.mainViewYPosition = y
        
        
        
        self.view.addSubview(mainView)
        
        switch x{
        case .left:
            mainView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        case .right:
            mainView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        case .center:
            mainView.centerXAnchor.constraint(equalTo: stickView.centerXAnchor).isActive = true
            
        }
        
        switch y{
        case let .bottom(maxHeight):
            
            
            mainView.topAnchor.constraint(equalTo: stickView.bottomAnchor).isActive = true
            heightAnchor?.constant = min(height, maxHeight ?? height)
        case let .top(maxHeight):
            
            heightAnchor?.constant = min(height, maxHeight ?? height)
            mainView.bottomAnchor.constraint(equalTo: stickView.topAnchor).isActive = true
        }
     
    }
    
    private let stickView = UIView()
    
    override func viewDidLoad() {
       
        super.viewDidLoad()

        self.view.restorationIdentifier = "background"
        
        stickView.backgroundColor = .clear
        stickView.frame = sourceFrame ?? CGRect.zero
        self.view.addSubview(stickView)
        
        self.view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        let width: CGFloat = priorityWidth == nil ? 200 : priorityWidth!
        
        
        mainView.frame.origin = CGPoint.zero
        mainView.frame.size = CGSize(width: width, height: mainView.sizeForController(actions: mainView.actions))
        
        mainView.widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor = mainView.heightAnchor.constraint(equalToConstant: mainView.sizeForController(actions: mainView.actions))
        heightAnchor?.isActive = true
        
        
        
        NavController?.view.layer.cornerRadius = mainView.layer.cornerRadius
        NavController?.view.clipsToBounds = true
        
        
        
        self.setConstraintsForMainView()
       
        mainView.addSubview(NavController!.view)
        NavController?.view.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        NavController?.view.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        NavController?.view.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        NavController?.view.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        
        
    }
    
    
    ///Calculates which Y position should be for custom picker and maximum height if needed
    /// > Warning:  Bottom is default
    ///- Returns: Custom picker view Y position
    func calculateCustomPickerViewYPosition(senderFrame: CGRect, customPickerViewHeight: CGFloat) -> CustomPickerView.CustomPickerViewYMode{
        
        if (senderFrame.maxY + customPickerViewHeight) > self.view.frame.size.height{
            //If the sender if above half the screen, place on bottom with limited size
            if (senderFrame.maxY < self.view.frame.size.height / 2){
                return .bottom(self.view.frame.size.height - senderFrame.maxY)
            }
            //Else place the customPicker view on top since it doesnt fit
            return .top(senderFrame.minY)
        }
        else if (senderFrame.minY - customPickerViewHeight) < 0{
            
            //If the sender if below half the screen, place on top with limited size
            if (senderFrame.minY > self.view.frame.height / 2){
                return .top(senderFrame.minY)
            }
            //Else place the customPicker view on bottom since it doesnt fit
            return .bottom(self.view.frame.size.height - senderFrame.maxY)
        }
        
        //bottom is default, if the custom view is placed freely
        return .bottom(nil)
    }
    ///Calculates which X position should be for custom picker.
    ///Left side, right side of the screen or center of source
    /// - Returns: Custom picker view X position
    func calculateCustomPickerViewXPosition(senderFrame: CGRect, customPickerViewWidth: CGFloat) -> CustomPickerView.CustomPickerViewXMode{
        
        if (senderFrame.midX + customPickerViewWidth / 2) > self.view.frame.size.width{
            return .right
        }
        else if (senderFrame.midX - customPickerViewWidth / 2) < 0{
            return .left
        }
        return .center
    }
    
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}



extension UINavigationController
{
    func addCustomBottomLine(color:UIColor)
    {
        //Hiding Default Line and Shadow
        navigationBar.setValue(true, forKey: "hidesShadow")
    
        //Creating New line
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width:0, height: 0.25))
        lineView.backgroundColor = color
        navigationBar.addSubview(lineView)
    
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 0.25).isActive = true
        lineView.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor).isActive = true
        lineView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
    }
}
