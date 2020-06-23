//
//  OverdraftGraphViewModel.swift
//  OverdraftLimit
//
//  Copyright © 2020 Ranjan-iOS. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import UIKit

protocol OverdraftGraphAmountViewModelPresenter {
    func updateAmount()
    func amountDetailsModel() -> AmountDetailViewData
}

protocol OverdraftGraphChartViewModelPresenter {
    func getChartStartAngle() -> CGFloat
    func calculateEndAngleForOverdraftAmount() -> CGFloat
    func calculateEndAngleForOverdraftLimit() -> CGFloat
}

protocol OverdraftGraphViewModelPresenter: OverdraftGraphAmountViewModelPresenter,
OverdraftGraphChartViewModelPresenter {
    var settingsObservable: Observable<[SectionModel<Any, Any>]>? { get }
    var needNotification: Bool { get set}
    func initialize()
}

final class OverdraftGraphViewModel: OverdraftGraphViewModelPresenter {

    var needNotification: Bool = true

    var localNotificationClient: LocalNotificationClientPresenter?

    var settingsObservable: Observable<[SectionModel<Any, Any>]>?

    deinit {
        
    }

    private var subject: BehaviorRelay<[SectionModel<Any, Any>]> = BehaviorRelay(value: [SectionModel<Any, Any>]())

    private var amountModel: AmountDetail?

    init (notificationClient: LocalNotificationClientPresenter?) {
        guard let client = notificationClient else { return }
        self.localNotificationClient = client
    }
}

extension OverdraftGraphViewModel {

    func initialize() {
        self.populateAmountDetails()

        self.settingsObservable = subject.asObservable()
        buildTableRows()
    }

    func updateAmount() {
        guard let _ = self.amountModel else { return }

        self.calculateInterest()
        self.pushNotification()
        buildTableRows()
    }

    func amountDetailsModel() -> AmountDetailViewData {
        let model = AmountDetailViewData(model: self.amountModel!)
        return model;
    }
}


// MARK: - MISC
extension OverdraftGraphViewModel {

    private func populateAmountDetails() {
        var temp = AmountDetail()

        temp.amount = retreiveValueFor(key: "InitialAmount")
        temp.interestRate = retreiveValueFor(key: "InterestRate")
        temp.overdraftLimit = retreiveValueFor(key: "OverdraftLimit")
        temp.overdraftDangerLimit = retreiveValueFor(key: "OverdraftDangerLimit")

        self.amountModel = temp;

    }

    private func buildTableRows() {
        let itemForSection1 = [
            "Interest incurred this quarter".localized
        ]
        let itemForSection2 = [
            "Overdraft alert".localized,
            "Request increase".localized
        ]

        subject.accept([
            SectionModel(model: "", items: itemForSection1),
            SectionModel(model: "", items: itemForSection2)
        ])
    }

    private func retreiveValueFor(key: String) -> Double {
        guard let value = valueForInfoKey(keyInInfo: key),
            value != "" else { return 0 }

        if let valueInt = Double(value) {
            return valueInt
        } else {
            return 0
        }
    }

    private func totalAmountWithdrawn() -> Double {
        let lowerLimit = Int(retreiveValueFor(key: "AmountLowest"))
        let higherLimit = Int(retreiveValueFor(key: "AmountHighest"))

        return Double(Int.random(in: lowerLimit...higherLimit))
    }
}

// MARK: - Amount Handling
extension OverdraftGraphViewModel {

    private func calculateInterest() {
        let amountWithdrawn: Double = self.totalAmountWithdrawn()
        let principleAmount: Double = self.amountModel!.amount! + amountWithdrawn
        let totalInterest = (principleAmount * amountModel!.interestRate!)/100

        self.amountModel!.amount = principleAmount + totalInterest
        self.amountModel!.interestAmount! += totalInterest

        NSLog("\n\n\(self.amountModel!.amount!) ---  \(self.amountModel!.interestAmount!) ---- \(totalInterest) --- \(amountWithdrawn)")
    }

    private func pushNotification() {

        if self.amountModel!.amount! > self.amountModel!.overdraftDangerLimit! {
            if !self.amountModel!.secondOverdraftLimit {
                // push a urgent notification
                self.localNotificationClient?.fireNotification (
                    NotificationMessage.SECOND_OVERDRAFT
                )
                self.amountModel?.secondOverdraftLimit = true
            }
        } else {
            if self.amountModel!.amount! > self.amountModel!.overdraftLimit! &&
                self.needNotification {
                if !self.amountModel!.firstOverdraftLimit {
                    // push a notification
                    self.localNotificationClient?.fireNotification (
                        NotificationMessage.FIRST_OVERDRAFT
                    )
                    self.amountModel!.firstOverdraftLimit = true
                }
            }
        }
    }
}

//MARK: - Chart Handling
extension OverdraftGraphViewModel {

    func getChartStartAngle() -> CGFloat {
        return ChartPlotLimits.min
    }

    func calculateEndAngleForOverdraftAmount() -> CGFloat {
        let amountTemp = ((amountModel?.amount)! > (amountModel?.overdraftDangerLimit)!) ? amountModel?.overdraftDangerLimit! : amountModel?.amount!
        return calculateEndAngleFor(val: CGFloat(amountTemp!))
    }

    func calculateEndAngleForOverdraftLimit() -> CGFloat {
        return calculateEndAngleFor(val: CGFloat(amountModel!.overdraftLimit!))
    }

    func calculateEndAngleFor(val: CGFloat) -> CGFloat {
        let difference = ChartPlotLimits.max - ChartPlotLimits.min
        let maxAmount = CGFloat(amountModel!.overdraftDangerLimit!)
        let factorToAdd = (difference * val)/maxAmount

        return ChartPlotLimits.min + factorToAdd
    }
}
