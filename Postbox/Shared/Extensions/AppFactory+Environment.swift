//
//  AppFactoryKey.swift
//  Postbox
//
//  Created by habil on 09/08/26.
//


import SwiftUI

private struct AppFactoryKey: EnvironmentKey {
    static let defaultValue: AppFactory? = nil
}

extension EnvironmentValues {
    var appFactory: AppFactory? {
        get { self[AppFactoryKey.self] }
        set { self[AppFactoryKey.self] = newValue }
    }
}
