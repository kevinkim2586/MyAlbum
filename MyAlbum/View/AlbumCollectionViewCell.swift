import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var albumTotalNumberOfPicturesLabel: UILabel!
    
    
    // When we dequeue are cell, we could just call this public function
    // instead of having to access each IBOutlet directly
    
    public func configure(image: UIImage, albumName: String, numberOfPics: Int ){
        albumImageView.image = image
        albumNameLabel.text = albumName
        albumTotalNumberOfPicturesLabel.text = String(format: "%d", numberOfPics)
    }
    
    
}
