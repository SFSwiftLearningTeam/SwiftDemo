//
//  NodeModel.swift
//  RubyChina
//
//  Created by FreyaYu on 2018/5/28.
//  Copyright © 2018年 Jianqiu Xiao. All rights reserved.
//

import UIKit

class NodeModel: NSObject {
    var nodeId: NSNumber
    var nodeName: String
    init(nodeId:NSNumber, nodeName:String) {
        self.nodeId = nodeId
        self.nodeName = nodeName
    }
}
