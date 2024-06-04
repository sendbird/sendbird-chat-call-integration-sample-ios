//
//  CallMessageCell.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 6/4/24.
//

import UIKit
import SendbirdChatSDK
import SendbirdUIKit
import SendBirdCalls

extension BaseMessage {
    func getPluginDetail(for vendor: String, type: String) -> [String: Any]? {
        let firstPlugin = self.plugins?.filter({ $0.vendor == vendor }).first(where: { $0.type == type })
        return firstPlugin?.detail
    }
}

open class CallMessageCell: SBUContentBaseMessageCell {
    var callInfo: CallInfo?
    // MARK: - Public property
    public var callMessage: BaseMessage? {
        self.message
    }
    public var callIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    public var callLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Incoming Call"
        return label
    }()
    
    public var sstackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        
        sstackView.addArrangedSubview(callIconImageView)
        sstackView.addArrangedSubview(callLabel)
        
        self.mainContainerView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.mainContainerView.stackView.addArrangedSubview(self.sstackView)
        self.mainContainerView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapContentView(sender:)))
        )
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.sstackView.sbu_constraint(
            equalTo: self.mainContainerView,
            leading: 8,
            trailing: -12,
            top: 8,
            bottom: 8
        )
        
        self.callIconImageView.sbu_constraint(width: 40, height: 40)
    }
    
    open override func setupStyles() {
        super.setupStyles()
    }
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let message = configuration.message as? UserMessage else { return }
        super.configure(with: configuration)
        
        guard let detail = message.getPluginDetail(for: "sendbird", type: "call"),
              let callInfo = CallInfo.make(from: detail) else { return }
        
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
        
        let labelColor: UIColor
        if position == .left {
            labelColor = theme.userMessageLeftTextColor
        } else {
            labelColor = theme.userMessageRightTextColor
        }
        
        self.callLabel.textColor = labelColor
        self.callIconImageView.image = UIImage(named: callInfo.isVideoCall ? "icCallVideoFilled" : "icCallFilled")?.sbu_resize(with: CGSize(width: 24, height: 24)).sbu_with(tintColor: labelColor)
    }
}
