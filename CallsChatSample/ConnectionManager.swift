//
//  ConnectionManager.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 5/31/24.
//

import Foundation
import SendbirdUIKit
import SendBirdCalls

class ConnectionManager {
    struct Config {
//        let appId: String
        let userId: String
        let accessToken: String?
        
        static func createFromUserDefaults() -> Config? {
            guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                      return nil
                  }
            
            let accessToken = UserDefaults.standard.value(forKey: "accessToken") as? String
            return Config(userId: userId, accessToken: accessToken)
        }
    }
    
//    static var config: Config?
    
    static func disconnect(completionHandler: (() -> Void)?) {
        if let pushToken = UserDefaults.standard.value(forKey: "voipPushToken") as? Data {
            SendbirdUI.unregisterPushToken { _ in }
            SendBirdCall.unregisterVoIPPush(token: pushToken, completionHandler: nil)
        }
        
        SendbirdUI.disconnect {
            SendBirdCall.deauthenticate { _ in
                UserDefaults.standard.removeObject(forKey: "userId")
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "voipPushToken")
                
                completionHandler?()
            }
        }
    }
    
    
    static func connect(config: Config? = nil, completionHandler: ((Error?) -> Void)?) {
        guard let config = config ?? Config.createFromUserDefaults() else {
            completionHandler?(nil) // TODO: FIXME
            return
        }
        
//        SendbirdUI.initialize(applicationId: config.appId) { _ in
            SBUGlobals.currentUser = .init(userId: config.userId)
            SBUGlobals.accessToken = config.accessToken
//            SBUGlobals.applicationId = config.appId
            
//            SendBirdCall.configure(appId: config.appId)
            SendBirdCall.executeOn(queue: .main)
            
            SendbirdUI.connect { user, error in
                guard let user = user, error == nil else {
                    completionHandler?(error)
                    return
                }
                
                let params = AuthenticateParams(userId: config.userId, accessToken: config.accessToken)
                SendBirdCall.authenticate(with: params) { user, error in
                    guard user != nil, error == nil else {
                        completionHandler?(error)
                        return
                    }
                    
                    if let pushToken = UserDefaults.standard.value(forKey: "voipPushToken") as? Data {
                        SendBirdCall.registerVoIPPush(token: pushToken) { error in
                            print("Registered VoIP push with error: \(error)")
                        }
                    }
 
                    UserDefaults.standard.set(config.userId, forKey: "userId")
                    UserDefaults.standard.set(config.accessToken, forKey: "accessToken")
//                    UserDefaults.standard.set(config.appId, forKey: "applicationId")
                    
                    completionHandler?(nil)
                }
            }
//        }
    }
}
