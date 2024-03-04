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
        defaultContainer.register(ChuckNorrisWebClient.self) { _ in ChuckNorrisWebClient() }
        defaultContainer.register(MainViewModel.self) { r in
            return MainViewModel(webClient: r.resolve(ChuckNorrisWebClient.self)!)
        }
        defaultContainer.storyboardInitCompleted(ViewController.self) { r, c in
            c.mainViewModel = r.resolve(MainViewModel.self)
        }
    }
}
