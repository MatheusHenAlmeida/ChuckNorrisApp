//
//  FeatureFlagsService.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 23/07/26.
//
import FirebaseCore
import FirebaseRemoteConfig

private let apiHostDefault = "https://api.chucknorris.io/"

protocol FeatureFlagsServiceType {
    func start()
    func getJokesURL() -> String
}

class FeatureFlagsService: FeatureFlagsServiceType {
    
    private let remoteConfig: RemoteConfig
    
    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
    }
    
    func start() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 3600
        #endif
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(["jokes_url": apiHostDefault as NSObject])
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                debugPrint("Error fetching config: \(error)")
            } else {
                debugPrint("Remote Config initialized")
            }
        }
    }
    
    func getJokesURL() -> String {
        return remoteConfig.configValue(forKey: "jokes_url").stringValue
    }
}
