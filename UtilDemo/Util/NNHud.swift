//
//  NNHud.swift
//  FengHuang
//
//  Created by dev10001 fh on 20/08/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

func NNShowToast(message:String, duration:Double, position: String) {
    keyWindow?.makeToast(message: message, duration: duration, position: position)
}
func NNShowLoadingHud(message:String) {
    keyWindow?.makeToastActivity(message: message)
}
func NNStopShowLoadingHud() {
    keyWindow?.hideToastActivity()
}

func /(lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs / CGFloat(rhs)
}

public struct NNToastConfig {
    var NNToastDefaultDuration = 2.0
    var NNToastFadeDuration = 0.2
    var NNToastHorizontalMargin:CGFloat = 10.0
    var NNToastVerticalMargin:CGFloat = 10.0
    
    var NNToastPositionVerticalOffset:CGFloat = 40.0
    var NNToastPosition = "bottom"
    var NNToastzPosition:CGFloat = 2.0
    
    // activity
    var NNToastActivityWidth:CGFloat = UIScreen.main.bounds.size.width
    var NNToastActivityHeight:CGFloat = UIScreen.main.bounds.size.height
    var NNToastActivityPositionDefault = "center"
    
    // label setting
    var NNToastMaxWidth:CGFloat = 0.6 // 60% of parent view width
    var NNToastMaxHeight:CGFloat = 0.8
    var NNToastFontSize:CGFloat = 16.0
    var NNToastMaxTitleLines = 0
    var NNToastMaxMessageLines = 0
    
    var NNToastOpacity:CGFloat = 0.5
    var NNToastCornerRadius:CGFloat = 10.0
    
    var NNToastHidesOnTap = true
    var NNToastDisplayShadow = true
    
    public init() {}
}

let NNToastPositionDefault = "bottom"
let NNToastPositionTop = "top"
let NNToastPositionCenter = "center"

var NNToastActivityView: UnsafePointer<UIView>? = nil
var NNToastTimer: UnsafePointer<Timer>? = nil
var NNToastView: UnsafePointer<UIView>? = nil
var NNToastThemeColor : UnsafePointer<UIColor>? = nil
var NNToastTitleFontName: UnsafePointer<String>? = nil
var NNToastFontName: UnsafePointer<String>? = nil
var NNToastFontColor: UnsafePointer<UIColor>? = nil

var indicatorStyle:UIActivityIndicatorView.Style = {
    if #available(iOS 13.0, *) {
        return UIActivityIndicatorView.Style.large
    }
    return UIActivityIndicatorView.Style.whiteLarge
}()

let defaults = NNToastConfig()

public extension UIView {
    
