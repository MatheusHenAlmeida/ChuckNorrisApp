//
//  FeatureFlagsService.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 23/07/26.
//
import FirebaseCore
import FirebaseRemoteConfig

private let apiHostDefault = "https://api.chucknorris.io/jokes"

protocol FeatureFlagsServiceType {
    func start() async
    func getJokesURL() -> String
}

class FeatureFlagsService: FeatureFlagsServiceType {
    
    private let remoteConfig: RemoteConfig
    
    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
    }
    
    func start() async {
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
        
        do {
            let status = try await remoteConfig.fetchAndActivate()
            debugPrint("Remote Config fetch status: \(status)")
        } catch {
            debugPrint("Error fetching Remote Config: \(error)")
        }
    }
    
    func getJokesURL() -> String {
        return remoteConfig.configValue(forKey: "jokes_url").stringValue
    }
}
