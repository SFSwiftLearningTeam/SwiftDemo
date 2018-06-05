//
//  MeViewController.swift
//  RubyChina
//
//  Created by FreyaYu on 2018/5/31.
//  Copyright © 2018年 Jianqiu Xiao. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import SQLite

class MeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    var user: JSON = [:]
    let dataSource = ["我的评价","我的已读","我的发帖","我的回复"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我"
        
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if Defaults.userId == nil {
            logoutView.isHidden = true
            tableView.isHidden = true
//            signIn()
        }else{
            let path = "/users/current.json"
            let searchPath = Helper.baseURL.absoluteString + path
            Alamofire.request(searchPath, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
                
                switch response.result{
                case .success:
                    self.logoutView.isHidden = false
                    self.tableView.isHidden = false
                    self.user = JSON(response.result.value)["user"]
                    if self.user.dictionary == nil {
                        self.signedOut()
                        self.logoutView.isHidden = true
                        self.tableView.isHidden = true
                    }else{
                        self.nameLabel?.text = self.user["login"].stringValue
                        self.userIdLabel?.text = self.user["name"].stringValue != "" ? self.user["name"].string : self.user["login"].string
                    }
                case .failure: ()
                    self.logoutView.isHidden = true
                    self.tableView.isHidden = true
                }
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = dataSource[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            self.navigationController?.pushViewController(readRecordsViewController(), animated: true)
        default:()
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        if Defaults.userId == nil {
            let vc = SignInController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func logoutActiopn(_ sender: Any) {
        let alertController = UIAlertController(title: "确定注销吗？", message: "注销后可以重新登录。", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "注销", style: .destructive) { _ in
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            let path = "/sessions/0.json"
//            AFHTTPSessionManager(baseURL: Helper.baseURL).delete(path, parameters: nil, success: { task, responseObject in
//                progressHUD.hide(animated: false)
//                self.signedOut()
//            }) { task, error in
//                progressHUD.hide(animated: false)
//                self.alert("网络错误")
//            }
            let searchPath = Helper.baseURL.absoluteString + path
            Alamofire.request(searchPath, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
                
                switch response.result{
                case .success:
                    progressHUD.hide(animated: false)
                    self.signedOut()
                case .failure:
                    progressHUD.hide(animated: false)
                    self.alert("网络错误")
                    
                }
                self.tableView.reloadData()
                
            }
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func signedOut() {
        Defaults.userId = nil
        user = [:]
        tableView.reloadData()
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
