//
//  AnimalCellModel.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation
import UIKit
import AVFoundation

///Cell model for a reusable cell
class AnimalCellModel: Hashable{
    static func == (lhs: AnimalCellModel, rhs: AnimalCellModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    ///Identifier that have a unique name in order to identify a model
    var identifier: String = ""
    
    ///Animal info object that has an url and sound manager to play a sound
    var animalInfo: AnimalInfo?
    
    ///View model for animated image
    lazy var animatedImageViewModel: VideoModel? = {
        guard let animalInfo = self.animalInfo, let animatedFilePath = animalInfo.video?.path else{
            return nil
        }
        return VideoModel(animatedFilePath: animatedFilePath, animalInfo: animalInfo)
    }()
    
    var displayedName: String{
        get{
            return animalInfo?.name ?? ""
        }
    }
    
    
    var previewImage: UIImage?
    
    weak var viewController: ViewController?
    
    init(identifier: String){
        self.identifier = identifier
    }
    
    init(animalInfo: AnimalInfo){
        self.identifier = animalInfo.url.path
        self.animalInfo = animalInfo
       
    }
    
    ///Loads and draws an image asynchronically
    func loadImageAsynchronically(completion: @escaping(UIImage?) -> Void){
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageURL = self.animalInfo?.image, let data = try? Data(contentsOf: imageURL) else{
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            
            self.previewImage = image
            
            completion(self.previewImage)
        }
    }
    
    
    ///Copy files to prepare for sharing and return urls to share
    func share(type: AnimalCell.ShareType, completion: @escaping ([URL]) -> Void){
        guard let animalInfo = animalInfo else{
            completion([])
            return
        }
        switch type{
        case .audio:
            if animalInfo.video != nil {
                if let shareURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(animalInfo.name).m4a"){
                    let asset = AVAsset(url: animalInfo.url)
                    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
                    
                    exporter?.outputURL = shareURL
                    exporter?.outputFileType = .m4a
                    
                    exporter?.exportAsynchronously { [weak self] in
                        guard let self = self else{
                            return
                        }
                        completion([shareURL])
                        
                    }
                }
            }
            else{
                if let shareURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(animalInfo.name).mp3"){
                    try? FileManager.default.copyItem(at: animalInfo.url, to: shareURL)
                    completion([shareURL])
                }
            }
        case .video:
            if let shareURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(animalInfo.name).mp4") {
                try? FileManager.default.copyItem(at: animalInfo.url, to: shareURL)
                completion([shareURL])
            }
        }
    }
    
    
    ///Adds to favorites
    func addToFavorites(){
        var favoriteArray: [String] = UserDefaults.standard.array(forKey: "Favorites") as? [String] ?? []
        guard let animalInfo = animalInfo else{
            return
        }
        
        animalInfo.favorite = true
        
        ///Proof check if the name is not already in the favorite array to avoid duplicates
        if !favoriteArray.contains(animalInfo.name){
            favoriteArray.insert(animalInfo.name, at: 0)
        }
        
        UserDefaults.standard.set(favoriteArray, forKey: "Favorites")
        
    }
    
    func removeFromFavorites(){
        var favoriteArray: [String] = UserDefaults.standard.array(forKey: "Favorites") as? [String] ?? []
        guard let animalInfo = animalInfo else{
            return
        }
        
        animalInfo.favorite = false
        
        favoriteArray = favoriteArray.filter({ $0 != animalInfo.name})
        
        UserDefaults.standard.set(favoriteArray, forKey: "Favorites")
    }
}
