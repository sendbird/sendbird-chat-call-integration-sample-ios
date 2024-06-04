//
//  CustomInputView.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 6/4/24.
//

import UIKit
import SendbirdChatSDK
import SendbirdUIKit
import SendBirdCalls

class CustomMessageInputView: SBUMessageInputView {
    weak var callDelegate: CallDelegate?
    
    override func generateResourceItems() -> [SBUActionSheetItem] {
        var items = super.generateResourceItems()
        
        let voiceCallItem = SBUActionSheetItem(
            title: "Make a voice call",
            image: UIImage(named: "icCallFilled")?.sbu_with(tintColor: SBUColorSet.primary300)
        )
        let videoCallItem = SBUActionSheetItem(
            title: "Make a voice call",
            image: UIImage(named: "icCallVideoFilled")?.sbu_with(tintColor: SBUColorSet.primary300)
        )
        
        items.append(contentsOf: [voiceCallItem, videoCallItem])
        return items
    }
    
    override func didSelectActionSheetItem(index: Int, identifier: Int) {
        switch index {
        case 3: callDelegate?.didClickMakeCall(isVideo: false)
        case 4: callDelegate?.didClickMakeCall(isVideo: true)
        default: super.didSelectActionSheetItem(index: index, identifier: identifier)
        }
    }
}


class CustomInputComponent: SBUGroupChannelModule.Input {
    override func setupViews() {
        self.messageInputView = CustomMessageInputView()
        
        super.setupViews()
    }
}
