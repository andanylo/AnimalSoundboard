//
//  SoundFetcher.swift
//  AnimalSoundboard
//
//  Created by Danil Andriuschenko on 24.06.2023.
//

import Foundation

///Class that fetches sounds and creates models asynchronically
class FilesFetcher{
    
    ///Struct of the file fetch that includes the file path and image path
    struct FileFetch{
        var name: String
        var filePath: String
        var imagePath: String?
    }
    
    
    ///Returns the file fetch objects from a 'Files' folder
    static func fetchFiles(completion: @escaping([FileFetch]) -> Void){
        Task(priority: .medium) {
            guard let files = Bundle.main.path(forResource: "Files", ofType: nil), var folders = try? FileManager.default.contentsOfDirectory(atPath: files) else{
                completion([])
                return
            }
            
            var result: [FileFetch] = []
            //Sort folders by name
            folders = folders.sorted(by: {$1 > $0})
            for folder in folders{
                let folderPath = files + "/" + folder
                
                //Get contents of the folder to get path of sound file and image file
                guard let contents = try? FileManager.default.contentsOfDirectory(atPath: folderPath),
                    let soundFile = contents.first(where: {
                    let suffix = $0.suffix(4)
                    return suffix == ".mp3" || suffix == ".mp4"
                }) else{
                    continue
                }
                
                let imageFile = contents.first(where: {
                    let suffix = $0.suffix(4)
                    return suffix == ".jpg" || suffix == ".jpeg" || suffix == ".png"
                })
                let imagePath = imageFile == nil ? nil : folderPath + "/" + imageFile!
                
                //Create object
                let fileFetch = FileFetch(name: folder, filePath: folderPath + "/" + soundFile, imagePath: imagePath)
                result.append(fileFetch)
            }
            completion(result)
        }
    }
    
    
}
