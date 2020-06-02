//
//  CodeCompanyViewController.swift
//  Ai-alearn
//
//  Created by NDPhu on 8/14/19.
//  Copyright © 2019 NDPhu. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Alamofire
import SVProgressHUD
class CodeCompanyViewController: UIViewController {
    @IBOutlet weak var topLayout: NSLayoutConstraint!
    @IBOutlet weak var codeTf: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        codeTf.delegate = self
    }
    @IBAction func unwindToCode(segue: UIStoryboardSegue) {
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        codeTf.text = ""
    }
    @IBAction func checkCode(_ sender: UIButton) {
        checkCompanyCode()
    }
    
    func checkCompanyCode(){
        let urlString = "https://luck-manager.aimap.jp/api/v1/user/company-code"
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        SVProgressHUD.show()
        Alamofire.request(URL.init(string: urlString)!, method: .post, parameters: ["app_token":"6c17d2af3d615c155d90408a8d281fe0","company_code":codeTf.text ?? ""], headers: headers).responseJSON { (response) in
            if let JSON = response.result.value as? [String: Any]{
                SVProgressHUD.dismiss()
                if let data = JSON["data"] as? [String: Any] {
                    guard let domain = data["domain"] as? String else {return}
                    let id = data["id"] as? Int ?? 0
                    let kms = data["kms"] as? String ?? ""
                    let code = data["code"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let nickname = data["nickname"] as? String ?? ""
                    let aisys = data["aisys"] as? String ?? ""
                    let companyCode = CompanyCode.init(aisys: aisys, code: code, kms: kms, domain: domain, name: name, nickname: nickname, id: id)
                    self.codeTf.resignFirstResponder()
                    UserDefaults.standard.set(companyCode.domain, forKey: "domain")
                    self.performSegue(withIdentifier: "toLogin", sender: self)
                }else{
                    self.codeTf.resignFirstResponder()
                    self.codeTf.errorMessage = "Company Code Wrong"
                }
            }
        }
    }
}

extension CodeCompanyViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        topLayout.constant = 50
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        topLayout.constant = 100
        textField.resignFirstResponder()
        return true
    }
}
