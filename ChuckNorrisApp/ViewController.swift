//
//  ViewController.swift
//  ChuckNorrisApp
//
//  Created by Matheus Henrique Almeida on 04/03/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var askForJokeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setButton()
    }
    
    private func setButton() {
        askForJokeButton.addTarget(self, action: #selector(askForJokeAction), for: .touchDown)
    }
    
    @objc func askForJokeAction() {
        Task {
            let webClient = AppDelegate.container.resolve(ChuckNorrisWebClient.self)
            if let joke = try? await webClient?.getJoke() {
                print(joke)
                myLabel.text = joke.value ?? ""
            }
        }
    }
}

