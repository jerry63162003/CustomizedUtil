//
//  SystemUtil.swift
//  UtilDemo
//
//  Created by JerryHU on 2020/6/24.
//  Copyright © 2020 jerryHU. All rights reserved.
//

import UIKit

var keyWindow: UIWindow? = {
    if #available(iOS 13.0, *) {
        return UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    }
    return UIApplication.shared.keyWindow
}()

var statusBarHeight: CGFloat? = {
    if #available(iOS 13.0, *) {
        return keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    return UIApplication.shared.statusBarFrame.size.height
}()

let bottomPadding = keyWindow?.safeAreaInsets.bottom ?? 0

func screenWidth() -> CGFloat {
    return UIScreen.main.bounds.size.width
}

func screenHeight() -> CGFloat {
    return UIScreen.main.bounds.size.height
}
