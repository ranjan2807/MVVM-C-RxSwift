//
//  OverdraftGraphCoordinator.swift
//  OverdraftLimit
//
//  Copyright © 2020 Ranjan-iOS. All rights reserved.
//

import Foundation
import UIKit
import Swinject

protocol OverdraftGraphCoordinatorPresenter: Coordinator {
    var tabController: UITabBarController? { get set }
}

final class OverdraftGraphCoordinator: OverdraftGraphCoordinatorPresenter {

    var tabController: UITabBarController?

    var localNotificationClient: LocalNotificationClient?

    var childCoordinators: [Coordinator]?

    var tabIndex = 4

    private var viewController: UIViewController?

    var container: Container = {
        var contTemp = Container()

        contTemp.register(LocalNotificationClientPresenter.self) {
            _ in LocalNotificationClient()
        }

        contTemp.register(OverdraftGraphViewModelPresenter.self) {
            r in OverdraftGraphViewModel(
                notificationClient: r.resolve(LocalNotificationClientPresenter.self)
            )
        }

        return contTemp
    } ()

    deinit {

    }

    func start() {
        guard let viewController = tabController?
            .viewControllers![tabIndex] as? OverdraftGraphViewController else
        { return }
        viewController.viewModel = container.resolve(OverdraftGraphViewModelPresenter.self)

    }

    func finish() {

    }


}
