//
//  ValidationViewController.swift
//  Practice
//
//  Created by shen on 2017/3/6.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ValidationViewController: ViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var usernameValid: UILabel!
    
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordValid: UILabel!
    
    
    @IBOutlet weak var login: UIButton!
    
    
    @IBAction func Login(_ sender: UIButton) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        usernameValid.text = "Username has to be at least 3 characters"
        
        self.passwordValid.text = "Password has to be at least 3 characters"
        
        let usernameVaildation = username.rx.text.orEmpty
            .map{ $0.characters.count >= 3 }
            .shareReplay(1)
        
        let passwordValidation = password.rx.text.orEmpty
            .map{ $0.characters.count >= 3 }
            .shareReplay(1)
        
        let everythingValid = Observable.combineLatest(usernameVaildation, passwordValidation) { $0 && $1 }
            .shareReplay(1)
        
        usernameVaildation
            .bindTo(password.rx.isEnabled)
            .disposed(by: disposebag)
        usernameVaildation
            .bindTo(usernameValid.rx.isHidden)
            .disposed(by: disposebag)
        
        passwordValidation
            .bindTo(passwordValid.rx.isHidden)
            .disposed(by: disposebag)
        
        everythingValid
            .bindTo(login.rx.isEnabled)
            .disposed(by: disposebag)
        
        login.rx.tap
            .subscribe(onNext: { [weak self] in self?.showAlert() })
            .disposed(by: disposebag)
        
    }
    
    func showAlert() {
        let alertView = UIAlertView(
            title: "Practice",
            message: "This is wonderful",
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        
        alertView.show()
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
