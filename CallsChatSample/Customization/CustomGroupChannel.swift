//
//  CustomGroupChannel.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 6/4/24.
//

import UIKit
import SendbirdChatSDK
import SendbirdUIKit
import SendBirdCalls

protocol CallDelegate: AnyObject {
    func didClickMakeCall(isVideo: Bool)
}

class CustomGroupChannelViewController: SBUGroupChannelViewController, CallDelegate {
    var remoteCallUserId: String? {
        guard let currentUserId = SendBirdCall.currentUser?.userId else { return nil }
        return channel?.members.first { $0.userId != currentUserId }?.userId
    }
    
    
    override func setupViews() {
        super.setupViews()

        ((inputComponent as? CustomInputComponent)?.messageInputView as? CustomMessageInputView)?.callDelegate = self
    }
    
    func didClickMakeCall(isVideo: Bool) {
        guard let channel = self.channel, let remoteCallUserId = self.remoteCallUserId else { return }
        let options = SendBirdChatOptions(channelURL: channel.channelURL)
        let params = DialParams(calleeId: remoteCallUserId, isVideoCall: isVideo, sendbirdChatOptions: options)
        
        SendBirdCall.dial(with: params) { call, error in
            guard let call = call, error == nil else {
                // Handle error
                return
            }
            
            CXCallManager.shared.startCXCall(call) { success in
                guard success else {
                    return
                }
                
                let callingViewController = CallingViewController(nibName: "CallingViewController", bundle: nil)
                callingViewController.call = call
                
                self.present(callingViewController, animated: true, completion: nil)
            }
        }
    }
    
    override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapMessage message: BaseMessage, forRowAt indexPath: IndexPath) {
        super.baseChannelModule(listComponent, didTapMessage: message, forRowAt: indexPath)

        guard let detail = message.getPluginDetail(for: "sendbird", type: "call"),
              let callInfo = CallInfo.make(from: detail), callInfo.endResult != .some(.none) else { return }
        didClickMakeCall(isVideo: callInfo.isVideoCall)
    }
    
}

class CustomListComponent: SBUGroupChannelModule.List {
    override func setupViews() {
        super.setupViews()
        
        self.register(customMessageCell: CallMessageCell())
    }
    
    override func generateCellIdentifier(by message: BaseMessage) -> String {
        let identifier = super.generateCellIdentifier(by: message)
        
        if let message = message as? UserMessage, message.getPluginDetail(for: "sendbird", type: "call") != nil {
            return CallMessageCell.sbu_className
        } else {
            return identifier
        }
    }
        
    override func configureCell(_ messageCell: SBUBaseMessageCell, message: BaseMessage, forRowAt indexPath: IndexPath) {
        super.configureCell(messageCell, message: message, forRowAt: indexPath)
        
        guard let channel = self.channel else { return }
        
        let isSameDay = self.checkSameDayAsNextMessage(
            currentIndex: indexPath.row,
            fullMessageList: fullMessageList
        )
        let receiptState = SBUUtils.getReceiptState(of: message, in: channel)
        let useReaction = channel.isSuper ?
        SBUAvailable.isSupportReactions(for: .superGroup) :
        SBUAvailable.isSupportReactions(for: .group) && !channel.isBroadcast
        let enableEmojiLongPress = !channel.isSuper
        
        switch (message, messageCell) {
        case let (callMessage, callMessageCell) as (UserMessage, CallMessageCell):
            
            let shouldHideSuggestedReplies = SendbirdUI.config.groupChannel.channel.showSuggestedRepliesFor.shouldHideSuggestedReplies(
                message: callMessage,
                fullMessageList: fullMessageList
            )
            
            let configuration = SBUUserMessageCellParams(
                message: callMessage,
                hideDateView: isSameDay,
                useMessagePosition: true,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                receiptState: receiptState,
                useReaction: useReaction,
                withTextView: true,
                joinedAt: self.channel?.joinedAt ?? 0,
                messageOffsetTimestamp: self.channel?.messageOffsetTimestamp ?? 0,
                shouldHideSuggestedReplies: shouldHideSuggestedReplies,
                shouldHideFormTypeMessage: false,
                enableEmojiLongPress: enableEmojiLongPress
            )
            configuration.shouldHideFeedback = message.myFeedbackStatus == .notApplicable
            callMessageCell.configure(with: configuration)
            callMessageCell.configure(highlightInfo: self.highlightInfo)
            (callMessageCell.quotedMessageView as? SBUQuotedBaseMessageView)?.delegate = self
            (callMessageCell.threadInfoView as? SBUThreadInfoView)?.delegate = self
            
            self.setMessageCellAnimation(callMessageCell, message: callMessage, indexPath: indexPath)
            self.setMessageCellGestures(callMessageCell, message: callMessage, indexPath: indexPath)
        default: break
        }
    }
}
