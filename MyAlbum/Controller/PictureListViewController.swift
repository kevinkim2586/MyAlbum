import UIKit
import Photos

class PictureListViewController: UIViewController {
    
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    
    let pictureCollection: PHAssetCollection = .init()
    
    var album: AlbumModel = AlbumModel(name: "", count: 0, collection: PHAssetCollection())
    
    
    var fetchResult: PHFetchResult<PHAsset> = PHFetchResult()
    let imageManager = PHImageManager.default()
    var numberOfPictures: Int = 0
    var albumName: String = ""
    
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pictureCollectionView.delegate = self
        pictureCollectionView.dataSource = self
        setFlowLayout()
        grabPhotos()
        
       
        
       
        

        pictureCollectionView.reloadData()
    }
    
    func grabPhotos(){
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .opportunistic
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        
        
        
        
        let albumCollection = album.collection
        let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: albumCollection, options: fetchOptions)
        

        for i in 0..<album.count{
            
            imageManager.requestImage(for: albumCollection  ,
                                      targetSize: CGSize(width: 300, height: 300),
                                      contentMode: .aspectFill,
                                      options: requestOptions,
                                      resultHandler:
                                        { image, _ in
                                            
                                            self.imageArray.append(image!)
                                        
                                      })
            
        }
        pictureCollectionView.reloadData()
        
        
        
        
    }
    

    func setFlowLayout(){
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing  = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.itemSize = CGSize(width: 180, height: 220)
        
        pictureCollectionView.collectionViewLayout = flowLayout
    }

    
    

    

}


extension PictureListViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = pictureCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.pictureCellIdentifier, for: indexPath) as? PictureListCollectionViewCell else{
            
            return UICollectionViewCell()
        }
        
        cell.pictureImageView.image = imageArray[indexPath.row]
        
        
        return cell
    }
    
    
    
    
    
    
}
