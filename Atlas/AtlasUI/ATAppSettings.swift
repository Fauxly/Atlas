//
//  ATAppSettings.swift
//  Atlas
//

import Foundation

enum ATAppSettings {

    private static let autoUpdateKey = "ATAutoUpdateOnLaunch"

    /// По умолчанию включено — сохраняем прежнее поведение для тех, кто ничего не менял
    static var autoUpdateOnLaunch: Bool {
        get {
            if UserDefaults.standard.object(forKey: autoUpdateKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: autoUpdateKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: autoUpdateKey)
        }
    }
}
