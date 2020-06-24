//
//  ViewController.swift
//  UtilDemo
//
//  Created by JerryHU on 2020/6/24.
//  Copyright © 2020 jerryHU. All rights reserved.
//

import UIKit

class NNUserInfo: NSObject {
    var account:String?
    var password:String?
}

class ViewController: UIViewController {
    
    var spreadButton: SpreadButton!
    var timer : Timer?
    let getKeyData = KeychainManager.getKeyInKeyChain(identifier: KeychainManager.keychain.identifierStr!)
    lazy var key:Data = {
        var key = Data(count: 64)
        _ = key.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 64, bytes)}
        return key
    }()
    let userInfo = NNUserInfo()
    @IBOutlet weak var accountInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var modiflyBtn: UIButton!
    @IBOutlet weak var cleanBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .groupTableViewBackground
        setUpAssistiveTouch()
        if spreadButton != nil {
            view.addSubview(spreadButton)
        }
        saveKeychain()
    }
    
    func saveKeychain() {
        if getKeyData.count > 0 {
            UserInfoData.userInfo = UserInfoData().getUserData()
            accountInput.text = UserInfoData.userInfo.account
            passwordInput.text = UserInfoData.userInfo.password
        } else {
            // 存储数据
            let saveKeyBool = KeychainManager.keyChainSaveData(data: key as Any, withIdentifier: KeychainManager.keychain.identifierStr!)
            if saveKeyBool {
                print("存储成功")
            }else{
                print("存储失败")
            }
        }
        initUI(haveData: getKeyData.count > 0 && !UserInfoData.userInfo.account.isEmpty && !UserInfoData.userInfo.password.isEmpty)
    }
    
    func initUI(haveData:Bool) {
        saveBtn.isHidden = haveData
        saveBtn.layer.cornerRadius = 10.0
        saveBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
        
        modiflyBtn.isHidden = !haveData
        modiflyBtn.layer.cornerRadius = 10.0
        modiflyBtn.addTarget(self, action: #selector(modiflyBtnClick), for: .touchUpInside)
        
        cleanBtn.layer.cornerRadius = 10.0
        cleanBtn.addTarget(self, action: #selector(cleanBtnClick), for: .touchUpInside)
    }
    
    @objc func saveBtnClick() {
        view.endEditing(true)
        let account = accountInput.text
        let password = passwordInput.text
        if account!.isEmpty {
            NNShowToast(message: "please enter account", duration: 1, position: NNToastPositionDefault)
            return
        }
        if password!.isEmpty {
            NNShowToast(message: "please enter password", duration: 1, position: NNToastPositionDefault)
            return
        }
        userInfo.account = account
        userInfo.password = password
        
        let userInfoData = UserInfoData()
        userInfoData.saveUserInfo(userInfo: userInfo, key:key)
        UserInfoData.userInfo = UserInfoData().getUserData()
        NNShowLoadingHud(message: "Loading........")
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(showSaveSuccessToast), userInfo: nil, repeats: false)
    }
    
    @objc func modiflyBtnClick() {
        view.endEditing(true)
        let account = accountInput.text
        let password = passwordInput.text
        if account != UserInfoData.userInfo.account {
            try! UserInfoData().getRealm().write {
                UserInfoData.userInfo.account = account!
            }
        }
        
        if password != UserInfoData.userInfo.password {
            try! UserInfoData().getRealm().write {
                UserInfoData.userInfo.password = password!
            }
        }
        NNShowLoadingHud(message: "Loading........")
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(showModiflySuccessToast), userInfo: nil, repeats: false)
    }
    
    @objc func cleanBtnClick() {
        view.endEditing(true)
        UserInfoData().removeAll(key: getKeyData)
        NNShowLoadingHud(message: "Loading........")
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(showCleanSuccessToast), userInfo: nil, repeats: false)
    }
    
    func setUpAssistiveTouch() {
        let btn1 = SpreadSubButton(backgroundImage: UIImage(named: "ic_assistive_back"), highlightImage: nil) { (index, sender) -> Void in
            NNShowToast(message: "I'm a Toast", duration: 1, position: NNToastPositionDefault)
        }
        
        let btn2 = SpreadSubButton(backgroundImage: UIImage(named: "ic_assistive_recharge"), highlightImage: nil) { (index, sender) -> Void in
            NNShowLoadingHud(message: "Loading........")
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.stopHud), userInfo: nil, repeats: false)
        }
        
        let btn3 = SpreadSubButton(backgroundImage: UIImage(named: "ic_assistive_refresh"), highlightImage: nil) { (index, sender) -> Void in
            if UserInfoData.userInfo.account.isEmpty || UserInfoData.userInfo.password.isEmpty {
                NNShowToast(message: "You have not saved the information", duration: 1, position: NNToastPositionDefault)
                return
            }
            NNShowToast(message: "account: \(UserInfoData.userInfo.account), password: \(UserInfoData.userInfo.password)", duration: 1, position: NNToastPositionDefault)
        }
        
        spreadButton = SpreadButton.init(image: UIImage(named: "ic_assistive_main"), highlightImage: nil, position: CGPoint.init(x: screenWidth() - 40, y:screenHeight() - 40))
        spreadButton.setSubButtons([btn1, btn2, btn3])
        //展開模式
        spreadButton.mode = SpreadMode.spreadModeSickleSpread
        //展開方向
        spreadButton.direction = SpreadDirection.spreadDirectionLeftUp
        //展開距離
        spreadButton.radius = 100
        //主按鈕可移動或不可移動
        spreadButton.positionMode = SpreadPositionMode.spreadPositionModeTouchBorder
        //矇層
        spreadButton.coverAlpha = 0.5
    }
    
    @objc func stopHud() {
        NNStopShowLoadingHud()
        timer?.invalidate()
    }
    
    @objc func showSaveSuccessToast() {
        saveBtn.isHidden = true
        modiflyBtn.isHidden = false
        NNStopShowLoadingHud()
        NNShowToast(message: "Save Success", duration: 1, position: NNToastPositionDefault)
        timer?.invalidate()
    }
    
    @objc func showModiflySuccessToast() {
        NNStopShowLoadingHud()
        NNShowToast(message: "Modifly Success", duration: 1, position: NNToastPositionDefault)
        timer?.invalidate()
    }
    
    @objc func showCleanSuccessToast() {
        NNStopShowLoadingHud()
        NNShowToast(message: "Clean Success", duration: 1, position: NNToastPositionDefault)
        timer?.invalidate()
        saveKeychain()
    }
    
}

