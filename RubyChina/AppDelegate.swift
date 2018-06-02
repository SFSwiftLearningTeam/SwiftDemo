//
//  AppDelegate.swift
//  RubyChina
//
//  Created by Jianqiu Xiao on 5/19/15.
//  Copyright (c) 2015 Jianqiu Xiao. All rights reserved.
//

import AFNetworking
import UIKit
import SQLite

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 9.1, *) {
            application.shortcutItems = [
                UIApplicationShortcutItem(type: "topics", localizedTitle: "社区", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .home), userInfo: nil),
                UIApplicationShortcutItem(type: "compose", localizedTitle: "发帖", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .compose), userInfo: nil),
            ]
        }

        AFNetworkActivityIndicatorManager.shared().isEnabled = true
        window = UIWindow(frame: UIScreen.main.bounds)

        window?.rootViewController = SplitViewController()
        window?.tintColor = Helper.tintColor
        window?.makeKeyAndVisible()
        
        //创建数据库
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDir = paths[0]
        
        let db = try? Connection(documentDir + "/db.sqlite3")
        
        //已读数据表
        let readRecords = Table("readRecords")
        let id = Expression<Int64>("id")
        let title = Expression<String?>("title")
        let node_name = Expression<String?>("node_name")
        let replies_count = Expression<Int64?>("replies_count")
        let replied_at = Expression<String?>("replied_at")
        let login = Expression<String?>("login")
        if(db != nil){
            do{
                try db!.run(readRecords.create { t in
                    t.column(id, primaryKey: true)
                    t.column(title)
                    t.column(node_name)
                    t.column(replies_count)
                    t.column(replied_at)
                    t.column(login)
                })
            }catch{
                print(error)
            }
        }
        //
        
        
        return true
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let splitViewController = window?.rootViewController as? SplitViewController else { return }
        switch shortcutItem.type {
        case "topics":
            guard let navigationController = splitViewController.viewControllers.first as? UINavigationController else { return }
            navigationController.popToRootViewController(animated: true)
        case "compose":
            splitViewController.showDetailViewController(UINavigationController(rootViewController: ComposeController()), sender: nil)
        default: Void()
        }
    }
}
