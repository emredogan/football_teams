//
//  VerificationServiceTests.swift
//  Football_APITests
//
//  Created by Emre Dogan on 05/05/2022.
//

@testable import Football_API
import XCTest

class VerificationServiceTests: XCTestCase {
    var verificationService: VerificationService!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_verify_valid_username() throws {
        XCTAssertNoThrow( try VerificationService.verifyUsername("EMRE DOGAN"))
    }
    
    func test_verify_invalid_username() throws {
        let expectedError = VerifyError.invalidValue
        var actualError: VerifyError?

        XCTAssertThrowsError(try VerificationService.verifyUsername(nil)) { givenError in
            actualError = givenError as? VerifyError
        }
        XCTAssertEqual(expectedError, actualError)
        XCTAssertEqual(expectedError.errorDesc, actualError?.errorDesc)
    }
    
    func test_verify_too_short_username() throws {
        let expectedError = VerifyError.nameTooShort
        var actualError: VerifyError?

        XCTAssertThrowsError(try VerificationService.verifyUsername("emre")) { givenError in
            actualError = givenError as? VerifyError
        }
        XCTAssertEqual(expectedError, actualError)
    }
}
