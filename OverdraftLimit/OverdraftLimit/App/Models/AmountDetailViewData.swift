//
//  AmountDetailViewData.swift
//  OverdraftLimit
//  Copyright © 2020 Ranjan-iOS. All rights reserved.
//

import Foundation

struct AmountDetailViewData {

    private var model: AmountDetail

    init(model: AmountDetail) {
        self.model = model
    }

    var interestRate : String {
        return String(format: "%.1f", self.model.interestRate ?? 0) + "%"
    }

    var interestAmount: String {
        return String(format: "%.1f", self.model.interestAmount ?? 0) + " " +
            valueForInfoKey(keyInInfo: "AppCurrency")!
    }

    var amount: String {
        return String(format: "%.1f", self.model.amount ?? 0) + " " +
        valueForInfoKey(keyInInfo: "AppCurrency")!
    }
}
