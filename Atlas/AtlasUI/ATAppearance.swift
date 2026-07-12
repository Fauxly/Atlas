//
//  ATAppearance.swift
//  Atlas
//

import UIKit

/// Глобальная тема через UIAppearance-прокси. Красит системный "хром" (навбар, таббар,
/// поисковую строку, разделители таблиц) во всём приложении одним местом, без правки
/// каждого экрана вручную. Вызвать один раз при старте — из AppDelegate/SceneDelegate,
/// например в application(_:didFinishLaunchingWithOptions:) или scene(_:willConnectTo:options:),
/// до создания любых view controller'ов.
enum ATAppearance {

    static func apply() {
        // Общий tint — латунный акцент на кнопках, курсоре поиска, выделении и т.д.
        UIWindow.appearance().tintColor = ATTheme.brass

        configureTabBar()
        configureNavigationBar()
        configureTableView()
        configureSearchBar()
    }

    private static func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ATTheme.ink

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = ATTheme.textSecondary
        normal.titleTextAttributes = [.foregroundColor: ATTheme.textSecondary]

        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = ATTheme.brass
        selected.titleTextAttributes = [.foregroundColor: ATTheme.brass]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().tintColor = ATTheme.brass
        UITabBar.appearance().unselectedItemTintColor = ATTheme.textSecondary
        #if os(iOS)
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        #endif
    }

    private static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = ATTheme.ink
        appearance.titleTextAttributes = [.foregroundColor: ATTheme.textPrimary]
        appearance.largeTitleTextAttributes = [.foregroundColor: ATTheme.textPrimary]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = ATTheme.brass
    }

    private static func configureTableView() {
        UITableView.appearance().backgroundColor = ATTheme.ink
    }

    private static func configureSearchBar() {
        UISearchBar.appearance().tintColor = ATTheme.brass
        UISearchBar.appearance().barTintColor = ATTheme.ink
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = ATTheme.textPrimary
    }
}
