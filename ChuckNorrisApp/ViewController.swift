//
//  ViewController.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import UIKit
import SwinjectStoryboard

class ViewController: UIViewController {

    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var askForJokeButton: UIButton!
        
    @IBOutlet weak var tellJokeButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    
    var mainViewModel: MainViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIds()
        setButton()
    }
    
    private func setIds() {
        askForJokeButton.accessibilityIdentifier = "ask_joke_button"
        myLabel.accessibilityIdentifier = "joke_label"
    }
    
    private func setButton() {
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
                myLabel.text = joke.value ?? DefaultMessages.tryItLater
            } else {
                myLabel.text = DefaultMessages.tryItLater
            }
            loadingView.isHidden = true
        }
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
        defaultContainer.storyboardInitCompleted(ViewController.self) { resolver, viewController in
            viewController.mainViewModel = resolver.resolve(MainViewModel.self)
        }
    }
}

struct DefaultMessages {
    static let tryItLater = "Try it later"
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
