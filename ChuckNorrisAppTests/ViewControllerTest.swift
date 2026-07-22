//
//  ViewControllerTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 25/04/24.
//

import XCTest
@testable import ChuckNorrisApp

final class MainViewModelMock: MainViewModelType {
    var getJokeReturnValue: JokeResponse?
    var getJokeCalled = false
    var getJokeShouldThrow = false
    
    func getJoke() async throws -> JokeResponse? {
        getJokeCalled = true
        if getJokeShouldThrow {
            throw NSError(domain: "test", code: -1, userInfo: nil)
        }
        return getJokeReturnValue
    }
}

@MainActor
final class ViewControllerTest: XCTestCase {

    private var viewController: ViewController? = nil
    private var mainViewModel = MainViewModelMock()
    
    override func setUp() async throws {
        try await super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.viewController = storyboard.instantiateViewController(withIdentifier: "MainStoryboard") as? ViewController
                
        mainViewModel = MainViewModelMock()
        viewController?.mainViewModel = mainViewModel
        viewController?.loadView()
        viewController?.viewDidLoad()
    }

    func testAskForJokeButtom_mustReturnJoke() async throws {
        mainViewModel.getJokeReturnValue = JokeResponse(id: "1", iconUrl: "url", value: "Some joke")
        
        let loadingBeforeApiResolves = viewController?.loadingView.isHidden
        viewController?.clickAskForJokeButton()
        try await Task.sleep(nanoseconds: 2_000_000_000)
        let joke = viewController?.myLabel.text
        let loadingAfterApiResolves = viewController?.loadingView.isHidden
        
        XCTAssertEqual("Some joke", joke)
        XCTAssertFalse(loadingBeforeApiResolves == false)
        XCTAssertTrue(loadingAfterApiResolves == true)
        XCTAssertTrue(mainViewModel.getJokeCalled)
    }

    override func tearDown() async throws {
        try await super.tearDown()
    }
}
