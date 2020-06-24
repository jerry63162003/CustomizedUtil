//
//  RealmObject.swift
//  FengHuang
//
//  Created by dev10001 fh on 15/08/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class UserInfoData: Object {
    public static var userInfo = UserInfoData().getUserData()
    
    @objc dynamic var account:String = ""
    @objc dynamic var password:String = ""
    
    let keyData = KeychainManager.getKeyInKeyChain(identifier: KeychainManager.keychain.identifierStr!)
    
    func getRealm()->Realm {
        let config = Realm.Configuration(encryptionKey: keyData)
        let realm:Realm
        do {
            realm = try Realm(configuration: config)
        } catch let error as NSError {
            // 如果密钥错误，error 会提示数据库不可访问
            fatalError("Error opening realm: \(error)")
        }
        return realm
    }
    
    func saveUserInfo(userInfo:NNUserInfo, key:Data) {
        account = userInfo.account!
        password = userInfo.password!
        
        // 打开加密文件
        let config = Realm.Configuration(
            encryptionKey: keyData,
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
        })
        print("key:\(config)")
        let realm:Realm
        do {
            realm = try Realm(configuration: config)
        } catch let error as NSError {
            // 如果密钥错误，error 会提示数据库不可访问
            fatalError("Error opening realm: \(error)")
        }
        try! realm.write {
            realm.add(self)
        }
    }
    
    func getUserData() -> UserInfoData {
        let config = Realm.Configuration(
            encryptionKey: keyData,
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
        })
        let realm:Realm
        do {
            realm = try Realm(configuration: config)
        } catch let error as NSError {
            // 如果密钥错误，error 会提示数据库不可访问
            fatalError("Error opening realm: \(error)")
        }
        return realm.objects(UserInfoData.self).last ?? UserInfoData()
    }
    
    func removeAll(key:Data) {
        let config = Realm.Configuration(
            encryptionKey: keyData,
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
        })
//        let config = Realm.Configuration(encryptionKey: key)
        var realm:Realm
        do {
            realm = try Realm(configuration: config)
        } catch let error as NSError {
            // 如果密钥错误，error 会提示数据库不可访问
            fatalError("Error opening realm: \(error)")
        }
        try! realm.write {
            realm.deleteAll()
        }
    }
    
}
