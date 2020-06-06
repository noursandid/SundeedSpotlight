//
//  InfoView.swift
//  SundeedSpotlight
//
//  Created by Nour Sandid on 6/6/20.
//  Copyright © 2020 LUMBERCODE. All rights reserved.
//

import UIKit
class InfoView: UIView {
    private let containerView: UIView = UIView()
    private let label: DefaultInfoLabel = DefaultInfoLabel()
    private let shapeLayer = CAShapeLayer()
    private var embededView: CustomSpotlightInfoView?
    var viewConstraints: [NSLayoutConstraint] = []
    var cornerRadius: CGFloat = 10
    lazy var cornerLength: CGFloat = cornerRadius/sqrt(2)
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func deactivateConstraints() {
        viewConstraints.forEach({
            $0.isActive = false
        })
        removeConstraints(viewConstraints)
        viewConstraints = []
    }
    private func commonInit() {
        addContainerView()
        embed(label)
    }
    
    func addMask(to infoView: UIView?) {
        layoutIfNeeded()
        guard let view = infoView,
            let viewCenter = view.superview?.convert(view.center, to: self),
            let viewCenterToWindow = view.superview?.convert(view.center, to: nil)
            else { return }
        let minX = containerView.frame.origin.x
        let minY = containerView.frame.origin.y
        let maxX = containerView.frame.origin.x+containerView.frame.width
        let maxY = containerView.frame.origin.y+containerView.frame.height
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: minX+cornerLength,
                                    y: minY))
        bezierPath.addQuadCurve(to: CGPoint(x: minX,
                                            y: minY+cornerLength),
                                controlPoint: CGPoint(x: minX,
                                                      y: minY))
        bezierPath.addLine(to: CGPoint(x: minX, y: maxY-cornerLength))
        bezierPath.addQuadCurve(to: CGPoint(x: minX+cornerLength,
                                            y: maxY),
                                controlPoint: CGPoint(x: minX,
                                                      y: maxY))
        let controlPointX = viewCenter.x
        let leftX = max(minX+cornerLength, controlPointX - 8)
        let rightX = min(maxX-cornerLength, controlPointX + 8)
        if center.y < viewCenterToWindow.y {
            let peak = CGPoint(x: controlPointX,
                               y: frame.height)
            bezierPath.addLine(to: CGPoint(x: leftX,
                                           y: maxY))
            bezierPath.addLine(to: peak)
            bezierPath.addLine(to: CGPoint(x: rightX,
                                           y: maxY))
            bezierPath.addLine(to: CGPoint(x: maxX-cornerLength,
                                           y: maxY))
            bezierPath.addQuadCurve(to: CGPoint(x: maxX,
                                                y: maxY-cornerLength),
                                    controlPoint: CGPoint(x: maxX,
                                                          y: maxY))
            bezierPath.addLine(to: CGPoint(x: maxX,
                                           y: minY+cornerLength))
            
            bezierPath.addQuadCurve(to: CGPoint(x: maxX-cornerLength,
                                                y: minY),
                                    controlPoint: CGPoint(x: maxX,
                                                          y: minY))
        } else {
            let peak = CGPoint(x: controlPointX,
                               y: 0)
            bezierPath.addLine(to: CGPoint(x: maxX-cornerLength,
                                           y: maxY))
            bezierPath.addQuadCurve(to: CGPoint(x: maxX,
                                                y: maxY-cornerLength),
                                    controlPoint: CGPoint(x: maxX,
                                                          y: maxY))
            bezierPath.addLine(to: CGPoint(x: maxX,
                                           y: minY+cornerLength))
            bezierPath.addQuadCurve(to: CGPoint(x: maxX-cornerLength,
                                                y: minY),
                                    controlPoint: CGPoint(x: maxX,
                                                          y: minY))
            bezierPath.addLine(to: CGPoint(x: rightX, y: minY))
            bezierPath.addLine(to: peak)
            bezierPath.addLine(to: CGPoint(x: leftX, y: minY))
        }
         bezierPath.close()
        shapeLayer.path = bezierPath.cgPath
        layer.mask = shapeLayer
    }
    
    func addContainerView() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ]
        
        constraints.forEach({$0.priority = UILayoutPriority(rawValue: 999)})
        NSLayoutConstraint.activate(constraints)
    }
    
    func embed(_ view: CustomSpotlightInfoView) {
        embededView?.removeFromSuperview()
        embededView = view
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
        ]
        NSLayoutConstraint.activate(constraints)
        setBackground(like: view)
    }
    
    func setBackground(like view: UIView) {
        if view.backgroundColor == nil {
            backgroundColor = .white
        } else {
            backgroundColor = view.backgroundColor
        }
    }
    
    func isWaiting(for identifier: String) {
        embededView?.walkthroughIsWaiting(for: identifier)
    }
    
    func didMoveToItem(at index: Int, withInfo info: String?,
                       withUserInfo userInfo: [String: Any?]) {
        embededView?.walkthroughDidMoveToItem(at: index, withInfo: info,
                                              withUserInfo: userInfo)
    }
    
    func didContinue(for identifier: String) {
        embededView?.walkthroughDidContinue(for: identifier)
    }
    
    func isWaitingForInsertion() {
        embededView?.walkthroughIsWaitingForInsertion()
    }
    
    func doneWaitingForInsertion() {
        embededView?.walkthroughDoneWaitingForInsertion()
    }
}
