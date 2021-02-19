import UIKit
import Photos


class AlbumModel{
    
    let name: String
    let count: Int
    let collection: PHAssetCollection
    
    
    init(name: String, count: Int, collection: PHAssetCollection) {
        
        self.name = name
        self.count = count
        self.collection = collection
    }
}



class AlbumViewController: UIViewController {
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    var albumModel: [AlbumModel] = [AlbumModel]()
    
    var fetchResult: [PHFetchResult<PHAsset>] = []
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    var fetchOptions: PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    
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
        flowLayout.itemSize = CGSize(width: 180, height: 220)
 
        
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing  = 10
        

        
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
            
            $0.enumerateObjects { collection, index, stop in
                
                let album = collection
                // PHAssetCollection 의 localizedTitle 을 이용해 앨범 타이틀 가져오기
                let albumTitle : String = album.localizedTitle!
                // 이미지만 가져오도록 옵션 설정
                let fetchOptions2 = PHFetchOptions()
                fetchOptions2.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions2)
                // PHFetchResult 의 count 을 이용해 앨범 사진 갯수 가져오기
                let albumCount = assetsFetchResult.count
                // 저장
                let newAlbum = AlbumModel(name:albumTitle, count: albumCount, collection:album)
                print(newAlbum.name)
                print(newAlbum.count)
                //앨범 정보 추가
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



extension AlbumViewController: UICollectionViewDelegateFlowLayout{
    
    // Here, we are able to specify what the margin, padding is of each cell
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 180, height: 220)
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: (view.frame.size.width / 3)-3,
//                      height: (view.frame.size.width / 3)-3)
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
}


extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("didSelectItem activated.")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return albumModel.count
        //return fetchResult.count
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
    
    
}









extension AlbumViewController: PHPhotoLibraryChangeObserver{
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        for i in 0..<self.fetchResult.count {
            if let changes = changeInstance.changeDetails(for: fetchResult[i]) {
                fetchResult[i] = changes.fetchResultAfterChanges
            }
        }
        
        OperationQueue.main.addOperation {
            self.albumCollectionView.reloadData()
        }
    }
    

    
}
