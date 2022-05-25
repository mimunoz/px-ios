//
//  FeatureFlag.swift
//  MercadoPagoSDKV4
//
//  Created by Ricardo Couto D Alambert on 16/05/22.
//

import Foundation

final class PXFeatureFlag {
    enum PXFeatureFlagNames: String, CaseIterable {
        case concurrencyPayments = "px_feature_concurrency_payments_ios"
    }

    static let shared = PXFeatureFlag()

    private var flagsEnabled: [PXFeatureFlagNames: Bool] = [:]

    init() {
        let flagsUpdateName = PXConfiguratorManager.remoteConfigurationsProtocol.flagsUpdateNotificationName()

        // first initialization - check flags
        checkFlags()

        // notification listener registration
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkFlags),
            name: flagsUpdateName,
            object: nil
        )
    }

    func isEnabled(_ flag: PXFeatureFlagNames) -> Bool {
        return flagsEnabled[flag] ?? false
    }

    // in case of any changes, this method is called from NotificationCenter to update the flag informations.
    @objc private func checkFlags() {
        for flagName in PXFeatureFlag.PXFeatureFlagNames.allCases {
            flagsEnabled[flagName] = PXConfiguratorManager.remoteConfigurationsProtocol.isFlagEnabled(
                flag: flagName.rawValue,
                defaultValue: false
            )
        }
    }
}
