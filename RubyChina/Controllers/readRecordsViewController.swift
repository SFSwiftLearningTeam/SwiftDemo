//
//  readRecordsViewController.swift
//  RubyChina
//
//  Created by FreyaYu on 2018/6/1.
//  Copyright © 2018年 Jianqiu Xiao. All rights reserved.
//

import UIKit
import SQLite
import SwiftyJSON

class readRecordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var topics: JSON = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的已读"
        topics = JSON(self.fetchReadRecords())
        tableView.register(TopicCell.self, forCellReuseIdentifier: "Cell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TopicCell
        cell.topic = topics[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicController = TopicController()
        topicController.topic = topics[indexPath.row]
        self.navigationController?.pushViewController(topicController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 61
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = TopicCell()
        cell.detailTextLabel?.text = " "
        cell.frame.size.width = tableView.frame.width - 8
        cell.textLabel?.text = topics[indexPath.row]["title"].string
        cell.topic = topics[indexPath.row]
        cell.layoutSubviews()
        return 11.5 + cell.textLabel!.frame.height + 5 + cell.detailTextLabel!.frame.height + 11.5
    }

    func fetchReadRecords() -> [Dictionary<String, String>] {
        let db = try? Connection(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/db.sqlite3")
        
        let readRecords = Table("readRecords")
        let id = Expression<Int64>("id")
        let title = Expression<String?>("title")
        let node_name = Expression<String?>("node_name")
        let replies_count = Expression<Int64?>("replies_count")
        let replied_at = Expression<String?>("replied_at")
        let login = Expression<String?>("login")
        var results : [Dictionary<String, String>] = []
        if(db != nil){
            let readRecords = try? db!.prepare(readRecords)
            for readRecord in readRecords!{
                
                let ai = "\(readRecord[id])"
                let at = readRecord[title]
                let nn = readRecord[node_name]
                let rc = "\(String(describing: readRecord[replies_count]))"
                let ra = readRecord[replied_at]
                let un = readRecord[login]
                
                let record = ["id":ai, "title": at, "node_name": nn,"replies_count": rc,"replied_at": ra,"login": un]
                results.append(record as! [String : String])
            }
        }
        return results
    }

}
