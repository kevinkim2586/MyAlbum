import UIKit
import Photos

class PictureListViewController: UIViewController {
    
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    
    var album: AlbumModel = AlbumModel(name: "", count: 0, collection: PHAssetCollection())
    var numberOfPictures: Int = 0
    var albumName: String = ""

    let imageManager = PHImageManager.default()
    var imageArray = [PHAsset]()
    
    var options: PHImageRequestOptions{
        
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.isSynchronous = true
        options.deliveryMode = .opportunistic
        return options
    }
    
    var fetchOptions: PHFetchOptions{
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pictureCollectionView.delegate = self
        pictureCollectionView.dataSource = self
        setFlowLayout()
        grabPhotos()
        pictureCollectionView.reloadData()
    }
    
    func setFlowLayout(){
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing  = 1
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.itemSize = CGSize(width: 180, height: 220)
        
        pictureCollectionView.collectionViewLayout = flowLayout
    }
    
    func grabPhotos(){

        
        
        let albumCollection = album.collection
        let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: albumCollection, options: fetchOptions)
        
        numberOfPictures = assetsFetchResult.count
        
        assetsFetchResult.enumerateObjects { (object, _, _) in
            self.imageArray.append(object)
        }
        pictureCollectionView.reloadData()
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension PictureListViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        guard let cell = pictureCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.pictureCellIdentifier, for: indexPath) as? PictureListCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        
        
        let asset = imageArray[indexPath.row]
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: options, resultHandler: {
            (image, _ ) in
            
            DispatchQueue.main.async {
                cell.pictureImageView?.image = image
            }
        })
        return cell
    }  
}
