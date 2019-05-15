//
//  BaseNavigationController.swift
//  TLTransition_Swift
//
//  Created by DR_Kun on 2019/5/9.
//  Copyright © 2019 DR_Kun. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

// MARK:  UINavigationController 增加存储属性
extension UINavigationController {
    
    private struct TLTransitionRuntimeKey {
        static let hideNavBarKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "hideNavBarKey".hashValue)
        static let indexKey: UnsafeRawPointer! = UnsafeRawPointer.init(bitPattern: "indexKey".hashValue)
    }
    
    var hideNavBar: Bool {
        set {
            objc_setAssociatedObject(self, UINavigationController.TLTransitionRuntimeKey.hideNavBarKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, UINavigationController.TLTransitionRuntimeKey.hideNavBarKey) as? Bool ?? false
        }
    }
    
    var index: Int {
        set {
            objc_setAssociatedObject(self, UINavigationController.TLTransitionRuntimeKey.indexKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, UINavigationController.TLTransitionRuntimeKey.indexKey) as? Int ?? 0
        }
    }
}

// MARK: UINavigationController 增加方法
extension UINavigationController {
    
    func tlPush(viewController: UIViewController, tlAnimationType: TLAnimationType){
        switch tlAnimationType {
        case .viewFame:
            TLPushTransitionDelegate.shared.popController = viewController
            TLPushTransitionDelegate.shared.addSystemGestureFor(viewController: viewController)
//            viewController.
        default:
            print("DNT")
        }
    }
    
    
    
    // MARK: 方法交换
    @objc override class func dr_awake() {
        UINavigationController.swizzleMethod
    }

    private static let swizzleMethod: Void = {
        let originalInitSelector = #selector(UINavigationController.init(rootViewController:))
        let swizzledInitSelector = #selector(swizzInit(rootViewController:))
        swizzlingForClass(UINavigationController.self, originalSelector: originalInitSelector, swizzledSelector: swizzledInitSelector)
    }()
    
    @objc fileprivate func swizzInit(rootViewController: UIViewController) -> UINavigationController {
        interactivePopGestureRecognizer?.delegate = TLPushTransitionDelegate.shared
        delegate = TLPushTransitionDelegate.shared
        return swizzInit(rootViewController: rootViewController)
    }

    override class func swizzlingForClass(_ forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
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
