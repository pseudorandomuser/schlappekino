//
//  FileTableViewCell.swift
//  PathFinder
//
//  Created by Pit Jost on 10/07/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func loadFile(_ file: FileData) {
        for View: AnyObject in self.imageView!.subviews {
            (View as! UIView).removeFromSuperview()
        }
        if (file.isDirectory) {
            self.imageView!.image = self.resizeImage(UIImage(named: "icon_folder")!, size: CGSize(width: 60.0, height: 70.0))
            self.accessoryType = UITableViewCellAccessoryType.detailDisclosureButton
        }
        else {
            self.imageView!.image = self.resizeImage(UIImage(named: "icon_file")!, size: CGSize(width: 60.0, height: 80.0))
            let ExtLabel: UILabel = UILabel(frame: CGRect(x: 0, y: self.frame.height - 24, width: 58, height: 22))
            ExtLabel.textAlignment = NSTextAlignment.center
            ExtLabel.font = ExtLabel.font.withSize(11.0)
            ExtLabel.textColor = UIColor(red: 49.0/255, green: 142.0/255, blue: 252.0/255, alpha: 1.0)
            ExtLabel.text = file.fileExtension
            self.imageView!.addSubview(ExtLabel)
            self.accessoryType = UITableViewCellAccessoryType.detailButton
        }
        self.textLabel!.text = file.fileName
        self.detailTextLabel!.text = "\(file.fileSize) bytes"
    }
    
    func resizeImage(_ image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let Image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return Image
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
