import UIKit
import Photos

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        
        setFlowLayout()
        authorizePhotoAccess()
        
        
        albumCollectionView.reloadData()
    }

    func setFlowLayout(){
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing  = 10
        
        let halfWidth: CGFloat = UIScreen.main.bounds.width / 2.0
        
        flowLayout.estimatedItemSize = CGSize(width: halfWidth - 30, height: 90)
        albumCollectionView.collectionViewLayout = flowLayout
    }
    
    
    func authorizePhotoAccess(){
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근 허가됨")
            self.requestCollection()
            albumCollectionView.reloadData()
            
        case .denied:
            print("접근 불허")
        case .notDetermined:
            print("응답 안 함")
            PHPhotoLibrary.requestAuthorization( { (status) in
                
                switch status{
                case.authorized:
                    print("사용자가 허용함")
                    self.requestCollection()
                    OperationQueue.main.addOperation {
                        self.albumCollectionView.reloadData()
                    }
                    
                case .denied:
                    print("사용자가 불허함")
                default: break
                }
            })
        case .restricted:
            print("접근 제한")
        default: break
        }
        PHPhotoLibrary.shared().register(self)
    }
    
    func requestCollection(){
        
        let cameraRoll: PHFetchResult<PHAssetCollection>
            = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        guard let cameraRollCollection = cameraRoll.firstObject else{
            return
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(in: cameraRollCollection, options: fetchOptions)
    }

}



extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.albumCellIdentifier, for: indexPath) as? AlbumCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        let asset: PHAsset = fetchResult.object(at: indexPath.row)
        

        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.resizeMode = .exact
        
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: 30, height: 30),
                                  contentMode: .aspectFill,
                                  options: options,
                                  resultHandler: { image, _ in
                                    cell.albumImageView?.image = image
                    
                                  })
        
        
        return cell
        
        
        
    }
    
    
    
    
}

extension AlbumViewController: PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult) else{
            return
        }
        
        fetchResult = changes.fetchResultAfterChanges
        
        OperationQueue.main.addOperation {
            self.albumCollectionView.reloadData()
        }
    }
    

    
}
