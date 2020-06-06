//
//  HighlightingView.swift
//  SundeedSpotlight
//
//  Created by Nour Sandid on 6/6/20.
//  Copyright © 2020 LUMBERCODE. All rights reserved.
//

import UIKit

open class HighlightingView: UIView {
    enum Action{
        case highlighted(Highlighted)
        case insertionWait
        case wait(String)
    }
    struct Highlighted {
        var view: UIView
        var customRadius: CGFloat?
        var info: String?
        var userInfo: [String: Any?]
    }
    public var currentIndex: Int = -1
    private let highlightLayer: CAShapeLayer = CAShapeLayer()
    private var actions: [Action] = []
    private var passThrough: Bool = true
    
    var currentAction: Action? {
        guard currentIndex >= 0, currentIndex < actions.count else { return nil }
        return actions[currentIndex]
    }
    var highlightedView: Highlighted? {
        if case .highlighted(let highlight) = currentAction {
            return highlight
        }
        return nil
    }
    private var actionsToBeAdded: [Action] = []
    private var insertedAtIndex: Int = 0
    private var hitTestTimeStamp: Double?
    private var padding: CGFloat = 15
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.layer.mask = self.highlightLayer
    }
    
    func doneWaitingForInsertion() {}
    func didContinue(for identifier: String) {}
    func hideInfo(completion: @escaping ()->Void) {}
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        remask()
    }
    
    private func remask() {
        guard let highlightedView = highlightedView?.view,
            let center = highlightedView.superview?
                .convert(highlightedView.center, to: self),
            let frame = highlightedView.superview?
                .convert(highlightedView.frame,
                         to: self)
            else { return }
        let bezierPath = UIBezierPath(rect: bounds)
        if let radius = self.highlightedView?.customRadius {
            cutCircle(bezierPath: bezierPath, center: center,
                      radius: radius)
        } else {
            cutOval(bezierPath: bezierPath, frame: frame)
        }
        self.animate(to: bezierPath.cgPath)
    }
    
    func cutCircle(bezierPath: UIBezierPath, center: CGPoint, radius: CGFloat) {
        let circle = UIBezierPath(arcCenter: center, radius: radius,
                                  startAngle: 0, endAngle: CGFloat.pi*2,
                                  clockwise: true)
        bezierPath.append(circle.reversing())
    }
    
    func cutOval(bezierPath: UIBezierPath, frame: CGRect) {
        let x = frame.origin.x-padding
        let y = frame.origin.y-padding
        let width = frame.width+(padding*2)
        let height = frame.height+(padding*2)
        let frame = CGRect(x: x, y: y, width: width, height: height)
        let highlighter = UIBezierPath(ovalIn: frame)
        bezierPath.append(highlighter.reversing())
    }
    
    func showInfo() {}
    private func animate(to path: CGPath) {
        let anim = CABasicAnimation(keyPath: "path")
        anim.fromValue = self.highlightLayer.path
        anim.toValue = path
        anim.duration = 0.4
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.showInfo()
        }
        self.highlightLayer.add(anim, forKey: "path")
        CATransaction.setDisableActions(true)
        self.highlightLayer.path = path
        CATransaction.commit()
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        guard let highlightedView = highlightedView?.view,
            let hightlightedFrame = highlightedView.superview?
                .convert(highlightedView.frame, to: self)
            else {
                if passThrough {
                    if case .wait = self.currentAction,
                        hitTestTimeStamp != event?.timestamp {
                        return hitView
                    } else {
                        return nil
                    }
                } else {
                    return hitView
                }
        }
        let isOnHighlight = hightlightedFrame.contains(point)
        
        if hitView == self {
            if isOnHighlight, hitTestTimeStamp != event?.timestamp {
                hitTestTimeStamp = event?.timestamp
                self.next()
                if passThrough {
                    return nil
                }
            }
        }
        if hitTestTimeStamp == event?.timestamp, passThrough {
            return nil
        } else {
            return hitView
        }
    }
    
    public func next(completion: ((Bool)->Void)? = nil) {
        guard self.currentIndex+1 < self.actions.count else {
            self.stop()
            self.currentIndex += 1
            completion?(true)
            return
        }
        if case .insertionWait = self.actions[self.currentIndex+1] {
            completion?(false)
        }
        if case .wait = self.actions[self.currentIndex+1] {
            self.currentIndex += 1
            completion?(true)
            self.currentIndex -= 1
            self.showInfo()
        }
        
        self.currentIndex += 1
        if case.highlighted = self.actions[self.currentIndex] {
            self.hideInfo {
                self.remask()
                completion?(true)
            }
        }
    }
    

    public func stop() {
        removeFromSuperview()
    }
    @discardableResult
    public func show() -> Self {
        self.actions.insert(contentsOf: self.actionsToBeAdded, at: self.insertedAtIndex)
        self.actionsToBeAdded = []
        self.insertedAtIndex = self.actions.count
        if self.superview == nil {
            guard let window = UIApplication.shared.windows.last
                else { return self }
            self.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(self)
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                self.topAnchor.constraint(equalTo: window.topAnchor),
                self.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
            next()
        } else {
            remask()
        }
        return self
    }
    @discardableResult
    public func addTabBarItem(at index: Int, in tabBar: UITabBar?,
                              withInfo info: String? = nil,
                              withUserInfo: [String: Any?] = [:],
                              withCustomRadius radius: CGFloat? = nil) -> Self {
        guard let subViews = tabBar?.subviews.filter({$0 is UIControl}),
            index < subViews.count else { return self }
        self.actionsToBeAdded
            .append(.highlighted(Highlighted(view: subViews[index],
                                             customRadius: radius,
                                             info: info,
                                             userInfo: withUserInfo)))
        self.insertedAtIndex = actions.count
        return self
    }
    @discardableResult
    public func addView(_ view: UIView,
                        withInfo info: String? = nil,
                        withUserInfo: [String: Any?] = [:],
                        withCustomRadius radius: CGFloat? = nil) -> Self {
        self.actionsToBeAdded
            .append(.highlighted(Highlighted(view: view,
                                             customRadius: radius,
                                             info: info,
                                             userInfo: withUserInfo)))
        self.insertedAtIndex = actions.count
        return self
    }
    @discardableResult
    public func insertView(_ view: UIView,
                           withInfo info: String? = nil,
                           withUserInfo: [String: Any?] = [:],
                           withCustomRadius radius: CGFloat? = nil) -> Self {
        self.actionsToBeAdded
            .append(.highlighted(Highlighted(view: view,
                                             customRadius: radius,
                                             info: info,
                                             userInfo: withUserInfo)))
        insertedAtIndex = min(currentIndex, actions.count)
        if case .insertionWait = currentAction {
            self.doneWaitingForInsertion()
            self.next()
        }
        return self
    }
    @discardableResult
    public func insertTabBarItem(at index: Int, in tabBar: UITabBar?,
                                 withInfo info: String? = nil,
                                 withUserInfo: [String: Any?] = [:],
                                 withCustomRadius radius: CGFloat? = nil) -> Self {
        guard let subViews = tabBar?.subviews.filter({$0 is UIControl}),
            index < subViews.count else { return self }
        self.actionsToBeAdded
            .append(.highlighted(Highlighted(view: subViews[index],
                                             customRadius: radius,
                                             info: info,
                                             userInfo: withUserInfo)))
        insertedAtIndex = min(currentIndex, actions.count)
        if case .insertionWait = currentAction {
            self.doneWaitingForInsertion()
            self.next()
        }
        return self
    }
    @discardableResult
    public func waitForInsertion() -> Self {
        self.actionsToBeAdded.append(.insertionWait)
        return self
    }
    
    @discardableResult
    public func wait(for string: String) -> Self {
        self.actionsToBeAdded.append(.wait(string))
        return self
    }
    
    @discardableResult
    public func `continue`(for string: String) -> Self {
        if self.currentIndex < self.actions.count,
            case .wait(let waiting) = self.actions[self.currentIndex],
            waiting == string {
            self.didContinue(for: string)
            self.next()
        }
        return self
    }
    
    @discardableResult
    public func withAbilityToTapThroughSpotlight(_ passthrough: Bool) -> Self {
        self.passThrough = passthrough
        return self
    }
}
