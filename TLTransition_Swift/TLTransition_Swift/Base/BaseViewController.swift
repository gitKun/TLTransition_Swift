//
//  BaseViewController.swift
//  TLTransition_Swift
//
//  Created by DR_Kun on 2019/5/9.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    public var hideNavBar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }


}

let TLPanEdgeInside = 50


extension UIViewController {
    
    fileprivate struct TLTransitionRuntimeKey {
        static let isInteractionKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "isInteractionKey".hashValue)
        static let animationTypeKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "animationTypeKey".hashValue)
        static let panDirectionTypeKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "panDirectionTypeKey".hashValue)
    }
    
    var isInteractionKey: Bool {
        set {
            objc_setAssociatedObject(self, UIViewController.TLTransitionRuntimeKey.isInteractionKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, UIViewController.TLTransitionRuntimeKey.isInteractionKey) as? Bool ?? false
        }
    }
    
    var animationType: TLAnimationType {
        set {
            objc_setAssociatedObject(self, UIViewController.TLTransitionRuntimeKey.animationTypeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, UIViewController.TLTransitionRuntimeKey.animationTypeKey) as? TLAnimationType ?? .none
        }
    }
    
    var panDirectionType: TLPanDirectionType {
        set {
            objc_setAssociatedObject(self, UIViewController.TLTransitionRuntimeKey.panDirectionTypeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, UIViewController.TLTransitionRuntimeKey.panDirectionTypeKey) as? TLPanDirectionType ?? .none
        }
    }
}

// MARK: 增加方法
extension UIViewController {
    public func tlPresent(_ vc: UIViewController, animationType: TLAnimationType, animated flag: Bool, completion: (() -> Void)? = nil) {
        if animationType == .bottomViewAlert {
            
        }
        present(vc, animated: flag, completion: completion)
    }
}


// MARK: UIViewController 方法交换
extension UIViewController: DRSelfAware {
    
    @objc class func dr_awake() {
        UIViewController.swizzleMethod
    }
    
    @objc func swizzled_viewWillAppear(_ animated: Bool) {
        
        if animationType == .viewFame || animationType == .windowScale || animationType == .appStore {
            navigationController?.interactivePopGestureRecognizer?.delegate = TLPushTransitionDelegate.shared
            navigationController?.delegate = TLPushTransitionDelegate.shared
            TLPushTransitionDelegate.shared.popController = self
        }
        
        swizzled_viewWillAppear(animated)
    }
    
    @objc fileprivate func swizzled_Present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        // 防止 UIModalPresentationCustom 模式 pre,dis变形
        if modalPresentationStyle == .custom {
            viewControllerToPresent.modalPresentationStyle = .overFullScreen
        }
        swizzled_Present(viewControllerToPresent, animated: animated, completion: completion)
    }
    
    private static let swizzleMethod: Void = {
        
        let originalSelector = #selector(viewWillAppear(_:))
        let swizzledSelector = #selector(swizzled_viewWillAppear(_:))
        swizzlingForClass(UIViewController.self, originalSelector: originalSelector, swizzledSelector: swizzledSelector)
 
        let originalPresentSelector = #selector(present(_:animated:completion:))
        let swizzledPresentSelector = #selector(swizzled_Present(_:animated:completion:))
        swizzlingForClass(UIViewController.self, originalSelector: originalPresentSelector, swizzledSelector: swizzledPresentSelector)
    }()
    
    @objc class func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(forClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
        
        guard originalMethod != nil && swizzledMethod != nil else {
            return
        }
        if class_addMethod(forClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!)) {
            class_replaceMethod(forClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        }else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
}
