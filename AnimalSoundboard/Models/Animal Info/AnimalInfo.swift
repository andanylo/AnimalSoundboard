//
//  AnimalSound.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation

///An animal info class that contains path for a sound, name, image url
class AnimalInfo{
    
    ///Url for a sound
    var url: URL
    
    ///Url for an image
    var image: URL?
    
    ///Url for a video
    var video: URL?
    
    ///Name for a sound
    var name: String
    
    ///Is favorite
    var favorite: Bool
    
    ///Sound manager to play a sound
    lazy var soundManager: SoundManager = {
        return SoundManager(animalInfo: self)
    }()
    
    init(url: URL, image: URL? = nil, video: URL? = nil, favorite: Bool = false){
        self.url = url
        self.image = image
        self.name = url.lastPathComponent
        self.video = video
        self.favorite = favorite
    }
    
    ///Init from filefetch
    init(fileFetch: FilesFetcher.FileFetch){
        self.url = URL(filePath: fileFetch.filePath)
        if let imagePath = fileFetch.imagePath{
            self.image = URL(filePath: imagePath)
        }
        self.name = fileFetch.name
        if let videoPAth = fileFetch.videoPath{
            self.video = URL(filePath: videoPAth)
        }
        if let favoriteArray = UserDefaults.standard.array(forKey: "Favorites") as? [String] {
            self.favorite = favoriteArray.contains(name)
        } else{
            self.favorite = false
        }
        
    }
    
    
}
