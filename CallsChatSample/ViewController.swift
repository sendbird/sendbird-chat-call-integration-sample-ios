//
//  ViewController.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 5/31/24.
//

import UIKit
import SendbirdUIKit
import SendBirdCalls
import SendbirdChatSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

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

protocol CallDelegate: AnyObject {
    func didClickMakeCall(isVideo: Bool)
}

class CustomGroupChannelViewController: SBUGroupChannelViewController, CallDelegate {
    var remoteCallUserId: String? {
        guard let currentUserId = SendBirdCall.currentUser?.userId else { return nil }
        return channel?.members.first { $0.userId != currentUserId }?.userId
    }

//    required init(channel: GroupChannel, messageListParams: MessageListParams? = nil) {
//        super.init(channel: channel, messageListParams: messageListParams)
//    }
//    
//    required init(channelURL: String, startingPoint: Int64? = nil, messageListParams: MessageListParams? = nil) {
//        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
//    }
//    
//    override required init(channelURL: String, startingPoint: Int64? = nil, messageListParams: MessageListParams? = nil, displaysLocalCachedListFirst: Bool) {
//        fatalError("init(channelURL:startingPoint:messageListParams:displaysLocalCachedListFirst:) has not been implemented")
//    }
    
    
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
                // TODO: FIXME
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
}

class CustomInputComponent: SBUGroupChannelModule.Input {
    override func setupViews() {
        self.messageInputView = CustomMessageInputView()
        
        super.setupViews()
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
}

//class CustomGroupChannelListCell: SBUGroupChannelListModule.List.

open class CallMessageCelsl: SBUContentBaseMessageCell {
    var callInfo: CallInfo?
    // MARK: - Public property
    public var callMessage: BaseMessage? {
        self.message
    }
    public lazy var callIconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            return imageView
        }()
        
        public lazy var callLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = "Incoming Call"
            return label
        }()
        
        public lazy var sstackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [callIconImageView, callLabel])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 4
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        // MARK: - View Lifecycle
        open override func setupViews() {
            super.setupViews()
            
            // Adding the stack view to the main container view
            self.mainContainerView.insertArrangedSubview(sstackView, at: 0)
//            self.mainContainerView.addSubview(sstackView)
        }
        
        open override func setupLayouts() {
            super.setupLayouts()
            
            // Layout constraints for the stack view
            NSLayoutConstraint.activate([
                sstackView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor, constant: 8),
                sstackView.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor, constant: 8),
                sstackView.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor, constant: -8),
                sstackView.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor, constant: -8)
            ])
        }
//    public lazy var callIconImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
//    
//    public lazy var callLabel: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.text = "Incoming Call"
//        return label
//    }()
//    
//    // MARK: - View Lifecycle
//    open override func setupViews() {
//        super.setupViews()
//        
//        // Adding the call icon and label to the main container view
//        self.mainContainerView.stackView.setHStack([
//            self.callIconImageView,
//            self.callLabel
//        ])
//    }
//    
//    open override func setupLayouts() {
//        super.setupLayouts()
//        
//        self.mainContainerView
//            .sbu_constraint(equalTo: self.contentView)
//        
//        // Layout constraints for image view and label
//        self.callIconImageView.translatesAutoresizingMaskIntoConstraints = false
//        self.callLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            self.callIconImageView.topAnchor.constraint(equalTo: self.mainContainerView.topAnchor, constant: 8),
//            self.callIconImageView.centerXAnchor.constraint(equalTo: self.mainContainerView.centerXAnchor),
//            self.callIconImageView.widthAnchor.constraint(equalToConstant: 40),
//            self.callIconImageView.heightAnchor.constraint(equalToConstant: 40),
//            
//            self.callLabel.topAnchor.constraint(equalTo: self.callIconImageView.bottomAnchor, constant: 4),
//            self.callLabel.leadingAnchor.constraint(equalTo: self.mainContainerView.leadingAnchor, constant: 8),
//            self.callLabel.trailingAnchor.constraint(equalTo: self.mainContainerView.trailingAnchor, constant: -8),
//            self.callLabel.bottomAnchor.constraint(equalTo: self.mainContainerView.bottomAnchor, constant: -8)
//        ])
//    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        // Set styles for icon and label if needed
    }
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let message = configuration.message as? UserMessage else { return }
        
        // Configure the cell with the message
        super.configure(with: configuration)
        
