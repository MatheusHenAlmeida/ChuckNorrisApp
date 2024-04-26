//
//  ViewControllerTest.swift
//  ChuckNorrisAppTests
//
//  Created by Matheus Henrique Almeida on 25/04/24.
//

import XCTest
import Mockingbird
@testable import ChuckNorrisApp

final class ViewControllerTest: XCTestCase {

    private var viewController: ViewController? = nil
    
    private lazy var mainViewModel = mock(MainViewModel.self)
    
    override func setUpWithError() throws {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.viewController = storyboard.instantiateViewController(withIdentifier: "MainStoryboard") as? ViewController
                
        viewController?.mainViewModel = mainViewModel
        viewController?.loadView()
        viewController?.viewDidLoad()
    }

    func testAskForJokeButtom_mustReturnJoke() async throws {
        given(await mainViewModel.getJoke()).willReturn(JokeResponse(id: "1", iconUrl: "url", value: "Some joke"))
        
        let loadingBeforeApiResolves = await viewController?.loadingView.isHidden
        await viewController?.clickAskForJokeButton()
        sleep(2)
        let joke = await viewController?.myLabel.text
        let loadingAfterApiResolves = await viewController?.loadingView.isHidden
        
        XCTAssertEqual("Some joke", joke)
        XCTAssertFalse(loadingBeforeApiResolves == false)
        XCTAssertTrue(loadingAfterApiResolves == true)
        verify(await mainViewModel.getJoke()).wasCalled()
    }

    override func tearDownWithError() throws {
        clearStubs(on: mainViewModel)
    }
}
