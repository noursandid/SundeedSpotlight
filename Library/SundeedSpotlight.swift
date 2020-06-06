//
//  SundeedSpotlight.swift
//  SundeedSpotlight
//
//  Created by Nour Sandid on 6/6/20.
//  Copyright © 2020 LUMBERCODE. All rights reserved.
//

import UIKit

open class SundeedSpotlight: HighlightingView {
    private let infoView: InfoView = InfoView()
    
    override func commonInit() {
        super.commonInit()
        self.addSubview(infoView)
        self.addInfoBasicConstraints()
    }
    
    private func addInfoBasicConstraints() {
        infoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            infoView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            infoView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.75)
        ])
    }
    
    override func hideInfo(completion: @escaping ()->Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.infoView.alpha = 0
        }, completion: { _ in
            completion()
        })
    }
    
    public override func next(completion: ((Bool)->Void)? = nil) {
        super.next() { didMove in
            if didMove {
                guard let currentAction = self.currentAction else {
                    completion?(false)
                    return
                }
                switch currentAction {
                case .highlighted(let highlight):
                    self.infoView.didMoveToItem(at: self.currentIndex,
                                                withInfo: highlight.info,
                                                withUserInfo: highlight.userInfo)
                case .wait(let identifier):
                    self.infoView.isWaiting(for: identifier)
                default:
                    completion?(false)
                    break
                }
                completion?(true)
            } else {
                self.infoView.isWaitingForInsertion()
                self.currentIndex += 1
                completion?(false)
            }
        }
    }
    
    override func doneWaitingForInsertion() {
        super.doneWaitingForInsertion()
        self.infoView.doneWaitingForInsertion()
    }
    
    override func didContinue(for identifier: String) {
        super.didContinue(for: identifier)
        self.infoView.didContinue(for: identifier)
    }
    
    override func showInfo() {
        super.showInfo()
        self.addInfoDynamicConstraints()
        self.infoView.addMask(to: highlightedView?.view)
        UIView.animate(withDuration: 0.3, animations: {
            self.infoView.alpha = 1
        })
    }
    
    private func addInfoDynamicConstraints() {
        guard let highlightedView = highlightedView else { return }
        guard let center = highlightedView.view.superview?
            .convert(highlightedView.view.center,
                     to: nil) else { return }
        
        infoView.deactivateConstraints()
        let centerXConstraint = infoView.centerXAnchor
            .constraint(equalTo: centerXAnchor,
                        constant: center.x - self.center.x)
        centerXConstraint.priority = .defaultLow
        centerXConstraint.isActive = true
        infoView.viewConstraints.append(centerXConstraint)
        
        guard let highLightedViewFrame = highlightedView.view.superview?
                .convert(highlightedView.view.frame, to: nil)
            else { return }
        let radius = highlightedView.customRadius ?? 5
        if center.y < frame.height/2 {
            addInfoTopConstraints(radius: radius,
                                  highlightedFrame: highLightedViewFrame)
        } else {
            addInfoBottomConstraints(radius: radius,
                                     highlightedFrame: highLightedViewFrame)
        }
    }
    
    func addInfoBottomConstraints(radius: CGFloat,
                                  highlightedFrame: CGRect) {
        let bottomConstant = (frame.height - highlightedFrame.origin.y) + radius + 16
        let bottomConstraint = infoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomConstant)
        bottomConstraint.priority = .defaultLow
        bottomConstraint.isActive = true
        infoView.viewConstraints.append(bottomConstraint)
    }
    
    func addInfoTopConstraints(radius: CGFloat, highlightedFrame: CGRect) {
        let topConstant = highlightedFrame.origin.y +
            highlightedFrame.height + radius + 16
        let topConstraint = infoView.topAnchor.constraint(equalTo: topAnchor, constant: topConstant)
        topConstraint.priority = .defaultLow
        topConstraint.isActive = true
        infoView.viewConstraints.append(topConstraint)
    }
    
    @discardableResult
    public func withCustomInfoView(_ view: CustomSpotlightInfoView) -> Self {
        infoView.embed(view)
        (view.manager as? InfoViewManager)?.delegate = self
        return self
    }
    
    @discardableResult
    public func withBackgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    @discardableResult
    public func withInfoCornerRadius(_ cornerRadius: CGFloat) -> Self {
        self.infoView.cornerRadius = cornerRadius
        return self
    }
}

extension SundeedSpotlight: SpotLightInfoViewManagerDelegate {
    func didPressNext() {
        self.next()
    }
    func didPressSkip() {
        self.stop()
    }
}

