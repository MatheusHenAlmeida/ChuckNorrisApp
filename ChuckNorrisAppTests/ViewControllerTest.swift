//
//  ViewControllerTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 25/04/24.
//

import XCTest
@testable import ChuckNorrisApp

final class MainViewModelMock: MainViewModel {
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

final class ViewControllerTest: XCTestCase {

    private var viewController: ViewController? = nil
    private var mainViewModel = MainViewModelMock()
    
    override func setUpWithError() throws {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.viewController = storyboard.instantiateViewController(withIdentifier: "MainStoryboard") as? ViewController
                
        mainViewModel = MainViewModelMock()
        viewController?.mainViewModel = mainViewModel
        viewController?.loadView()
        viewController?.viewDidLoad()
    }

    func testAskForJokeButtom_mustReturnJoke() async throws {
        mainViewModel.getJokeReturnValue = JokeResponse(id: "1", iconUrl: "url", value: "Some joke")
        
        let loadingBeforeApiResolves = await viewController?.loadingView.isHidden
        await viewController?.clickAskForJokeButton()
        sleep(2)
        let joke = await viewController?.myLabel.text
        let loadingAfterApiResolves = await viewController?.loadingView.isHidden
        
        XCTAssertEqual("Some joke", joke)
        XCTAssertFalse(loadingBeforeApiResolves == false)
        XCTAssertTrue(loadingAfterApiResolves == true)
        XCTAssertTrue(mainViewModel.getJokeCalled)
    }

    override func tearDownWithError() throws {
        // No-op
    }
}
