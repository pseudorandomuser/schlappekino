//
//  CustomSearch.swift
//  Schlappekino
//
//  Created by Pit Jost on 21/6/14.
//  Copyright (c) 2014 Pit Jost. All rights reserved.
//

import UIKit

class CustomSearch: UISearchBar {

    var Toolbar: UIToolbar! = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(parent: UISearchBarDelegate!, cancelHandler: Selector, searchHandler: Selector) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.barStyle = UIBarStyle.blackTranslucent
        self.keyboardAppearance = UIKeyboardAppearance.dark
        self.returnKeyType = UIReturnKeyType.done
        self.delegate = parent
        self.Toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        self.Toolbar.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.Toolbar.barStyle = UIBarStyle.blackTranslucent
        let CancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: parent, action: cancelHandler)
        let FlexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: parent, action: nil)
        let SearchButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: parent, action: searchHandler)
        self.Toolbar.setItems([CancelButton, FlexSpace, SearchButton], animated: false)
        self.inputAccessoryView = self.Toolbar
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}