//        // Set the appropriate icon and label text based on the message content
//        if message.customType == "incoming_call" {
//            self.callIconImageView.image = UIImage(named: "incoming_call_icon")
//            self.callLabel.text = "Incoming Call"
//        } else if message.customType == "outgoing_call" {
//            self.callIconImageView.image = UIImage(named: "outgoing_call_icon")
//            self.callLabel.text = "Outgoing Call"
//        }
//        
        self.callIconImageView.image = UIImage(named: "outgoing_call_icon")
        if let detail = message.getPluginDetail(for: "sendbird", type: "call"),
           let callInfo = CallInfo(from: detail) {
            self.callInfo = callInfo
            
            if let duration = callInfo.duration,
                let reason = callInfo.endResult {
                switch reason {
                case .completed:
                    self.callLabel.text = "\(duration)"
                case .unknown, .none:
                    self.callLabel.text = "Unknown Error"
                default:
                    self.callLabel.text = reason.capitalized().replacingOccurrences(of: "_", with: " ")
                }
            } else {
                self.callLabel.text = "\(callInfo.isVideoCall ? "Video" : "Voice") calling..."
            }
            
        }
//        self.mainContainerView.addArrangedSubview(callImage)
//        self.mainContainerView.addArrangedSubview(messageTextView)
        
    }
    
    open override func configure(highlightInfo: SBUHighlightMessageInfo?) {
        // Handle any highlighting if needed
    }
}

@IBDesignable
open class CallMessageCell: SBUContentBaseMessageCell {
    var callInfo: CallInfo?
//    {
//        didSet {
//            guard let info = self.callInfo else { return }
//            
//            if info.isVideoCall {
//                self.callTypeImageView.image = UIImage(named: "icCallVideoFilled")
//            } else {
//                self.callTypeImageView.image = UIImage(named: "icCallFilled")
//            }
//            
//            if let duration = info.duration,
//                let reason = info.endResult {
//                switch reason {
//                case .completed:
//                    self.textMessageLabel.text = "\(duration.timerText())"
//                case .unknown, .none:
//                    self.textMessageLabel.text = "Unknown Error"
//                default:
//                    self.textMessageLabel.text = reason.capitalized().replacingOccurrences(of: "_", with: " ")
//                }
//            } else {
//                self.textMessageLabel.text = "\(info.isVideoCall ? "Video" : "Voice") calling..."
//            }
//        }
//    }

    public lazy var callImage: SBUImageContentView = {
       let contentView = SBUImageContentView()
        let image = UIImage(named: "icCallVideoFilled_Incoming")
        contentView.imageView = UIImageView(image: image)
        return contentView
    }()
    
    public lazy var messageTextView: UILabel = {
       let label = UILabel()
        label.text = "HELOELO"
        return label
    }()

//    public lazy var baseFileContentView: SBUBaseFileContentView = {
//        let fileView = SBUBaseFileContentView()
//        return fileView
//    }()
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        
        self.mainContainerView.stackView.setHStack ([callImage,messageTextView])

        // + ------------------- +
        // | baseFileContentView |
        // + ------------------- +
        // | reactionView        |
        // + ------------------- +
        
//        self.mainContainerView.setAxis(.horizontal)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.mainContainerView
            .sbu_constraint_lessThan(width: SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize.width)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
//        self.baseFileContentView.setupStyles()
    }
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
//        guard let configuration = configuration as? SBUBaseMessageCellParams else { return }
        guard let message = configuration.message as? UserMessage else { return }
        
        self.useReaction = false
        self.enableEmojiLongPress = false
        self.useQuotedMessage = false
        self.useThreadInfo = false

        super.configure(with: configuration)
        
        if let detail = message.getPluginDetail(for: "sendbird", type: "call"),
           let callInfo = CallInfo(from: detail) {
            self.callInfo = callInfo
            
            if let duration = callInfo.duration,
                let reason = callInfo.endResult {
                switch reason {
                case .completed:
                    self.messageTextView.text = "\(duration)"
                case .unknown, .none:
                    self.messageTextView.text = "Unknown Error"
                default:
                    self.messageTextView.text = reason.capitalized().replacingOccurrences(of: "_", with: " ")
                }
            } else {
                self.messageTextView.text = "\(callInfo.isVideoCall ? "Video" : "Voice") calling..."
            }
            
        }
        self.mainContainerView.stackView.setHStack ([callImage,messageTextView])
        self.mainContainerView.backgroundColor = .red
