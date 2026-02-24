//
//  ViewController.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import UIKit
import SwinjectStoryboard
import AVFoundation
import SwiftUI
import GoogleMobileAds

class ViewController: UIViewController {

    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var askForJokeButton: UIButton!
        
    @IBOutlet weak var tellJokeButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    
    var mainViewModel: MainViewModel?
    var speechService: SpeechService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIds()
        setButton()
    }
    
    private func setIds() {
        askForJokeButton.accessibilityIdentifier = "ask_joke_button"
        tellJokeButton.accessibilityIdentifier = "tell_joke_button"
        myLabel.accessibilityIdentifier = "joke_label"
    }
    
    private func setButton() {
        askForJokeButton.setTitle(NSLocalizedString("get_a_joke_button", comment: "Button to get a joke"), for: .normal)
        tellJokeButton.setTitle(NSLocalizedString("tell_me_a_joke_button", comment: "Button to tell a joke"), for: .normal)
        askForJokeButton.addTarget(self, action: #selector(askForJokeAction), for: .touchDown)
        tellJokeButton.addTarget(self, action: #selector(tellJokeAction), for: .touchUpInside)
    }
    
    @objc func askForJokeAction() {
        loadingView.isHidden = false
        Task {
            if let joke = try? await mainViewModel?.getJoke() {
                myLabel.text = joke.value ?? DefaultMessages.tryItLater
            } else {
                myLabel.text = DefaultMessages.tryItLater
            }
            loadingView.isHidden = true
        }
    }
    
    @objc func tellJokeAction() {
        loadingView.isHidden = false
        Task {
            if let joke = try? await mainViewModel?.getJoke() {
                let jokeText = joke.value ?? DefaultMessages.tryItLater
                myLabel.text = jokeText
                
                speechService?.speech(message: jokeText)
            } else {
                myLabel.text = DefaultMessages.tryItLater
            }
            loadingView.isHidden = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAdditionalUI()
    }
    
    private var bannerView: BannerView!
    private var didSetupUI = false

    private func setupAdditionalUI() {
        guard !didSetupUI else { return }
        didSetupUI = true
        
        // Add Alarms Button
        let alarmsButton = UIButton(type: .system)
        alarmsButton.setTitle("Alarms", for: .normal)
        alarmsButton.addTarget(self, action: #selector(openAlarms), for: .touchUpInside)
        alarmsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alarmsButton)
        
        // Add About Button
        let aboutButton = UIButton(type: .system)
        aboutButton.setTitle("About", for: .normal)
        aboutButton.addTarget(self, action: #selector(openAbout), for: .touchUpInside)
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(aboutButton)
        
        // Setup AdBanner
        bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // Test ID
        bannerView.rootViewController = self
        bannerView.load(Request())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        // Layout
        NSLayoutConstraint.activate([
            // Banner at bottom safely
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Buttons at top safely (left and right)
            alarmsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            alarmsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            aboutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            aboutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func openAlarms() {
        let alarmView = AlarmListView()
        let hostingController = UIHostingController(rootView: alarmView)
        present(hostingController, animated: true, completion: nil)
    }
    
    @objc func openAbout() {
        let aboutView = AboutView()
        let hostingController = UIHostingController(rootView: aboutView)
        present(hostingController, animated: true, completion: nil)
    }
}

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.register(ChuckNorrisService.self) { _ in
            ChuckNorrisServiceImpl(baseUrl: "https://api.chucknorris.io/jokes")
        }
        defaultContainer.register(ChuckNorrisWebClient.self) { resolver in
            ChuckNorrisWebClientImpl(webService: resolver.resolve(ChuckNorrisService.self)!)
        }
        defaultContainer.register(MainViewModel.self) { resolver in
            MainViewModelImpl(webClient: resolver.resolve(ChuckNorrisWebClient.self)!)
        }
        defaultContainer.register(SpeechService.self) { _ in
            SpeechService(speechSynthesizer: AVSpeechSynthesizer())
        }
        defaultContainer.storyboardInitCompleted(ViewController.self) { resolver, viewController in
            viewController.mainViewModel = resolver.resolve(MainViewModel.self)
            viewController.speechService = resolver.resolve(SpeechService.self)
        }
    }
}

struct DefaultMessages {
    static let tryItLater = NSLocalizedString("try_it_later", comment: "Default message when joke cannot be fetched")
}

#if DEBUG
extension ViewController {
    public func clickAskForJokeButton() {
        askForJokeAction()
    }
    
    public func getLabel() async -> String? {
        return myLabel.text
    }
}
#endif
