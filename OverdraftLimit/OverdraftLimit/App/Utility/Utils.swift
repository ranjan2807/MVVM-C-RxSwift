//
//  Utils.swift
//  OverdraftLimit
//
//  Copyright © 2020 Ranjan-iOS. All rights reserved.
//

import Foundation

func valueForInfoKey(keyInInfo: String) -> String? {
    if let infoValue = Bundle.main.infoDictionary?[keyInInfo] as? String {
        return infoValue.replacingOccurrences(of: "\\", with: "")
    } else { return "" }
}
