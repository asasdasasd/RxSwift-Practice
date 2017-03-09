//
//  CollectionViewImageCell.swift
//  Practice
//
//  Created by shen on 2017/3/8.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


typealias Image = UIImage

enum DownloadableImage{
    case content(image:Image)
    case offlinePlaceholder
    
}


class CollectionViewImageCell: UICollectionViewCell {

    @IBOutlet weak var imageview: UIImageView!
   
    var disposebag: DisposeBag?
    
    var downloadableImage: Observable<DownloadableImage>?{
        didSet{
            let disposeBag = DisposeBag()
            
            self.downloadableImage?
                .asDriver(onErrorJustReturn: DownloadableImage.offlinePlaceholder)
                .drive(imageview.rx.downloadableImageAnimated(kCATransitionFade))
                .disposed(by: disposeBag)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        downloadableImage = nil
        disposebag = nil
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}


extension Reactive where Base: UIImageView {
    
    var downloadableImage: UIBindingObserver<Base, DownloadableImage>{
        return downloadableImageAnimated(nil)
    }
    
    func downloadableImageAnimated(_ transitionType:String?) -> UIBindingObserver<Base, DownloadableImage> {
        return UIBindingObserver(UIElement: base) { imageView, image in
            for subview in imageView.subviews {
                subview.removeFromSuperview()
            }
            switch image {
            case .content(let image):
                (imageView as UIImageView).rx.image.on(.next(image))
            case .offlinePlaceholder:
                let label = UILabel(frame: imageView.bounds)
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 35)
                label.text = "⚠️"
                imageView.addSubview(label)
            }
        }
    }
}
