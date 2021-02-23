import UIKit
import Photos

enum Mode{
    case view, select
}

class PictureListViewController: UIViewController {
    
    @IBOutlet weak var pictureCollectionView: UICollectionView!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var orderButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    
    var album: AlbumModel = AlbumModel(name: "", count: 0, collection: PHAssetCollection())
    var numberOfPictures: Int = 0
    var albumName: String = ""

    let imageManager = PHImageManager.default()
    var imageArray = [PHAsset]()
    
    var selectedIndexPath: [IndexPath : Bool] = [:]
    
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
    
    
    var currentMode: Mode = .view{
        
        didSet{
            switch currentMode{
            case .view:
                selectButton.title = "선택"
                trashButton.isEnabled = false
                //pictureCollectionView.reloadData()
                pictureCollectionView.allowsMultipleSelection = false
                
            case .select:
                selectButton.title = "취소"
                trashButton.isEnabled = true
                pictureCollectionView.allowsMultipleSelection = true
            }
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pictureCollectionView.delegate = self
        pictureCollectionView.dataSource = self
        setFlowLayout()
        grabPhotos()
        pictureCollectionView.reloadData()
        
        trashButton.isEnabled = false
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PictureListCollectionViewCell else{
            return
        }
     
        
        switch currentMode{
        
        case .view:
            
            let selectedItem = imageArray[indexPath.item]
            
        case .select:
            cell.pictureImageView.alpha = 0.5
            selectedIndexPath[indexPath] = true
        
        
        }
     
//        if cell.isSelected == true {
//            cell.pictureImageView.alpha = 0
//        } else{
//            cell.pictureImageView.alpha = 0.5
//        }
        
        //cell.pictureImageView.layer.borderWidth = 3
        //cell.pictureImageView.layer.borderColor = UIColor.black.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if currentMode == .select{
            selectedIndexPath[indexPath] = false
        }
    }
    
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

//MARK: - @IBAction Methods

extension PictureListViewController{
    
    @IBAction func pressedSelectButton(_ sender: UIBarButtonItem) {

        currentMode = currentMode == .view ? .select : .view
        
        
    }
    
    
    
    @IBAction func pressedShareButton(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func pressedOrderButton(_ sender: UIBarButtonItem) {
        imageArray.reverse()
        
        if orderButton.title == "최신순"{
            orderButton.title = "과거순"
        } else{
            orderButton.title = "최신순"
        }
        pictureCollectionView.reloadData()
    }
    
    @IBAction func pressedTrashButton(_ sender: UIBarButtonItem) {
        
        var deleteNeededIndexPath: [IndexPath] = []
        
        for (key,value) in selectedIndexPath{
            
            if value == true{
                deleteNeededIndexPath.append(key)
            }
        }
        
        for i in deleteNeededIndexPath.sorted(by: { $0.item > $1.item }){
            imageArray.remove(at: i.item)
        }

        pictureCollectionView.deleteItems(at: deleteNeededIndexPath)
        selectedIndexPath.removeAll()
    }
    
    
}

//MARK: - UIActivityViewController

extension PictureListViewController{
    
    func showShareSheet(){
        
    }
    
}
