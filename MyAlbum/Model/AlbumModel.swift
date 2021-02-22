import Foundation
import Photos

class AlbumModel{
    
    var name: String
    var count: Int
    var collection: PHAssetCollection
    
    init(name: String, count: Int, collection: PHAssetCollection) {
        
        self.name = name
        self.count = count
        self.collection = collection
    }
}
