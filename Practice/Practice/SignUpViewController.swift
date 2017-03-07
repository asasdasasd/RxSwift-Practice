//
//  SignUpViewController.swift
//  Practice
//
//  Created by shen on 2017/3/7.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit

class SignUpViewController: ViewController {
    @IBOutlet weak var username: UITextField!

    @IBOutlet weak var password: UITextField!
   
    @IBOutlet weak var passwordrepeat: UITextField!
 
    
    @IBOutlet weak var usernamevalidation: UILabel!
    
    @IBOutlet weak var passwordvalidation: UILabel!
    
    @IBOutlet weak var passwordrepeatvalidation: UILabel!
    @IBOutlet weak var signup: UIButton!
    
    @IBOutlet weak var indecatior: UIActivityIndicatorView!
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
