//
//  LoginViewController.swift
//  Ai-alearn
//
//  Created by NDPhu on 8/14/19.
//  Copyright © 2019 NDPhu. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Alamofire
import SVProgressHUD
class LoginViewController: UIViewController {
    var codeCom: CompanyCode?
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var idTf: SkyFloatingLabelTextField!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        idTf.delegate = self
        password.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        password.text = ""
        idTf.text = ""
    }
    
    @IBAction func login(_ sender: UIButton) {
        login()
    }
    func login() {
        guard let domain = UserDefaults.standard.value(forKey: "domain") else { return }
        let urlString = "\(domain)/api/v1/user/login"
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        SVProgressHUD.show()
        Alamofire.request(URL.init(string: urlString)!, method: .post, parameters: ["app_token":"6c17d2af3d615c155d90408a8d281fe0","username":self.idTf.text ?? "","password":self.password.text ?? "","uuid":"xxxxx","kind":5], headers: headers).responseJSON { (response) in
            if let JSON = response.result.value as? [String: Any]{
                if let status = JSON["status"] as? String {
                    UserDefaults.standard.set(true, forKey: "check")
                    SVProgressHUD.show(withStatus: status)
                    self.performSegue(withIdentifier: "toARView", sender: self)
                    self.password.resignFirstResponder()
                    self.idTf.resignFirstResponder()
                }else{
                    self.password.errorMessage = "Password Wrong"
                    self.idTf.errorMessage = "Username Wrong"
                    self.password.resignFirstResponder()
                    self.idTf.resignFirstResponder()
                }
                SVProgressHUD.dismiss()
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == password{
            topLayout.constant = 0
        }else{
            topLayout.constant = 50
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        topLayout.constant = 100
        textField.resignFirstResponder()
        return true
    }
}
