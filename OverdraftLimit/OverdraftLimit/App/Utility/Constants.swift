//
//  Constants.swift
//  OverdraftLimit
//
//  Copyright © 2020 Ranjan-iOS. All rights reserved.
//

import Foundation
import UIKit

struct NotificationMessage {
    static let FIRST_OVERDRAFT = "Amount crossed first overdraft limit of 1000$".localized
    static let SECOND_OVERDRAFT = "Amount crossed second overdraft limit of 2000$".localized
}

struct ODColors {
    static let primary: UIColor = #colorLiteral(red: 0.4980392157, green: 0.7960784314, blue: 0.8, alpha: 1)
    static let secondary: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let tertiary: UIColor = #colorLiteral(red: 0.9137254902, green: 0.9176470588, blue: 0.9215686275, alpha: 1)
    static let danger: UIColor = #colorLiteral(red: 0.6274520159, green: 0.3507198095, blue: 0.3933730125, alpha: 1)
}

struct ChartPlotLimits {
    static let min: CGFloat = (π/2) * 1.4
    static let max: CGFloat = (2 * π) * 1.14
}

let withdrawTimerDuration = (60*60)/10
