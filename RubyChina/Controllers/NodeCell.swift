//
//  CollectionViewNodeCell.swift
//  RubyChina
//
//  Created by FreyaYu on 2018/5/27.
//  Copyright © 2018年 Jianqiu Xiao. All rights reserved.
//

import UIKit
enum CellType:Int{
    case CellTypeExist
    case CellTypeAdd
}
class NodeCell: UICollectionViewCell {

    @IBOutlet weak var deleteImg: UIImageView!
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nodeNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func reloadCellWithTitle(title:String, isEditing:Bool, type:CellType) {
        nodeNameLabel.text = title
        if(isEditing){
            self.deleteImg.isHidden = false
        }else{
            self.deleteImg.isHidden = true
        }
        if(type == .CellTypeAdd){
            self.bgView.backgroundColor = UIColor(red: 221/255, green: 223/255, blue: 223/255, alpha: 1)
            self.bgView.layer.shadowOpacity = 0.8
            self.bgView.layer.shadowColor = UIColor.black.cgColor
            self.bgView.layer.shadowOffset = CGSize(width: 1, height: 1)
        }else{
            self.bgView.backgroundColor = UIColor.lightGray
        }
    }

}
