//
//  Football_APIUITests.swift
//  Football_APIUITests
//
//  Created by Emre Dogan on 07/05/2022.
//

import XCTest

class Football_APIUITests: XCTestCase {
    let app = XCUIApplication()

    func testSuccessfulLogin() {
        app.launch()
        sleep(2) // Wait for animation to finish

        let emailTextField = app.textFields["E-mail"]
        emailTextField.tap()
        emailTextField.typeText("EMREDOGAN")
        dismissKeyboardIfPresent()
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123456")
        dismissKeyboardIfPresent()

        app.staticTexts["LOGIN"].tap()
        app.staticTexts["Premier League"].tap()
    }
    
    func dismissKeyboardIfPresent() {
        if app.keyboards.element(boundBy: 0).exists {
            if UIDevice.current.userInterfaceIdiom == .pad {
                app.keyboards.buttons["Hide keyboard"].tap()
            } else {
                app.toolbars.buttons["Done"].tap()
            }
        }
    }
}
