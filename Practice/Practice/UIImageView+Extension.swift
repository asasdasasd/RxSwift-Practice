//
//  UIImageView+Extension.swift
//  Practice
//
//  Created by shen on 2017/2/17.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func makeRoundedCorners(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func makeRoundedCorners() {
        self.makeRoundedCorners(self.frame.size.width / 2)
    }
}
