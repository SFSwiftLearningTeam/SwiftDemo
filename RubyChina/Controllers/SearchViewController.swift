//
//  SearchViewController.swift
//  RubyChina
//
//  Created by FreyaYu on 2018/5/27.
//  Copyright © 2018年 Jianqiu Xiao. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    
    var showHistory = true;
    var historySearchList:[String] = [];
    var topics: JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "搜索"
        self.navigationController?.navigationBar.isHidden = false
        tableView.register(TopicCell.self, forCellReuseIdentifier: "TopicCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.textField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.loadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        if(self.fetchPlistData(fileName: "historySearch") != nil){
            historySearchList = self.fetchPlistData(fileName: "historySearch") as! [String]
        }
//        historySearchList = self.fetchPlistData(fileName: "historySearch") as! [String]
        if(historySearchList.count == 0){
            tableViewTopConstraint.constant = 0;
        }else{
            tableViewTopConstraint.constant = 40;
        }
    }
    
    @IBAction func searchAction(_ sender: Any) {
        if(textField.text != nil){
            self.addNewRecordIntoPlist(textField.text!)
            self.startSearch(searchText: textField.text!)
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        self.storeToPlist(dataToStore: NSArray(), fileName: "historySearch")
        historySearchList.removeAll()
        showHistory = false
        tableViewTopConstraint.constant = 0
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(showHistory){
            showHistory = false
            tableViewTopConstraint.constant = 0
            self.textField.text = self.historySearchList[indexPath.row]
            self.startSearch(searchText: self.historySearchList[indexPath.row])
            
        }else{
            let topicController = TopicController()
            topicController.topic = topics[indexPath.row]
            self.navigationController?.pushViewController(topicController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(showHistory){
            return self.historySearchList.count
        }else{
            return self.topics.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(showHistory){
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = self.historySearchList[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopicCell", for: indexPath) as! TopicCell
            cell.topic = topics[indexPath.row]
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(showHistory){
            return 30
        }else{
            return 61
        }
    }
    
    func textFieldDidChange(_ textField: UITextField){
        self.startSearch(searchText: textField.text!)
    }
    
    func addNewRecordIntoPlist(_ record: String){
        let arr = self.fetchPlistData(fileName: "historySearch")
        let newArr = NSMutableArray()
        if(arr != nil){
            newArr.addObjects(from: arr! as! [Any])
        }
        if(!newArr.contains(record)){
            newArr.add(record)
        }
        
        self.storeToPlist(dataToStore: newArr, fileName: "historySearch")
    }
    
    func storeToPlist(dataToStore array: NSArray, fileName name:String) {

        let filePath:String = NSHomeDirectory() + "/Documents/" + name + ".plist"
        array.write(toFile: filePath, atomically: true)
    }
    
    func fetchPlistData(fileName name:String) -> NSArray? {
        return NSArray(contentsOfFile: NSHomeDirectory() + "/Documents/" + name + ".plist")
    }
    
    func startSearch(searchText text:String) {
        showHistory = false
        tableViewTopConstraint.constant = 0
        let limit = 30
        let type = "last_actived"
        let path = "/topics.json?limit=\(limit)&offset=\(topics.count)&type=\(type)&query=\(text)"
  
        let searchPath = Helper.baseURL.absoluteString + path
        Alamofire.request(searchPath, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            switch response.result{
            case .success:
                if let value = response.result.value{
                    //把得到的JSON数据转为字典
                    self.topics = JSON(JSON(value)["topics"].arrayValue)
                }
            case .failure: ()
                
            }
            self.tableView.reloadData()
            
        }
    }
}
