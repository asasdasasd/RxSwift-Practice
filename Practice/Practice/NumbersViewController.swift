//
//  NumbersViewController.swift
//  Practice
//
//  Created by shen on 2017/3/6.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NumbersViewController: ViewController {

    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var resultLable: UILabel!
    
    @IBOutlet weak var thirdTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        Observable.combineLatest(firstTextField.rx.text.orEmpty,secondTextField.rx.text.orEmpty,thirdTextField.rx.text.orEmpty){ textValue1, textValue2, textValue3 -> Int in
                return (Int(textValue1) ?? 0) + (Int(textValue2) ?? 0) + (Int(textValue3) ?? 0)
            }
            .map{$0.description}
            .bindTo(resultLable.rx.text)
            .disposed(by: disposebag)
    
        
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
