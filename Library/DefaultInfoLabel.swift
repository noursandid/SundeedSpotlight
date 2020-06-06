//
//  DefaultInfoLabel.swift
//  SundeedSpotlight
//
//  Created by Nour Sandid on 6/6/20.
//  Copyright © 2020 LUMBERCODE. All rights reserved.
//

import UIKit

class DefaultInfoLabel: UILabel, CustomSpotlightInfoView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .black
        self.textColor = .white
        self.textAlignment = .center
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func walkthroughIsWaiting(for identifier: String) {
        self.text = "Waiting..."
    }
    func walkthroughDidMoveToItem(at index: Int, withInfo info: String?, withUserInfo userInfo: [String : Any?]) {
        self.text = info
    }
}
