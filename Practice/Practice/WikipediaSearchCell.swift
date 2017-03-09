//
//  WikipediaSearchCell.swift
//  Practice
//
//  Created by shen on 2017/3/8.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit

class WikipediaSearchCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var images: UICollectionView!
    @IBOutlet weak var urlLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.images.register(UINib(nibname: "wikipediaImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
        self.images.register(UINib(nibName: "WikipediaImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")

    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
