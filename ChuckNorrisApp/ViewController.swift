//
//  ViewController.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import UIKit
import Swinject
import SwinjectStoryboard
import AVFoundation
import SwiftUI
import GoogleMobileAds
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var askForJokeButton: UIButton!
    @IBOutlet weak var tellJokeButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    
    var mainViewModel: MainViewModel?
    var speechService: SpeechService?
    
    private var dimmingView: UIView!
    private var sideMenuContainerView: UIView!
    private var sideMenuLeadingConstraint: NSLayoutConstraint!
    private let sideMenuWidthMultiplier: CGFloat = 0.75
    
    private var bannerView: BannerView!
    private var didSetupUI = false
    private var menuButton: UIButton!
    
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
    
    func displayJoke(text: String, speak: Bool) {
        myLabel.text = text
        if speak {
            speechService?.speech(message: text)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAdditionalUI()
    }

    private func setupAdditionalUI() {
        guard !didSetupUI else { return }
        didSetupUI = true
        
        // Add Hamburger Menu Button
        menuButton = UIButton(type: .system)
        let menuImage = UIImage(systemName: "line.3.horizontal")
        menuButton.setImage(menuImage, for: .normal)
        menuButton.tintColor = .white
        menuButton.addTarget(self, action: #selector(openSideMenu), for: .touchUpInside)
        menuButton.accessibilityIdentifier = "menu_button"
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuButton)
        
        // Setup AdBanner
        bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = Bundle.main.object(forInfoDictionaryKey: "AdUnitID") as? String
            ?? "ca-app-pub-3940256099942544/2934735716" // Fallback to Test ID
        bannerView.rootViewController = self
        bannerView.load(Request())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        configAdditionalUIConstraints()
        
        setupSideMenu()
    }
    
    private func configAdditionalUIConstraints() {
        NSLayoutConstraint.activate([
            // Banner at bottom safely
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Menu Button at top left safely
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            menuButton.widthAnchor.constraint(equalToConstant: 44),
            menuButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupSideMenu() {
        // 1. Create Dimming Backdrop View
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmingView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeSideMenu))
        dimmingView.addGestureRecognizer(tapGesture)
        
        // 2. Create Side Menu Container View
        sideMenuContainerView = UIView()
        sideMenuContainerView.backgroundColor = .systemBackground
        sideMenuContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add shadow for premium feel
        sideMenuContainerView.layer.shadowColor = UIColor.black.cgColor
        sideMenuContainerView.layer.shadowOpacity = 0.25
        sideMenuContainerView.layer.shadowOffset = CGSize(width: 4, height: 0)
        sideMenuContainerView.layer.shadowRadius = 8
        
        view.addSubview(sideMenuContainerView)
        
        // 3. Setup Side Menu Header with Orange Background and App Icon + Name
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.929, green: 0.557, blue: 0.310, alpha: 1.0)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        sideMenuContainerView.addSubview(headerView)
        
        let headerIconImageView = UIImageView()
        headerIconImageView.contentMode = .scaleAspectFit
        headerIconImageView.clipsToBounds = true
        headerIconImageView.layer.cornerRadius = 6
        headerIconImageView.translatesAutoresizingMaskIntoConstraints = false
        if let appIcon = UIImage(named: "AppIcon") ?? UIImage(named: "app_icon") {
            headerIconImageView.image = appIcon
        } else {
            headerIconImageView.image = UIImage(systemName: "face.smiling")
            headerIconImageView.tintColor = .white
        }
        headerView.addSubview(headerIconImageView)
        
        let headerTitleLabel = UILabel()
        headerTitleLabel.text = SystemHelper.getAppName()
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headerTitleLabel)
        
        // 4. Create Vertical UIStackView for Menu Items
        let itemsStackView = UIStackView()
        itemsStackView.axis = .vertical
        itemsStackView.spacing = 8
        itemsStackView.alignment = .fill
        itemsStackView.distribution = .fillEqually
        itemsStackView.translatesAutoresizingMaskIntoConstraints = false
        sideMenuContainerView.addSubview(itemsStackView)
        
        // Create Menu Item Helper
        func createMenuItem(title: String, iconName: String, action: Selector) -> UIButton {
            let button = UIButton(type: .system)
            button.setTitle("  " + title, for: .normal)
            button.setImage(UIImage(systemName: iconName), for: .normal)
            button.tintColor = .label
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            button.addTarget(self, action: action, for: .touchUpInside)
            return button
        }
        
        let createAlarmBtn = createMenuItem(title: NSLocalizedString("menu_create_alarm", comment: "Side menu item to create an alarm"), iconName: "plus.circle", action: #selector(menuCreateAlarmTapped))
        createAlarmBtn.accessibilityIdentifier = "menu_create_alarm_button"
        
        let savedAlarmsBtn = createMenuItem(title: NSLocalizedString("menu_manage_alarms", comment: "Side menu item to manage alarms"), iconName: "alarm", action: #selector(menuSavedAlarmsTapped))
        savedAlarmsBtn.accessibilityIdentifier = "menu_manage_alarms_button"
        
        let aboutBtn = createMenuItem(title: NSLocalizedString("menu_about", comment: "Side menu item about the app"), iconName: "info.circle", action: #selector(menuAboutTapped))
        aboutBtn.accessibilityIdentifier = "menu_about_button"
        
        itemsStackView.addArrangedSubview(createAlarmBtn)
        itemsStackView.addArrangedSubview(savedAlarmsBtn)
        itemsStackView.addArrangedSubview(aboutBtn)
        
        // 5. Constraints Configuration
        let menuWidth = view.frame.width * sideMenuWidthMultiplier
        sideMenuLeadingConstraint = sideMenuContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -menuWidth)
        
        NSLayoutConstraint.activate([
            // Dimming View covers the full view
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Side Menu Container View
            sideMenuContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            sideMenuContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideMenuLeadingConstraint,
            sideMenuContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: sideMenuWidthMultiplier),
            
            // Header View
            headerView.topAnchor.constraint(equalTo: sideMenuContainerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: sideMenuContainerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: sideMenuContainerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120), // Height of orange header
            
            // Header Icon Image View
            headerIconImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            headerIconImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerIconImageView.widthAnchor.constraint(equalToConstant: 32),
            headerIconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // Header Title Label
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerIconImageView.centerYAnchor),
            headerTitleLabel.leadingAnchor.constraint(equalTo: headerIconImageView.trailingAnchor, constant: 10),
            headerTitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            // Items Stack View
            itemsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            itemsStackView.leadingAnchor.constraint(equalTo: sideMenuContainerView.leadingAnchor),
            itemsStackView.trailingAnchor.constraint(equalTo: sideMenuContainerView.trailingAnchor),
        ])
    }
    
    @objc func openSideMenu() {
        view.bringSubviewToFront(dimmingView)
        view.bringSubviewToFront(sideMenuContainerView)
        dimmingView.isHidden = false
        sideMenuLeadingConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dimmingView.alpha = 1.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func closeSideMenu() {
        let menuWidth = view.frame.width * sideMenuWidthMultiplier
        sideMenuLeadingConstraint.constant = -menuWidth
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.dimmingView.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dimmingView.isHidden = true
        })
    }
    
    @objc func menuCreateAlarmTapped() {
        closeSideMenu()
        openCreateAlarm()
    }
    
    func openCreateAlarm() {
        let childContainer = Container(parent: SwinjectStoryboard.defaultContainer)
        let alarmViewModel = childContainer.resolve(AlarmViewModel.self)!
        let editView = AlarmEditView(viewModel: alarmViewModel, alarm: nil)
        let hostingController = UIHostingController(rootView: editView)
        present(hostingController, animated: true, completion: nil)
    }
    
    @objc func menuSavedAlarmsTapped() {
        closeSideMenu()
        openAlarms(showAddAlarmInitially: false)
    }
    
    @objc func menuAboutTapped() {
        closeSideMenu()
        openAbout()
    }
    
    @objc func openAlarms() {
        openAlarms(showAddAlarmInitially: false)
    }
    
    func openAlarms(showAddAlarmInitially: Bool) {
        let childContainer = Container(parent: SwinjectStoryboard.defaultContainer)
        let viewModel = childContainer.resolve(AlarmViewModel.self)!
        let alarmView = AlarmListView(showAddAlarmInitially: showAddAlarmInitially, viewModel: viewModel)
        let hostingController = UIHostingController(rootView: alarmView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true, completion: nil)
    }
    
    @objc func openAbout() {
        let childContainer = Container(parent: SwinjectStoryboard.defaultContainer)
        let systemHelper = childContainer.resolve(SystemHelping.self)!
        let aboutView = AboutView(systemHelper: systemHelper)
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
        defaultContainer.register(SystemHelping.self) { _ in
            SystemHelperImpl()
        }
        defaultContainer.register(NSManagedObjectContext.self) { _ in
            CoreDataManager.shared.context
        }
        defaultContainer.register(AlarmRepository.self) { resolver in
            AlarmRepositoryImpl(context: resolver.resolve(NSManagedObjectContext.self)!)
        }
        defaultContainer.register(NotificationManaging.self) { _ in
            NotificationManager.shared
        }
        defaultContainer.register(AlarmViewModel.self) { resolver in
            AlarmViewModel(
                repository: resolver.resolve(AlarmRepository.self)!,
                notificationManager: resolver.resolve(NotificationManaging.self)!,
                speechService: resolver.resolve(SpeechService.self)!
            )
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
