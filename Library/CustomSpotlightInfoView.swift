//
//  CustomWalkthroughInfoView.swift
//  SundeedSpotlight
//
//  Created by Nour Sandid on 6/6/20.
//  Copyright © 2020 LUMBERCODE. All rights reserved.
//

import UIKit

public protocol SpotlightInfoViewManager {
    func next()
    func skip()
}
protocol SpotLightInfoViewManagerDelegate {
    func didPressNext()
    func didPressSkip()
}
public class InfoViewManager: SpotlightInfoViewManager {
    var delegate: SpotLightInfoViewManagerDelegate?
    public func next() {
        delegate?.didPressNext()
    }
    public func skip() {
        self.delegate?.didPressSkip()
    }
}

public protocol CustomSpotlightInfoView: UIView {
    var manager: SpotlightInfoViewManager? { get }
    func walkthroughDidMoveToItem(at index: Int,
                                  withInfo info: String?,
                                  withUserInfo userInfo: [String: Any?])
    func walkthroughIsWaiting(for identifier: String)
    func walkthroughDidContinue(for identifier: String)
    func walkthroughIsWaitingForInsertion()
    func walkthroughDoneWaitingForInsertion()
}
extension CustomSpotlightInfoView {
    var manager: SpotlightInfoViewManager? { nil }
    func walkthroughDidMoveToItem(at index: Int,
                                  withInfo info: String?,
                                  withUserInfo userInfo: [String : Any?]) {}
    func walkthroughIsWaiting(for identifier: String) {}
    func walkthroughDidContinue(for identifier: String) {}
    func walkthroughIsWaitingForInsertion() {}
    func walkthroughDoneWaitingForInsertion() {}
}
