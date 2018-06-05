//
//  TopicCell.swift
//  RubyChina
//
//  Created by Jianqiu Xiao on 5/22/15.
//  Copyright (c) 2015 Jianqiu Xiao. All rights reserved.
//

import SwiftyJSON
import UIKit

class TopicCell: UITableViewCell {

    var topic: JSON = [:]
    var tagLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator

        textLabel?.numberOfLines = 4

        detailTextLabel?.font = .preferredFont(forTextStyle: .subheadline)
        detailTextLabel?.textColor = .lightGray
        self.addSubview(tagLabel)
        tagLabel.backgroundColor = .red
        tagLabel.textColor = .white
        tagLabel.text = "热门"
        tagLabel.textAlignment = .center
        tagLabel.layer.cornerRadius = 2
        tagLabel.layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame.origin.y = 11.5
        textLabel?.text = topic["title"].string
        textLabel?.frame.size.height = textLabel!.textRect(forBounds: textLabel!.frame, limitedToNumberOfLines: 3).height
        tagLabel.frame = CGRect(x:SCREEN_WIDTH-45, y:10, width:40, height:18)
        
        detailTextLabel?.frame.origin.y = 11.5 + textLabel!.frame.height + 5
        detailTextLabel?.text = "[\(topic["node_name"])] · \(topic["user"]["login"]) · \(Helper.timeAgoSinceNow(topic["replied_at"].string ?? topic["created_at"].string))\(topic["replies_count"].intValue > 0 ? " · \(topic["replies_count"]) ↵" : "")"
    }
}
