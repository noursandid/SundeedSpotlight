//
//  CustomWalkthroughInfoView.swift
//  SundeedSpotlight
//
//  Created by Nour Sandid on 6/6/20.
//  Copyright © 2020 LUMBERCODE. All rights reserved.
//

import UIKit

public protocol CustomSpotlightInfoView: UIView {
    func walkthroughDidMoveToItem(at index: Int,
                                  withInfo info: String?,
                                  withUserInfo userInfo: [String: Any?])
    func walkthroughIsWaiting(for identifier: String)
    func walkthroughDidContinue(for identifier: String)
    func walkthroughIsWaitingForInsertion()
    func walkthroughDoneWaitingForInsertion()
}
extension CustomSpotlightInfoView {
     func walkthroughDidMoveToItem(at index: Int,
                                   withInfo info: String?,
                                   withUserInfo userInfo: [String : Any?]) {}
    func walkthroughIsWaiting(for identifier: String) {}
    func walkthroughDidContinue(for identifier: String) {}
    func walkthroughIsWaitingForInsertion() {}
    func walkthroughDoneWaitingForInsertion() {}
}