    class func nn_setToastThemeColor(color: UIColor) {
        objc_setAssociatedObject(self, &NNToastThemeColor, color, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func nn_toastThemeColor() -> UIColor {
        var color = objc_getAssociatedObject(self, &NNToastThemeColor) as! UIColor?
        if color == nil {
            color = UIColor.black
            UIView.nn_setToastThemeColor(color: color!)
        }
        return color!
    }
    
    class func nn_setToastTitleFontName(fontName: String) {
        objc_setAssociatedObject(self, &NNToastTitleFontName, fontName, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func nn_toastTitleFontName() -> String {
        var name = objc_getAssociatedObject(self, &NNToastTitleFontName) as! String?
        if name == nil {
            let font = UIFont.systemFont(ofSize: 12.0)
            name = font.fontName
            UIView.nn_setToastTitleFontName(fontName: name!)
        }
        
        return name!
    }
    
    class func nn_setToastFontName(fontName: String) {
        objc_setAssociatedObject(self, &NNToastFontName, fontName, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func nn_toastFontName() -> String {
        var name = objc_getAssociatedObject(self, &NNToastFontName) as! String?
        if name == nil {
            let font = UIFont.systemFont(ofSize: 12.0)
            name = font.fontName
            UIView.nn_setToastFontName(fontName: name!)
        }
        
        return name!
    }
    
    class func nn_setToastFontColor(color: UIColor) {
        objc_setAssociatedObject(self, &NNToastFontColor, color, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func nn_toastFontColor() -> UIColor {
        var color = objc_getAssociatedObject(self, &NNToastFontColor) as! UIColor?
        if color == nil {
            color = UIColor.white
            UIView.nn_setToastFontColor(color: color!)
        }
        
        return color!
    }
    
    func makeToast(message msg: String, withConfiguration config: NNToastConfig = NNToastConfig()) {
        makeToast(message: msg, duration: config.NNToastDefaultDuration, position: config.NNToastPosition, withConfiguration: config)
    }
    
    func makeToast(message msg: String, duration: Double, position: String, withConfiguration config: NNToastConfig = NNToastConfig()) {
        let toast = self.viewForMessage(msg, title: nil, withConfiguration: config)
        showToast(toast: toast!, duration: duration, position: position, withConfiguration: config)
    }
    
    func makeToast(message msg: String, duration: Double, position: String, title: String, withConfiguration config: NNToastConfig = NNToastConfig()) {
        let toast = self.viewForMessage(msg, title: title, withConfiguration: config)
        showToast(toast: toast!, duration: duration, position: position, withConfiguration: config)
    }
    
    func showToast(toast: UIView, withConfiguration config: NNToastConfig = NNToastConfig()) {
        showToast(toast: toast, duration: config.NNToastDefaultDuration, position: config.NNToastPosition, withConfiguration: config)
    }
    
    fileprivate func showToast(toast: UIView, duration: Double, position: String, withConfiguration config: NNToastConfig) {
        let existToast = objc_getAssociatedObject(self, &NNToastView) as! UIView?
        if existToast != nil {
            if let timer: Timer = objc_getAssociatedObject(existToast as Any, &NNToastTimer) as? Timer {
                timer.invalidate()
            }
            hideToast(toast: existToast!, force: false, withConfiguration: config)
        }
        
        toast.alpha = 0.0
        
        if config.NNToastHidesOnTap {
            let tapRecognizer = UITapGestureRecognizer(target: toast, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(tapRecognizer)
            toast.isUserInteractionEnabled = true
            toast.isExclusiveTouch = true
        }
        
        addSubview(toast)
        let sidePadding = self.bounds.width * (1 - config.NNToastMaxWidth) / 5
        toast.leftAnchor.constraint(equalTo: self.leftAnchor, constant: sidePadding).isActive = true
        toast.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -sidePadding).isActive = true
        
        let desiredSize = toast.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let yPosition = yPositionForToastPosition(position, toastSize: desiredSize, withConfiguration: config)
        toast.centerYAnchor.constraint(equalTo: self.topAnchor, constant: yPosition).isActive = true
        objc_setAssociatedObject(self, &NNToastView, toast, .OBJC_ASSOCIATION_RETAIN)
        
        UIView.animate(withDuration: config.NNToastFadeDuration,
                       delay: 0.0, options: ([.curveEaseOut, .allowUserInteraction]),
                       animations: {
                        toast.alpha = 1.0
        },
                       completion: { (finished: Bool) in
                        let timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
                        objc_setAssociatedObject(toast, &NNToastTimer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    func makeToastActivity(withConfiguration config: NNToastConfig = NNToastConfig()) {
        makeToastActivity(position: config.NNToastActivityPositionDefault, withConfiguration: config)
    }
    
    func makeToastActivity(message msg: String, withConfiguration config: NNToastConfig = NNToastConfig()){
        makeToastActivity(position: config.NNToastActivityPositionDefault, message: msg, withConfiguration: config)
    }
    
    fileprivate func makeToastActivity(position pos: String, message msg: String = "", withConfiguration config: NNToastConfig) {
        let existingActivityView: UIView? = objc_getAssociatedObject(self, &NNToastActivityView) as? UIView
        if existingActivityView != nil { return }
        
        let activityView = UIView(frame: CGRect(x: 0, y: 0, width: config.NNToastActivityWidth, height: config.NNToastActivityHeight))
        activityView.center = self.centerPointForPosition(pos, toast: activityView, withConfiguration: config)
        activityView.backgroundColor = UIView.nn_toastThemeColor().withAlphaComponent(config.NNToastOpacity)
        activityView.autoresizingMask = ([.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin])
        
        let indicatorViewBgView = UIView.init(frame: CGRect(x: activityView.bounds.size.width / 2 - 50, y: activityView.bounds.size.height / 2 - 50, width: 100, height: 100))
        indicatorViewBgView.backgroundColor = UIView.nn_toastThemeColor().withAlphaComponent(config.NNToastOpacity)
        indicatorViewBgView.layer.cornerRadius = config.NNToastCornerRadius
        activityView.addSubview(indicatorViewBgView)
        
        let activityIndicatorView = UIActivityIndicatorView(style: indicatorStyle)
        activityIndicatorView.color = .white
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width / 2, y: activityView.bounds.size.height / 2)
        activityView.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
        
        if (!msg.isEmpty){
            activityIndicatorView.frame.origin.y -= 10
            let activityMessageLabel = UILabel(frame: CGRect(x: activityView.bounds.origin.x, y: (activityIndicatorView.frame.origin.y + activityIndicatorView.frame.size.height + 10), width: activityView.bounds.size.width, height: 20))
            activityMessageLabel.textColor = UIView.nn_toastFontColor()
            activityMessageLabel.font = (msg.count<=10) ? UIFont(name:UIView.nn_toastFontName(), size: 16) : UIFont(name:UIView.nn_toastFontName(), size: 13)
            activityMessageLabel.textAlignment = .center
            activityMessageLabel.text = msg
            activityView.addSubview(activityMessageLabel)
        }
        
        addSubview(activityView)
        
        // associate activity view with self
        objc_setAssociatedObject(self, &NNToastActivityView, activityView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        UIView.animate(withDuration: config.NNToastFadeDuration,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                        activityView.alpha = 1.0
        },
                       completion: nil)
    }
    
    func hideToastActivity(withConfiguration config: NNToastConfig = NNToastConfig()) {
        let existingActivityView = objc_getAssociatedObject(self, &NNToastActivityView) as! UIView?
        if existingActivityView == nil { return }
        UIView.animate(withDuration: config.NNToastFadeDuration,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                        existingActivityView!.alpha = 0.0
        },
                       completion: { (finished: Bool) in
                        existingActivityView!.removeFromSuperview()
                        objc_setAssociatedObject(self, &NNToastActivityView, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    /*
     *  private methods (helper)
     */
    func hideToast(toast: UIView) {
        hideToast(toast: toast, force: false, withConfiguration: NNToastConfig())
    }
    
    func hideToast(toast: UIView, force: Bool, withConfiguration config: NNToastConfig) {
        let completeClosure = { (finish: Bool) -> () in
            toast.removeFromSuperview()
            objc_setAssociatedObject(self, &NNToastTimer, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if force {
            completeClosure(true)
        } else {
            UIView.animate(withDuration: config.NNToastFadeDuration,
                           delay: 0.0,
                           options: ([.curveEaseIn, .beginFromCurrentState]),
                           animations: {
                            toast.alpha = 0.0
            },
                           completion:completeClosure)
        }
    }
    
    @objc func toastTimerDidFinish(_ timer: Timer) {
        hideToast(toast: timer.userInfo as! UIView)
    }
    
    @objc func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        let timer = objc_getAssociatedObject(self, &NNToastTimer) as? Timer
        
        if let timer = timer {
            timer.invalidate()
        }
        
        hideToast(toast: recognizer.view!)
    }
    
    fileprivate func yPositionForToastPosition(_ position: String, toastSize: CGSize, withConfiguration config: NNToastConfig) -> CGFloat {
        let viewSize  = self.bounds.size
        
        if position == NNToastPositionTop {
            return toastSize.height/2 + config.NNToastPositionVerticalOffset
        } else if position == NNToastPositionDefault {
            return viewSize.height - toastSize.height - config.NNToastPositionVerticalOffset - bottomPadding
        } else if position == NNToastPositionCenter {
            return viewSize.height/2
        }
        
        print("[Toast-Swift]: Warning! Invalid position for toast.")
        return viewSize.height/2
    }
    
    fileprivate func centerPointForPosition(_ position: String, toast: UIView, withConfiguration config: NNToastConfig) -> CGPoint {
        
        let toastSize = toast.bounds.size
        let viewSize  = self.bounds.size
        if position == NNToastPositionTop {
            return CGPoint(x: viewSize.width/2, y: toastSize.height/2 + config.NNToastVerticalMargin)
        } else if position == NNToastPositionDefault {
            return CGPoint(x: viewSize.width/2, y: viewSize.height - toastSize.height/2 - config.NNToastVerticalMargin)
        } else if position == NNToastPositionCenter {
            return CGPoint(x: viewSize.width/2, y: viewSize.height/2)
        }
        
        print("[Toast-Swift]: Warning! Invalid position for toast.")
        return self.centerPointForPosition(config.NNToastPosition, toast: toast, withConfiguration: config)
    }
    
    fileprivate func viewForMessage(_ msg: String?, title: String?, withConfiguration config: NNToastConfig) -> UIView? {
        if msg == nil && title == nil { return nil }
        
        let someTextBeingShown = (msg != nil || title != nil)
        let wrapperView = createInitialView(withConfiguration: config)
        let contentsStackView = addContentsStackView(toWrapperView: wrapperView, withConfiguration: config)
        
        if someTextBeingShown {
            addMessage(msg, andTitle: title, toStackView: contentsStackView, withConfiguration: config)
        }
        
        return wrapperView
    }
    
    fileprivate func createInitialView(withConfiguration config: NNToastConfig) -> UIView {
        let initialView = UIView()
        initialView.translatesAutoresizingMaskIntoConstraints = false
        initialView.layer.cornerRadius = config.NNToastCornerRadius
        initialView.layer.zPosition = config.NNToastzPosition
        initialView.backgroundColor = UIView.nn_toastThemeColor().withAlphaComponent(config.NNToastOpacity)
        return initialView
    }
    
    fileprivate func addContentsStackView(toWrapperView wrapperView: UIView, withConfiguration config: NNToastConfig) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor.clear
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = config.NNToastVerticalMargin
        stackView.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        stackView.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        wrapperView.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: wrapperView.centerXAnchor).isActive = true
        let leftSideConstraint = stackView.leftAnchor.constraint(greaterThanOrEqualTo: wrapperView.leftAnchor, constant: config.NNToastHorizontalMargin)
        leftSideConstraint.priority = UILayoutPriority(rawValue: 1000)
        leftSideConstraint.isActive = true
        let rightSideConstraint = stackView.rightAnchor.constraint(lessThanOrEqualTo: wrapperView.rightAnchor, constant: -config.NNToastHorizontalMargin)
        rightSideConstraint.priority = UILayoutPriority(rawValue: 1000)
        rightSideConstraint.isActive = true
        let leftSideEqualConstraint = stackView.leftAnchor.constraint(equalTo: wrapperView.leftAnchor, constant: config.NNToastHorizontalMargin)
        leftSideEqualConstraint.priority = UILayoutPriority(rawValue: 250)
        leftSideEqualConstraint.isActive = true
        let rightSideEqualConstraint = stackView.rightAnchor.constraint(equalTo: wrapperView.rightAnchor, constant: -config.NNToastHorizontalMargin)
        rightSideEqualConstraint.priority = UILayoutPriority(rawValue: 250)
        rightSideEqualConstraint.isActive = true
        stackView.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: config.NNToastVerticalMargin).isActive = true
        stackView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: -config.NNToastVerticalMargin).isActive = true
        
        return stackView
    }
    
    fileprivate func addMessage(_ msg: String?, andTitle title: String?, toStackView parentStackView: UIStackView, withConfiguration config: NNToastConfig) {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor.clear
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = config.NNToastVerticalMargin
        parentStackView.addArrangedSubview(stackView)
        
        stackView.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        stackView.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        if let title = title {
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.numberOfLines = config.NNToastMaxTitleLines
            titleLabel.font = UIFont(name: UIView.nn_toastFontName(), size: config.NNToastFontSize)
            titleLabel.textAlignment = .center
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.textColor = UIView.nn_toastFontColor()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.alpha = 1.0
            titleLabel.text = title
            
            titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 751), for: .vertical)
            stackView.addArrangedSubview(titleLabel)
        }
        
        if let msg = msg {
            let msgLabel = UILabel()
            msgLabel.translatesAutoresizingMaskIntoConstraints = false
            msgLabel.numberOfLines = config.NNToastMaxMessageLines
            msgLabel.font = UIFont(name: UIView.nn_toastFontName(), size: config.NNToastFontSize)
            msgLabel.lineBreakMode = .byWordWrapping
            msgLabel.textAlignment = .center
            msgLabel.textColor = UIView.nn_toastFontColor()
            msgLabel.backgroundColor = UIColor.clear
            msgLabel.alpha = 1.0
            msgLabel.text = msg
            
            msgLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 751), for: .vertical)
            stackView.addArrangedSubview(msgLabel)
        }
    }
    
}

