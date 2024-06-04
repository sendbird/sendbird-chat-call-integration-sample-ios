//
//  CallInfo.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 5/31/24.
//

import Foundation
import SendBirdCalls

@objc
class CallInfo: NSObject, Decodable {
    let callId: String
    let callType: String
    
    let isVideoCall: Bool
    
    let duration: Int64?
    let endResult: DirectCallEndResult?
    
    static func make(from dictionary: [String: Any]) -> CallInfo? {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(CallInfo.self, from: data)
    }
    
    enum CodingKeys: String, CodingKey {
        case callId = "call_id"
        case callType = "call_type"
        case isVideoCall = "is_video_call"
        case duration
        case endResult = "end_result"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.callId = try container.decode(String.self, forKey: .callId)
        self.callType = try container.decode(String.self, forKey: .callType)
        
        self.isVideoCall = try container.decode(Bool.self, forKey: .isVideoCall)

        self.duration = try? container.decode(Int64.self, forKey: .duration)
        self.endResult = try? container.decode(DirectCallEndResult.self, forKey: .endResult)
    }
}

extension DirectCallEndResult {
    func capitalized() -> String {
        let string = self.rawValue
        return string.prefix(1).capitalized + string.dropFirst()
    }
}