//        // Set up base file content view
//        switch SBUUtils.getFileType(by: message) {
//        case .image, .video:
//            if !(self.baseFileContentView is SBUImageContentView) {
//                self.baseFileContentView.removeFromSuperview()
//                self.baseFileContentView = SBUImageContentView()
//                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
//                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
//                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
//            }
//            self.baseFileContentView.configure(
//                message: message,
//                position: configuration.messagePosition
//            )
//            
//        case .audio, .pdf, .etc:
//            if !(self.baseFileContentView is SBUCommonContentView) {
//                self.baseFileContentView.removeFromSuperview()
//                self.baseFileContentView = SBUCommonContentView()
//                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
//                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
//                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
//            }
//            if let commonContentView = self.baseFileContentView as? SBUCommonContentView {
//                commonContentView.configure(
//                    message: message,
//                    position: configuration.messagePosition,
//                    highlightKeyword: nil
//                )
//            }
//            
//        case .voice:
//            if !(self.baseFileContentView is SBUVoiceContentView) {
//                self.baseFileContentView.removeFromSuperview()
//                self.baseFileContentView = SBUVoiceContentView()
//                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
//                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
//                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
//            }
//            if let voiceContentView = self.baseFileContentView as? SBUVoiceContentView {
//                voiceContentView.configure(
//                    message: message,
//                    position: configuration.messagePosition,
//                    voiceFileInfo: configuration.voiceFileInfo
//                )
//            }
//        }
    }
    
//    open override func configure(highlightInfo: SBUHighlightMessageInfo?) {
//        // Only apply highlight for the given message, that's not edited (updatedAt didn't change)
//        guard let message = self.message,
//              message.messageId == highlightInfo?.messageId,
//              message.updatedAt == highlightInfo?.updatedAt else { return }
//        
//        guard let commonContentView = self.baseFileContentView as? SBUCommonContentView,
//              let fileMessage = self.fileMessage else { return }
//        
//        commonContentView.configure(
//            message: fileMessage,
//            position: self.position,
//            highlightKeyword: highlightInfo?.keyword
//        )
//    }
//    
//    /// This method has to be called in main thread
//    public func setImage(_ image: UIImage?, size: CGSize? = nil) {
//        guard let imageContentView = self.baseFileContentView as? SBUImageContentView else { return }
//        imageContentView.setImage(image, size: size)
//        imageContentView.setNeedsLayout()
//    }
//    
//    @available(*, deprecated, renamed: "configure(with:)") // 2.2.0
//    open func configure(_ message: FileMessage,
//                        hideDateView: Bool,
//                        groupPosition: MessageGroupPosition,
//                        receiptState: SBUMessageReceiptState?,
//                        useReaction: Bool) {
//        let configuration = SBUFileMessageCellParams(
//            message: message,
//            hideDateView: hideDateView,
//            useMessagePosition: true,
//            groupPosition: groupPosition,
//            receiptState: receiptState ?? .none,
//            useReaction: useReaction
//        )
//        self.configure(with: configuration)
//    }
//    
//    // MARK: - Action
//    public override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
}

extension BaseMessage {
    func getPluginDetail(for vendor: String, type: String) -> [String: Any]? {
        let firstPlugin = self.plugins?.filter({ $0.vendor == vendor }).first(where: { $0.type == type })
        return firstPlugin?.detail
    }
}


