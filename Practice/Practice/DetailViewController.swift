//
//  DetailViewController.swift
//  Practice
//
//  Created by shen on 2017/2/17.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxSwift

class DetailViewController: ViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.makeRoundedCorners(40)
        
        let url = URL(string: user.imageURL)!
        let request = URLRequest(url: url)
        
        URLSession.shared.rx.data(request: request)
            .map { data in
                UIImage(data: data)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(imageView.rx.image)
            .disposed(by: disposebag)
        
        label.text = user.firstName + " " + user.lastName
        
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
