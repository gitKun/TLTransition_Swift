//
//  TLPushTransitionDelegate.swift
//  TLTransition_Swift
//
//  Created by DR_Kun on 2019/5/13.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

import UIKit


enum Planet: Int {
    case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune
}

public enum TLPanDirectionType: Int {
    
    case none       = 0b0000
    case edgeLeft   = 0b0001
    case edgeRight  = 0b0010
    case edgeUp     = 0b0100
    case engeDown   = 0b1000
}

public enum TLAnimationType: Int {
    case none = 0, viewFame, windowScale, appStore, bottomViewAlert, tabScroll
}

final class TLPushTransitionDelegate: UIPercentDrivenInteractiveTransition,UINavigationControllerDelegate,UIGestureRecognizerDelegate {

    var popController: UIViewController?
    var scrollView: UIScrollView?
    
    private var isInteraction = false
    private var isPop = false
    private var edgeLeftBeganFloat: CGFloat = 0.0
    private var startDirection: TLPanDirectionType = .none
    private var lastPercentComplete: CGFloat = 0.0
    
    
    static let shared: TLPushTransitionDelegate = TLPushTransitionDelegate()
    
    private override init() {
    }
    
    public func addSystemGestureFor(viewController vc: UIViewController) {
        let edgePan = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(doInteractiveTypePop(_:)))
        edgePan.edges = .left
        vc.view.addGestureRecognizer(edgePan)
    }
    
    /// 自定义全屏手势
    ///
    /// - Parameters:
    ///   - viewController: VC
    ///   - directionTypes: 方向,传入 TLPanDirectionType.none.rawValue 则不添加任何自定义手势
    public func addPanGestureFor(viewController vc: UIViewController, directionTypes type: Int) {
        guard type == TLPanDirectionType.none.rawValue else { return }
        startDirection = .none
        
    }
    
    // MARK: 手势方法
    
    @objc private func doInteractiveTypePop(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        var percentComplete: CGFloat = 0.0
        // 左右滑动百分比
        percentComplete = translation.x / (UIApplication.shared.keyWindow?.frame.size.width)!
        percentComplete = abs(percentComplete)
        
        switch gesture.state {
        case .began:
            isInteraction = true
            popController?.navigationController?.popViewController(animated: true)
        case .changed:
            isInteraction = false
            update(percentComplete)
        case .ended:
            isInteraction = false
            if percentComplete > 0.3 {
                finish()
            }else {
                cancel()
            }
        default:
            isInteraction = false
            cancel()
        }
    }
    
    
    // MARK: === Delegate
    // MARK: ==- UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isMember(of: UIScreenEdgePanGestureRecognizer.self) {
            if otherGestureRecognizer.isMember(of: UIScreenEdgePanGestureRecognizer.self) {
                return false
            }
            if otherGestureRecognizer.isMember(of: UIPanGestureRecognizer.self) {
                return false
            }
        }
        guard gestureRecognizer.isMember(of: UIScreenEdgePanGestureRecognizer.self) &&
            (otherGestureRecognizer.isMember(of: UIScreenEdgePanGestureRecognizer.self) ||
                otherGestureRecognizer.isMember(of: UIPanGestureRecognizer.self)) else
        {
            return false
        }
        guard gestureRecognizer.isMember(of: UIPanGestureRecognizer.self) &&
            otherGestureRecognizer.isMember(of: UIScreenEdgePanGestureRecognizer.self) else
        {
            return false
        }
        return true
    }
    
    
    
}
