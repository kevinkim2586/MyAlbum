import UIKit
import Photos

class AlbumViewController: UIViewController {
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    var albumModel: [AlbumModel] = [AlbumModel]()
    
    var fetchResult: [PHFetchResult<PHAsset>] = []
    let imageManager: PHImageManager = PHImageManager.default()
    var fetchOptions: PHFetchOptions{

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        albumCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        
        authorizePhotoAccess()
        setFlowLayout()
        albumCollectionView.reloadData()
    }

    func setFlowLayout(){
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing  = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.itemSize = CGSize(width: 180, height: 220)
        
        // Applying flowLayout to my CollectionView
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
        
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        let favoriteList = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
        let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        
        [cameraRoll, favoriteList, albumList].forEach{
            
            $0.enumerateObjects { collection, _, _ in
                
                let album = collection
                let albumTitle : String = album.localizedTitle!
                
                let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: album, options: self.fetchOptions)
                let albumCount = assetsFetchResult.count
                
                let newAlbum = AlbumModel(name:albumTitle, count: albumCount, collection:album)

                self.albumModel.append(newAlbum)
            }
        }
    
        addAlbums(collection: cameraRoll)
        addAlbums(collection: favoriteList)
        addAlbums(collection: albumList)
    }
    
    func addAlbums(collection : PHFetchResult<PHAssetCollection>){
        
        for i in 0 ..< collection.count {
            let collection = collection.object(at: i)
            self.fetchResult.append(PHAsset.fetchAssets(in: collection, options: fetchOptions))
        }
    }
    

}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let pictureVC = self.storyboard?.instantiateViewController(identifier: "pictureVC") as? PictureListViewController else{
            return
        }
        
        pictureVC.album = albumModel[indexPath.row]
        pictureVC.title = albumModel[indexPath.row].name
        
        self.show(pictureVC, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.albumCellIdentifier, for: indexPath) as? AlbumCollectionViewCell else{
            return UICollectionViewCell()
        }
        
        guard let asset = fetchResult[indexPath.row].firstObject else {
            return UICollectionViewCell()
        }
        
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.resizeMode = .exact
    
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: 300, height: 300),
                                  contentMode: .aspectFill,
                                  options: nil) { (image, _) in
                                  cell.albumImageView?.image = image
            
            
        }
        
        cell.albumNameLabel.text = albumModel[indexPath.row].name
        cell.albumTotalNumberOfPicturesLabel.text = String(format: "%d", albumModel[indexPath.row].count)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumModel.count
    }
}

//MARK: -

extension AlbumViewController: PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
//        for i in 0..<self.fetchResult.count {
//            if let changes = changeInstance.changeDetails(for: fetchResult[i]) {
//                fetchResult[i] = changes.fetchResultAfterChanges
//            }
//        }
//
//        OperationQueue.main.addOperation {
//            self.albumCollectionView.reloadData()
        //        }
        
        
        for i in 0..<self.albumModel.count{
            
            if let changes = changeInstance.changeDetails(for: albumModel[i].collection){
                
                if let changesMade = changes.objectAfterChanges{
                    albumModel[i].collection = changesMade
                }
                OperationQueue.main.addOperation {
                    self.albumCollectionView.reloadSections(IndexSet(0...0))
                }
                
            }
            OperationQueue.main.addOperation {
                self.albumCollectionView.reloadSections(IndexSet(0...0))
            }
        }
        

        
        
        
    }
}
