import UIKit
import Photos

class PictureDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var imageToShow: PHAsset = PHAsset()
    let imageManager = PHImageManager.default()
    
    var options: PHImageRequestOptions{
        
        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.isSynchronous = true
        options.deliveryMode = .opportunistic
        return options
    }
    
    var dateFormatter: DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
    var timeFormatter: DateFormatter{
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .medium
        return timeFormatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        
        setTitle()
        presentImage()
    }
    
    func setTitle(){
        
        guard let imageTimeData = imageToShow.creationDate else { return }
        
        let date = dateFormatter.string(from: imageTimeData)
        let time = timeFormatter.string(from: imageTimeData)
        
        navigationItem.title = date + " " + time
    }
    
    func presentImage(){
        
        imageManager.requestImage(for: imageToShow,
                                  targetSize: CGSize(width: 300, height: 300),
                                  contentMode: .aspectFill,
                                  options: nil,
                                  resultHandler: { (image, _) in
            
            DispatchQueue.main.async{
                self.imageView.image = image
            }
            
        })
        
    }
    

}

//MARK: - @IBAction methods

extension PictureDetailViewController{
    
    @IBAction func pressedShareButton(_ sender: UIBarButtonItem) {
        
    }
    
    
    @IBAction func pressedFavoriteButton(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func pressedDeleteButton(_ sender: UIBarButtonItem) {
        
    }
    
}


extension PictureDetailViewController: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return self.imageView
    }
    
}
