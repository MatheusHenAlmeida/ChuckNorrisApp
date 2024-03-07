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
    
    var mainViewModel: MainViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        setButton()
    }
    
    private func setButton() {
        askForJokeButton.addTarget(self, action: #selector(askForJokeAction), for: .touchDown)
    }
    
    @objc func askForJokeAction() {
        Task {
            if let joke = try? await mainViewModel?.getJoke() {
                myLabel.text = joke.value ?? ""
            }
        }
    }
}

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.register(ChuckNorrisService.self) { _ in
            ChuckNorrisService(baseUrl: "https://api.chucknorris.io/jokes")
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
