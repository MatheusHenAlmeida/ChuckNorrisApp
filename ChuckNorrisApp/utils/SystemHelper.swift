//
//  SystemHelper.swift
//  ChuckNorrisApp
//
//  Created by Antigravity on 09/07/26.
//

import Foundation

protocol SystemHelping {
    func getAppName() -> String
    func getAppVersion() -> String
    func getAppBuild() -> String
    func getFormattedAppVersion() -> String
}

class SystemHelper {
    static func getAppName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Chuck Norris App"
    }
    
    static func getAppVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    static func getAppBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    static func getFormattedAppVersion() -> String {
        let version = getAppVersion()
        let build = getAppBuild()
        let format = NSLocalizedString("about_version_format", comment: "Format for app version and build")
        return String(format: format, version, build)
    }
}

class SystemHelperImpl: SystemHelping {
    func getAppName() -> String {
        return SystemHelper.getAppName()
    }
    
    func getAppVersion() -> String {
        return SystemHelper.getAppVersion()
    }
    
    func getAppBuild() -> String {
        return SystemHelper.getAppBuild()
    }
    
    func getFormattedAppVersion() -> String {
        return SystemHelper.getFormattedAppVersion()
    }
}
