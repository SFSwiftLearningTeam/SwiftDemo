//
//  SplitViewController.swift
//  RubyChina
//
//  Created by Jianqiu Xiao on 6/4/15.
//  Copyright (c) 2015 Jianqiu Xiao. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func loadView() {
        let tabVC = UITabBarController()
        let vc1 = UINavigationController(rootViewController: TopicsController())
        let barItem1 = UITabBarItem(title: "列表", image: UIImage(named: "form"), selectedImage: UIImage(named: "form"))
        vc1.tabBarItem = barItem1
        let vc2 = UINavigationController(rootViewController: UIViewController())
        let barItem2 = UITabBarItem(title: "操作", image: UIImage(named: "operation"), selectedImage: UIImage(named: "operation"))
        vc2.tabBarItem = barItem2
        let vc3 = UINavigationController(rootViewController: UIViewController())
        let barItem3 = UITabBarItem(title: "我", image: UIImage(named: "account"), selectedImage: UIImage(named: "account"))
        vc3.tabBarItem = barItem3
        tabVC.viewControllers = [vc1,vc2,vc3]
        addChildViewController(tabVC)
        addChildViewController(UIViewController())
        super.loadView()
    }

    override func viewDidLoad() {
        delegate = self
        preferredDisplayMode = .allVisible
        view.backgroundColor = Helper.backgroundColor
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return (secondaryViewController as? UINavigationController) == nil
    }

    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        if (primaryViewController as? UINavigationController)?.viewControllers.last as? UINavigationController == nil { return UIViewController() }
        return nil
    }

    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
        (svc.viewControllers.last as? UINavigationController)?.viewControllers.last?.traitCollectionDidChange(nil)
    }
}
