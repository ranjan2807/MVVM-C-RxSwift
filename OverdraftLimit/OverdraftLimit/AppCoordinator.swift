//
//  AppCoordinator.swift
//  OverdraftLimit
//
//  Copyright © 2020 Ranjan-iOS. All rights reserved.
//

import Foundation
import UIKit
import Swinject

protocol Coordinator: class {
    var childCoordinators: [Coordinator]? {get set}
    func start()
    func finish()
}

extension Coordinator {

    func store(coordinator: Coordinator)
    {
        childCoordinators?.append(coordinator)
    }

    func free(coordinator: Coordinator)
    {
        childCoordinators = childCoordinators?.filter { $0 !== coordinator }
    }
}

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator]?

    let window: UIWindow?

    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)

    var sceneTabIndex = 4

    var container: Container = {
        var contTemp = Container();
        contTemp.register(OverdraftGraphCoordinatorPresenter.self,
                          factory: { _ in OverdraftGraphCoordinator() })

        return contTemp
    }()

    lazy var rootViewController: UITabBarController? = {
        if let controller = storyboard.instantiateViewController(withIdentifier: "MainTab") as? UITabBarController {
            controller.selectedIndex = sceneTabIndex;
            return controller;
        } else {
            return nil
        }
    }()

    init(window: UIWindow?) {
        self.window = window
    }

    func start() {
        guard let window = window else { return}
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.addChildCoordinators()
    }

    func finish() {
        // call back to parent coordinator to remove self
    }
}

extension AppCoordinator {

    func addChildCoordinators() {
        // for now, just adding coordinator
        // to fifth tab screen
        if let coordinator = container.resolve(OverdraftGraphCoordinatorPresenter.self) {
            coordinator.tabController = self.rootViewController
            coordinator.start()

            self.store(coordinator: coordinator)
        }
    }
}

