//
//  AppDelegate.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 5/31/24.
//

import UIKit
import CallKit
import PushKit

import SendbirdChatSDK
import SendbirdUIKit
import SendBirdCalls


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var queue: DispatchQueue = DispatchQueue(label: "com.sendbird.calls.quickstart.appdelegate")
    var voipRegistry: PKPushRegistry?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let appId = "C53EDF5A-9EEF-48EA-99D3-2139E20D2BEE"
        SendbirdUI.initialize(applicationId: appId) { _ in
            SendBirdCall.configure(appId: appId)
            SendBirdCall.executeOn(queue: .main)
        }
        SBCLogger.setLoggerLevel(.info)
        
        SBUGlobals.accessToken = ""
        SendbirdUI.config.common.isUsingDefaultUserProfileEnabled = true
        
        // Reply
        SendbirdUI.config.groupChannel.channel.replyType = .quoteReply
        // Channel List - Typing indicator
        SendbirdUI.config.groupChannel.channelList.isTypingIndicatorEnabled = true
        // Channel List - Message receipt state
        SendbirdUI.config.groupChannel.channelList.isMessageReceiptStatusEnabled = true
        // User Mention
        SendbirdUI.config.groupChannel.channel.isMentionEnabled = true
        // GroupChannel - Voice Message
        SendbirdUI.config.groupChannel.channel.isVoiceMessageEnabled = true
        // GroupChannel - suggested replies
        SendbirdUI.config.groupChannel.channel.isSuggestedRepliesEnabled = true
        // GroupChannel - form type message
        SendbirdUI.config.groupChannel.channel.isFormTypeMessageEnabled = true
        
        
        self.initializeRemoteNotification()
        
        
        SendBirdCall.addDelegate(self, identifier: "com.sendbird.sample4.calls.delegate")
        self.voipRegistration()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func initializeRemoteNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert]) { granted, error in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Register a device token to SendBird server.
        SendbirdUI.registerPush(deviceToken: deviceToken) { success in
            
        }
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    func voipRegistration() {
        self.voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        self.voipRegistry?.delegate = self
        self.voipRegistry?.desiredPushTypes = [.voIP]
    }
    
    // MARK: SendBirdCalls - Registering push token.
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        UserDefaults.standard.setValue(pushCredentials.token, forKey: "voipPushToken")
        
        SendBirdCall.registerVoIPPush(token: pushCredentials.token, unique: true) { error in
            guard error == nil else { return }
            print("Successfully registered VoIP Push token to Sendbird")
        }
    }
    
    // MARK: SendBirdCalls - Receive incoming push event
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type, completionHandler: nil)
    }
    
    // Handle Incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        // MARK: Handling incoming call
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) { uuid in
            guard uuid != nil else {
                let update = CXCallUpdate()
                update.remoteHandle = CXHandle(type: .generic, value: "invalid")
                let randomUUID = UUID()

                CXCallManager.shared.reportIncomingCall(with: randomUUID, update: update) { _ in
                    CXCallManager.shared.endCall(for: randomUUID, endedAt: Date(), reason: .acceptFailed)
                }
                completion()
                return
            }

            completion()
        }
    }
}

// MARK: - SendBirdCalls Delegates
extension AppDelegate: SendBirdCallDelegate, DirectCallDelegate {
    // MARK: SendBirdCallDelegate
    func didStartRinging(_ call: DirectCall) {
        call.delegate = self // To receive call event through `DirectCallDelegate`
        
        guard let uuid = call.callUUID else { return }
        guard CXCallManager.shared.shouldProcessCall(for: uuid) else { return }  // Should be cross-checked with state to prevent weird event processings
        
        // Use CXProvider to report the incoming call to the system
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let name = call.caller?.userId ?? "Unknown"
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: name)
        update.hasVideo = call.isVideoCall
        update.localizedCallerName = call.caller?.userId ?? "Unknown"
        
        // Report the incoming call to the system
        CXCallManager.shared.reportIncomingCall(with: uuid, update: update)
    }
    
    // MARK: DirectCallDelegate
    func didConnect(_ call: DirectCall) { }
    
    func didEnd(_ call: DirectCall) {
        var callId: UUID = UUID()
        if let callUUID = call.callUUID {
            callId = callUUID
        }
        
        CXCallManager.shared.endCall(for: callId, endedAt: Date(), reason: call.endResult)
    }
}
