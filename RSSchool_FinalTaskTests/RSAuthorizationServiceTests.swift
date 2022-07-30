//
//  RSAuthorizationServiceTests.swift
//  RSSchool_FinalTaskTests
//
//  Created by Kirill on 12.11.21.
//

import XCTest
@testable import RSSchool_FinalTask

class RSAuthorizationServiceTests: XCTestCase {
    
    var authorizationService: AuthorizationService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        authorizationService = AuthorizationService()
    }

    override func tearDownWithError() throws {
        authorizationService = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
//        let image = RSDefaultIcons.defaultAvatar
//        let promice = expectation(description: "Image saving success")
//        authorizationService.saveCurrentUserAvatar(image: image) { result in
//            switch result {
//            case .success:
//                XCTAssert(true)
//                promice.fulfill()
//            case .failure(let string):
//                XCTFail(string)
//            }
//        }
//
//        wait(for: [promice], timeout: 10)
//
//        authorizationService.getCurrentUserAvatar { avatar in
//            XCTAssertEqual(image, avatar)
//        }
    }

}
