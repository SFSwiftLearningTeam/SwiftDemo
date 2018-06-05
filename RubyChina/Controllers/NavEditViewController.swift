//
//  NavEditViewController.swift
//  RubyChina
//
//  Created by FreyaYu on 2018/5/27.
//  Copyright © 2018年 Jianqiu Xiao. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

typealias chooseNodeBlock = (NodeModel) -> ()
typealias saveBlock = ([NodeModel]) -> ()
//typealias chooseNodeBlock = (String) -> String

class NavEditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var myNodeCollectionView: UICollectionView!
    
    @IBOutlet weak var otherNodeCollectionView: UICollectionView!
    
    @IBOutlet weak var editBtn: UIButton!
    var chooseANodeBlock : chooseNodeBlock?
    var saveNodesBlock : saveBlock?
    var nodes: JSON = []
//    var myNodeNames = ["招聘","Ruby","Gem","部署","开源项目","测试"]
    var myNodes: [NodeModel] = []
    var otherNodes: [NodeModel] = []
    var isNodeEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "导航编辑"
        self.navigationController?.navigationBar.isHidden = false
        self.loadData()
        
        let item = UIBarButtonItem(title:"完成", style: UIBarButtonItemStyle.plain, target: self, action: #selector(comfirmAction))
        self.navigationItem.rightBarButtonItem = item
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize.init(width:(SCREEN_WIDTH-16)/4,height:50)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        let flowLayout2 = UICollectionViewFlowLayout()
        flowLayout2.itemSize = CGSize.init(width:(SCREEN_WIDTH-16)/4,height:50)
        flowLayout2.minimumLineSpacing = 0
        flowLayout2.minimumInteritemSpacing = 0;
        flowLayout2.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        myNodeCollectionView.collectionViewLayout = flowLayout
        myNodeCollectionView.register(UINib.init(nibName: "NodeCell", bundle: nil), forCellWithReuseIdentifier: "NodeCell")
        myNodeCollectionView.showsVerticalScrollIndicator = false
        otherNodeCollectionView.collectionViewLayout = flowLayout2
        otherNodeCollectionView.register(UINib.init(nibName: "NodeCell", bundle: nil), forCellWithReuseIdentifier: "NodeCell")
        otherNodeCollectionView.showsVerticalScrollIndicator = false
    }
    
    func loadData() {
        let path = Helper.baseURL.absoluteString + "/nodes/grouped.json"
        
        Alamofire.request(path, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            switch response.result{
            case .success:
                if let value = response.result.value{
                    //把得到的JSON数据转为字典
                    self.nodes = JSON(value)
                    for i in 0 ..< self.nodes.count {
                        for j in 0 ..< self.nodes[i]["nodes"].count {
                            let node = self.nodes[i]["nodes"][j]
                            if(!self.nodeNameExist(nodeName: node.dictionaryObject!["name"] as! String)){
                                self.otherNodes.append(NodeModel(nodeId: node.dictionaryObject!["id"] as! NSNumber,nodeName: node.dictionaryObject!["name"] as! String))
                            }
//                            if(!self.myNodeNames.contains(node.dictionaryObject!["name"] as! String)){
//                                self.otherNodes.append(NodeModel(nodeId: node.dictionaryObject!["id"] as! NSNumber,nodeName: node.dictionaryObject!["name"] as! String))
//                            }else{
//                                self.myNodes.append(NodeModel(nodeId: node.dictionaryObject!["id"] as! NSNumber,nodeName: node.dictionaryObject!["name"] as! String))
//                            }
                        }
                    }
                }
                self.myNodeCollectionView .reloadData()
                self.otherNodeCollectionView .reloadData()
            case .failure: ()
                
            }
        }

    }
    
    func nodeNameExist(nodeName: String) -> Bool {
        for nodeModel in self.myNodes{
            if(nodeModel.nodeName == nodeName){
                return true
            }
        }
        return false
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.myNodeCollectionView){
            return myNodes.count
        }else{
            return otherNodes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NodeCell", for: indexPath) as! NodeCell
        if(collectionView == self.myNodeCollectionView){
            let node = self.myNodes[indexPath.item]
            cell.reloadCellWithTitle(title: node.nodeName, isEditing: self.isNodeEditing, type: .CellTypeExist)
            return cell
        }else{
            let node = self.otherNodes[indexPath.item]
            cell.reloadCellWithTitle(title: "+\(node.nodeName)", isEditing: false, type: .CellTypeAdd)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.myNodeCollectionView){
            if(isNodeEditing){
                self.deleteNode(node: self.myNodes[indexPath.item])
            }else{
                self.chooseANodeBlock!(self.myNodes[indexPath.item])
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            self.addNode(node: self.otherNodes[indexPath.item])
        }
    }
    
    @IBAction func editAction(_ sender: Any) {
        isNodeEditing = !isNodeEditing
        if(isNodeEditing){
            editBtn.setTitle("取消编辑", for: UIControlState.normal)
        }else{
            editBtn.setTitle("编辑", for: UIControlState.normal)
        }
        self.myNodeCollectionView.reloadData()
    }
    
    func comfirmAction() {
        self.saveNodesBlock!(self.myNodes)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteNode(node:NodeModel) {
        self.otherNodes.append(node)
        if(self.myNodes.contains(node)){
            self.myNodes.remove(at: self.myNodes.index(of: node)!)
        }
        self.myNodeCollectionView.reloadData()
        self.otherNodeCollectionView.reloadData()
    }
    
    func addNode(node:NodeModel) {
        self.myNodes.append(node)
        if(self.otherNodes.contains(node)){
            self.otherNodes.remove(at: self.otherNodes.index(of: node)!)
        }
        self.myNodeCollectionView.reloadData()
        self.otherNodeCollectionView.reloadData()
    }

}
