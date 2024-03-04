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
    
    var webClient: ChuckNorrisWebClient?
    
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
            if let joke = try? await webClient?.getJoke() {
                print(joke)
                myLabel.text = joke.value ?? ""
            }
        }
    }
}

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.register(ChuckNorrisWebClient.self) { _ in ChuckNorrisWebClient() }
        defaultContainer.storyboardInitCompleted(ViewController.self) { r, c in
            c.webClient = r.resolve(ChuckNorrisWebClient.self)
        }
    }
}
