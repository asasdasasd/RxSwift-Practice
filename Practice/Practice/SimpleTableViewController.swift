//
//  SimpleTableViewController.swift
//  Practice
//
//  Created by asasdasasd on 2017/2/9.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SimpleTableViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let items = Observable.just((0..<20).map({"\($0)"}))
        
        items
            .bindTo(tableview.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)){ (row,element,cell) in
            cell.textLabel?.text = "\(element) row --- \(row)"
            }
            .disposed(by: DisposeBag())
        
        tableview.rx
            .modelSelected(String.self)
            .subscribe(onNext: { value in
            
                print("Tapped \(value)")
            })
            .disposed(by: DisposeBag())
        
        tableview.rx
        .itemAccessoryButtonTapped
        .subscribe(onNext: { (indexPath) in
            print("Tapped Detail \(indexPath.section) \(indexPath.row)")
        })
        .disposed(by: DisposeBag())
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
