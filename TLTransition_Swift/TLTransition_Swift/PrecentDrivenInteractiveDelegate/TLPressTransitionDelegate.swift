//
//  TLPressTransitionDelegate.swift
//  TLTransition_Swift
//
//  Created by DR_Kun on 2019/5/15.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

import UIKit

class TLPressTransitionDelegate: UIPercentDrivenInteractiveTransition, UIViewControllerTransitioningDelegate {
    
    weak var disMissController: UIViewController?
    weak var scrollView: UIScrollView?
    
    private var isInteraction = false
    private var isMiss = false
    private var edgeLeftBeganFloat: CGFloat = 0.0
    private var startDirection = TLPanDirectionType.none
    private var lastPercentComplate: CGFloat = 0.0
    
    static let shared = TLPressTransitionDelegate()
    
    fileprivate override init() {
    }
    
    public func addSystemEdgeLeftGestureFor(_ viewController: UIViewController) {
        
    }
    
    public func addPanGestureFor(_ viewController: UIViewController, directionTypes: TLPanDirectionType) {
        
    }
    
    
}


extension TLPressTransitionDelegate {
    func handleGesture(_ gesture: UIPanGestureRecognizer, percentComplete: CGFloat, directionType: TLPanDirectionType) {
        var pCom = percentComplete
        // 对于不包含的手势禁止动画
        if (disMissController?.panDirectionType.rawValue ?? 0) & directionType.rawValue == 0 {
            pCom = 0
        }
        if directionType == .edgeLeft {
            
        }
    }
}

extension TLPressTransitionDelegate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


extension TLPressTransitionDelegate {
    /// pres 动画
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isMiss = false
        if presented.animationType == .bottomViewAlert {
            return nil;
        }
        return nil
    }
    /// dis 动画
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isMiss = true
        if dismissed.animationType == .bottomViewAlert {
            return nil
        }
        return nil
    }
    /// 是否返回交互
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if isMiss {
            return isInteraction ? self : nil
        }
        return nil
    }
}
