//
//  SimpleTableViewSectionedController.swift
//  Practice
//
//  Created by shen on 2017/2/14.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class SimpleTableViewSectionedController: ViewController ,UITableViewDelegate{

    @IBOutlet weak var tableview: UITableView!
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = self.dataSource
        
        let items = Observable.just([
            SectionModel(model:"First section", items:[
                1.0,
                2.0,
                3.0
                ]),
            SectionModel(model:"Seconde section", items:[
                1.0,
                2.0,
                3.0
                ]),
            SectionModel(model:"Third section", items:[
                1.0,
                2.0,
                3.0
                ]),
            ])
        
        dataSource.configureCell = {(_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(element) @ row \(indexPath.row)"
            return cell
        }
        
        items
            .bindTo(tableview.rx.items(dataSource: dataSource))
            .disposed(by: disposebag)
        
        tableview.rx
            .itemSelected
            .map{ indexPath in
                return (indexPath, dataSource[indexPath])
            }
            .subscribe(onNext: { indexPath, model in
                print("tapped \(model) @ \(indexPath)")
            })
            .disposed(by: disposebag)
        
        tableview.rx
            .setDelegate(self)
            .disposed(by: disposebag)
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
            let label = UILabel.init(frame: CGRect.zero)
            label.text = dataSource[section].model
            return label
        }
        
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
            return .none
        }
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
