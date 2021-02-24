import UIKit
import Photos

class PictureDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        
        guard let imageTimeData = imageToShow.creationDate else{
            return
        }
        
        
//        print(dateFormatter.string(from: today))
//        print(timeFormatter.string(from: today))
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


extension PictureDetailViewController: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return self.imageView
    }
    
}
