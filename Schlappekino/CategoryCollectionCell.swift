//
//  CustomCatCollectionCell.swift
//  Schlappekino
//
//  Created by Pit Jost on 20/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet var Name : UILabel?
    @IBOutlet var Thumbnail : UIImageView?
    @IBOutlet var Description : UILabel?
    var CategoryInfo: CategoryData! = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.masksToBounds = false
    }
    
    func loadCategoryInfo(_ category: CategoryData) {
        self.CategoryInfo = category
        self.Name!.text = category.Name
        self.Description!.text = category.Description
        self.Thumbnail!.image = UIImage(contentsOfFile: FSTools.getDocumentSub("CategoryAssets/Thumbnails/" + category.ThumbnailName))
        self.Thumbnail!.layer.masksToBounds = false
    }
    
}
