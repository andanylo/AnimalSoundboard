//
//  AnimalCellModel.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation
import UIKit

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
}
