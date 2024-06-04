//
//  CustomGroupChannelList.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 6/4/24.
//

import UIKit
import SendbirdChatSDK
import SendbirdUIKit
import SendBirdCalls

class CustomChannelListComponent: SBUGroupChannelListModule.List {
    override func setupViews() {
        self.register(channelCell: CustomGroupChannelCell())
        super.setupViews()
    }
}

class CustomGroupChannelCell: SBUGroupChannelCell {
    override func setupStyles() {
        super.setupStyles()
        
        guard let channel = channel as? GroupChannel,
              let pluginDetail = channel.lastMessage?.getPluginDetail(for: "sendbird", type: "call"),
              let callInfo = CallInfo.make(from: pluginDetail) else {
            return
        }
        self.messageLabel.text = callInfo.isVideoCall ? "Video Call" : "Audio Call"
    }
}
