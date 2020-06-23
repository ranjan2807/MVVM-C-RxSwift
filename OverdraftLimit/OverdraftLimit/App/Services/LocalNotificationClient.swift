//
//  LocalNotificationClient.swift
//  OverdraftLimit
//
//  Copyright © 2020 Ranjan-iOS. All rights reserved.
//

import Foundation
import UserNotifications

protocol LocalNotificationClientPresenter {
    func fireNotification(_ message: String)
}

final class LocalNotificationClient: LocalNotificationClientPresenter {

    let notificationCenter = UNUserNotificationCenter.current()

    init() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }

    func fireNotification(_ message: String) {
        let content = UNMutableNotificationContent()

        content.title = ""
        content.body = message
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}
