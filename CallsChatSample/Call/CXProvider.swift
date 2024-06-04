//
//  CXProvider.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 5/31/24.
//

import Foundation
import CallKit
import UIKit

extension CXProviderConfiguration {
    // The app's provider configuration, representing its CallKit capabilities
    static var `default`: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration()
        if let image = UIImage(named: "icCallkitSb") {
            providerConfiguration.iconTemplateImageData = image.pngData()
        }
        // Even if `.supportsVideo` has `false` value, SendBirdCalls supports video call.
        // However, it needs to be `true` if you want to make video call from native call log, so called "Recents"
        // and update correct type of call log in Recents
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        
        return providerConfiguration
    }
}

extension CXProvider {
    static var `default`: CXProvider {
        CXProvider(configuration: .`default`)
    }
}
