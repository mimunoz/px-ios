import Foundation

// MARK: Events
extension TrackingPaths {
    struct Events {
        static func getInitPath() -> String {
            return TrackingPaths.pxTrack + "/init"
        }

        // Use this path for any user friction.
        static func getErrorPath() -> String {
            return "/friction"
        }

        static func getCreateTokenPath() -> String {
            return TrackingPaths.pxTrack + "/create_esc_token"
        }

        static func getConfirmPath() -> String {
            return TrackingPaths.pxTrack + "/review/confirm"
        }

        static func getBackPath(screen: String) -> String {
            return screen + "/back"
        }

        static func getAbortPath(screen: String) -> String {
            return screen + "/abort"
        }

        static func getRecognizedCardPath() -> String {
            return TrackingPaths.pxTrack + TrackingPaths.addPaymentMethod + "/number" + "/recognized_card"
        }

        static func getProgramValidation() -> String {
            return TrackingPaths.pxTrack + "/program_validation"
        }

        static func getComboSwitch() -> String {
            return TrackingPaths.pxTrack + "/combo_switch"
        }
    }
}

extension TrackingPaths.Events {
    struct OneTap {
        static func getSwipePath() -> String {
            return TrackingPaths.pxTrack + "/review/one_tap/swipe"
        }

        static func getConfirmPath() -> String {
            return TrackingPaths.pxTrack + "/review/confirm"
        }

        static func getTargetBehaviourPath() -> String {
            return TrackingPaths.pxTrack + "/review/one_tap/target_behaviour"
        }

        static func getOfflineMethodStartKYCPath() -> String {
            return TrackingPaths.pxTrack + "/review/one_tap/offline_methods/start_kyc_flow"
        }

        static func getDialogOpenPath() -> String {
            return TrackingPaths.pxTrack + "/dialog/open"
        }

        static func getDialogDismissPath() -> String {
            return TrackingPaths.pxTrack + "/dialog/dismiss"
        }

        static func getDialogActionPath() -> String {
            return TrackingPaths.pxTrack + "/dialog/action"
        }
    }
}

extension TrackingPaths.Events {
    struct SecurityCode {
        static func getConfirmPath() -> String {
            return TrackingPaths.pxTrack + "/security_code/confirm"
        }

        static func getTokenFrictionPath() -> String {
            return TrackingPaths.pxTrack + "/security_code/token_api_error"
        }

        static func getPaymentsFrictionPath() -> String {
            return TrackingPaths.pxTrack + "/security_code/payments_api_error"
        }
    }
}

extension TrackingPaths.Events {
    struct ReviewConfirm {
        static func getChangePaymentMethodPath() -> String {
            return TrackingPaths.pxTrack + "/review/traditional/change_payment_method"
        }

        static func getConfirmPath() -> String {
            return TrackingPaths.pxTrack + "/review/confirm"
        }
    }
}

// MARK: Congrats events paths.
enum EventsPaths: String {
    case tapScore = "/tap_score"
    case tapDiscountItem = "/tap_discount_item"
    case tapDownloadApp = "/tap_download_app"
    case tapCrossSelling = "/tap_cross_selling"
    case tapSeeAllDiscounts = "/tap_see_all_discounts"
    case deeplink = "/deep_link"
}

// MARK: Congrats events.
extension TrackingPaths.Events {
    struct Congrats {
        private static let success = "/success"
        private static let result = TrackingPaths.pxTrack + "/result"

        static func getSuccessPath() -> String {
            return result + success
        }

        static func getSuccessTapScorePath() -> String {
            return getSuccessPath() + EventsPaths.tapScore.rawValue
        }

        static func getSuccessTapDiscountItemPath() -> String {
            return getSuccessPath() + EventsPaths.tapDiscountItem.rawValue
        }

        static func getSuccessTapDownloadAppPath() -> String {
            return getSuccessPath() + EventsPaths.tapDownloadApp.rawValue
        }

        static func getSuccessTapCrossSellingPath() -> String {
            return getSuccessPath() + EventsPaths.tapCrossSelling.rawValue
        }

        static func getSuccessTapSeeAllDiscountsPath() -> String {
            return getSuccessPath() + EventsPaths.tapSeeAllDiscounts.rawValue
        }

        static func getSuccessTapViewReceiptPath() -> String {
            return getSuccessPath() + "/tap_view_receipt"
        }

        static func getSuccessTapDeeplinkPath() -> String {
            return getSuccessPath() + EventsPaths.deeplink.rawValue
        }
    }
}
