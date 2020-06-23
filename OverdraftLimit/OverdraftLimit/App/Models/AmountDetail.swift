//
//  AmountDetail.swift
//  OverdraftLimit
//
//  Copyright © 2020 Ranjan-iOS. All rights reserved.
//

import Foundation

struct AmountDetail {
    var amount: Double? = 0
    var interestRate: Double?
    var interestAmount: Double? = 0
    var overdraftLimit: Double?
    var overdraftDangerLimit: Double?
    var firstOverdraftLimit: Bool = false
    var secondOverdraftLimit: Bool = false
}
