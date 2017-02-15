//
//  PartialUpdatesViewController.swift
//  Practice
//
//  Created by asasdasasd on 2017/2/15.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

let generateCustomSize = true
let runAutomatically = false
let useAnimatedUpdateForCollectionView = false


class PartialUpdatesViewController: UIViewController {

    @IBOutlet weak var reloadTableViewOutlet: UITableView!
    @IBOutlet weak var partialUpdatesTableViewOutlet: UITableView!
    @IBOutlet weak var partialUpdatesCollectionViewOutlet: UICollectionView!
    
    var timer: Foundation.Timer? = nil
    
    static let initalValue: [AnimatableSectionModel<String, Int>] = [
        NumberSection(model: "section 1", items: [1, 2, 3])
    
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




























