//
//  NodesController.swift
//  RubyChina
//
//  Created by Jianqiu Xiao on 5/22/15.
//  Copyright (c) 2015 Jianqiu Xiao. All rights reserved.
//

import AFNetworking
import CCBottomRefreshControl
import SwiftyJSON
import TPKeyboardAvoiding
import UINavigationBar_Addition
import UIKit
import Alamofire
import SQLite

class TopicsController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIToolbarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var emptyView = EmptyView()
    var failureView = FailureView()
    var loadingView = LoadingView()
    var editNavBtn : UIButton!
    var parameters: JSON = [:]
    var refreshing = false
    var tableView = TPKeyboardAvoidingTableView()
    var collectionView : UICollectionView!
//    var toolbar = UIToolbar()
    var topRefreshControl = UIRefreshControl()
    var topics: JSON = []
    var myNodes: [NodeModel] = []
    var nodes: JSON = []
    var selectedIndex = 0


    override func viewDidLoad() {
        
//        automaticallyAdjustsScrollViewInsets = false
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "UserIcon"), style: .plain, target: self, action: #selector(user))
//        navigationItem.title = "社区"

        view.backgroundColor = Helper.backgroundColor
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize.init(width:(SCREEN_WIDTH-16)/4,height:50)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x:view.bounds.origin.x, y:view.bounds.origin.y, width:SCREEN_WIDTH - 60, height:64), collectionViewLayout: flowLayout)
        collectionView.register(UINib.init(nibName: "NavCell", bundle: nil), forCellWithReuseIdentifier: "NavCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionView)
        
        editNavBtn = UIButton(type:.custom)
        editNavBtn.frame = CGRect(x:SCREEN_WIDTH - 45, y:view.bounds.origin.y + 20, width:30, height:30)
        editNavBtn.setImage(UIImage(named:"nav_list"), for: .normal)
        editNavBtn.addTarget(self, action:  #selector(TopicsController.editNav), for: UIControlEvents.touchUpInside)
        self.view.addSubview(editNavBtn)
        
        tableView.allowsMultipleSelection = false
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = CGRect(x:view.bounds.origin.x, y:view.bounds.origin.y + 64, width:SCREEN_WIDTH, height:SCREEN_HEIGHT-64-44)
//        tableView.frame = view.bounds
        tableView.register(TopicCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)

        let searchBar = UISearchBar()
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.delegate = self
        searchBar.placeholder = "搜索"
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar

        topRefreshControl.addTarget(self, action: #selector(topRefresh), for: .valueChanged)
        tableView.addSubview(topRefreshControl)

        let bottomRefreshControl = UIRefreshControl()
        bottomRefreshControl.addTarget(self, action: #selector(bottomRefresh), for: .valueChanged)
        tableView.bottomRefreshControl = bottomRefreshControl

//        toolbar.autoresizingMask = .flexibleWidth
//        toolbar.delegate = self
//        toolbar.frame.size.width = view.bounds.width
//        view.addSubview(toolbar)

        failureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(autoRefresh)))
        view.addSubview(failureView)

        view.addSubview(loadingView)

        emptyView.text = "没有帖子"
        view.addSubview(emptyView)

        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.hideBottomHairline()
        if let indexPath = tableView.indexPathForSelectedRow { tableView.deselectRow(at: indexPath, animated: true) }
        traitCollectionDidChange(nil)
        if myNodes.count == 0 { loadNodes() }
//        if topics.count == 0 { autoRefresh() }
        Helper.trackView(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.showBottomHairline()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myNodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NavCell", for: indexPath) as! NavCell
        let node = self.myNodes[indexPath.item]
        cell.titleLabel.text = node.nodeName
        if(indexPath.item == selectedIndex){
            cell.titleLabel.textColor = UIColor.red
        }else{
            cell.titleLabel.textColor = UIColor.black
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        collectionView.reloadData()
        loadData()
    }

    func autoRefresh() {
        if refreshing { return }
        loadingView.show()
        loadData()
    }

    func topRefresh() {
        if refreshing { topRefreshControl.endRefreshing(); return }
        topics = []
        loadData()
    }

    func bottomRefresh() {
        if refreshing { tableView.bottomRefreshControl.endRefreshing(); tableView.bottomRefreshControl.isHidden = true; return }
        loadData()
    }

    func stopRefresh() {
        refreshing = false
        loadingView.hide()
        topRefreshControl.endRefreshing()
        tableView.bottomRefreshControl.endRefreshing()
        tableView.bottomRefreshControl.isHidden = true
    }

    func loadData() {
        if refreshing { return }
        refreshing = true
        failureView.hide()
        emptyView.hide()
        let path = "/topics.json"
        parameters["limit"] = 30
        parameters["offset"].object = topics.count
        parameters["node_id"].object = myNodes[selectedIndex].nodeId
        AFHTTPSessionManager(baseURL: Helper.baseURL).get(path, parameters: parameters.object, progress: nil, success: { task, responseObject in
            self.stopRefresh()
            if JSON(responseObject)["topics"].count == 0 { if self.topics.count == 0 { self.emptyView.show() } else { return } }
            if self.topics.count == 0 { self.tableView.scrollRectToVisible(CGRect(x: 0, y: self.tableView.tableHeaderView?.frame.height ?? 0, width: 1, height: 1), animated: false) }
            self.topics = JSON(responseObject)["topics"]
            self.tableView.reloadData()
        }) { task, error in
            self.stopRefresh()
            self.failureView.show()
        }
    }
    func loadNodes() {
        let path = Helper.baseURL.absoluteString + "/nodes/grouped.json"
        
        Alamofire.request(path, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            switch response.result{
            case .success:
                if let value = response.result.value{
                    //把得到的JSON数据转为字典
                    self.nodes = JSON(value)
                    for i in 0 ..< self.nodes.count {
                        if(self.myNodes.count > 8){
                            break;
                        }
                        for j in 0 ..< self.nodes[i]["nodes"].count {
                            let node = self.nodes[i]["nodes"][j]
                            self.myNodes.append(NodeModel(nodeId: node.dictionaryObject!["id"] as! NSNumber,nodeName: node.dictionaryObject!["name"] as! String))
                            if(self.myNodes.count > 8){
                                break;
                            }
                        }
                    }
                }
                self.collectionView.reloadData()
                self.collectionView.selectItem(at:IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.top)
                if self.topics.count == 0 { self.autoRefresh() }
            case .failure: ()
                
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TopicCell
        cell.topic = topics[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topicController = TopicController()
        topicController.topic = topics[indexPath.row]
        self.saveReadRecord(topic:topics[indexPath.row])
        self.navigationController?.pushViewController(topicController, animated: true)
//        splitViewController?.showDetailViewController(UINavigationController(rootViewController: topicController), sender: self)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row + 1) % 30 == 0 && indexPath.row + 1 == topics.count { autoRefresh() }
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .top
    }

//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        toolbar.frame.origin.y = min(UIApplication.shared.statusBarFrame.width, UIApplication.shared.statusBarFrame.height) + navigationController!.navigationBar.frame.height
//        toolbar.frame.size.height = navigationController!.navigationBar.frame.height
//        tableView.contentInset.top = toolbar.frame.origin.y + toolbar.frame.height
//        tableView.scrollIndicatorInsets.top = toolbar.frame.origin.y + toolbar.frame.height
//    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.resignFirstResponder()
        self.navigationController?.pushViewController(SearchViewController(), animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        parameters["query"].string = searchBar.text != "" ? searchBar.text : nil
        topics = []
        tableView.reloadData()
        autoRefresh()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBarSearchButtonClicked(searchBar)
    }
    
    func editNav() {
        let navVC = NavEditViewController()
        navVC.myNodes = myNodes
        navVC.chooseANodeBlock = {
            (node:NodeModel) -> () in
            //滚动导航条，更新数据
            self.selectedIndex = self.myNodes.index(of: node)!
            self.collectionView.selectItem(at: IndexPath(row: self.selectedIndex, section: 0), animated: false, scrollPosition: .top)
            self.loadData()
        }
        navVC.saveNodesBlock = {
            (nodes:[NodeModel]) -> () in
            //更新导航，默认选中第一项
            self.myNodes = nodes
            self.selectedIndex = 0
            self.collectionView.reloadData()
            self.loadData()
        }
        navigationController?.pushViewController(navVC, animated: true)
    }

    func user() {
        let navVC = NavEditViewController()
        navVC.chooseANodeBlock = {
            (node:NodeModel) -> () in
            //滚动导航条，更新数据
        }
        navVC.saveNodesBlock = {
            (nodes:[NodeModel]) -> () in
            //更新导航，默认选中第一项
        }
        navigationController?.pushViewController(navVC, animated: true)
    }

    func selectNode(_ node: JSON) {
        parameters["node_id"] = node["id"]
        title = node["name"].string
        topics = []
        tableView.reloadData()
        _ = navigationController?.popToViewController(self, animated: true)
    }
    
    func saveReadRecord(topic:JSON) {
        let db = try? Connection(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/db.sqlite3")
        
        let readRecords = Table("readRecords")
        let id = Expression<Int64>("id")
        let title = Expression<String?>("title")
        let node_name = Expression<String?>("node_name")
        let replies_count = Expression<Int64?>("replies_count")
        let replied_at = Expression<String?>("replied_at")
        let login = Expression<String?>("login")
        let insert = readRecords.insert(id <- Int64(topic["id"].intValue),title <- topic["title"].string, node_name <- topic["node_name"].string,replies_count <- Int64(topic["replies_count"].intValue),replied_at <- topic["replied_at"].string,login <- topic["user"]["login"].string)
        _ = try? db?.run(insert)
    }
    
}


extension TopicsController: UIViewControllerPreviewingDelegate {

    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: view.convert(location, to: tableView)) else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        previewingContext.sourceRect = tableView.convert(cell.frame, to: view)
        let topicController = TopicController()
        topicController.topic = topics[indexPath.row]
        return topicController
    }

    @available(iOS 9.0, *)
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        splitViewController?.showDetailViewController(UINavigationController(rootViewController: viewControllerToCommit), sender: self)
    }
}
