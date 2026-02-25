//  Created by Aji Prakosa on 25 February 2026.

import XCTest

final class MovieDBUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
    }
    
    func testMovieListFlow() {
        // Wait for movies to load
        let firstMovie = app.collectionViews.cells.element(boundBy: 0)
        XCTAssertTrue(firstMovie.waitForExistence(timeout: 5))
        
        // Tap on first movie
        firstMovie.tap()
        
        // Verify we're on detail screen
        XCTAssertTrue(app.navigationBars.staticTexts.firstMatch.waitForExistence(timeout: 2))
        
        // Go back to list
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Verify we're back on list
        XCTAssertTrue(app.navigationBars["Film Terbaru"].waitForExistence(timeout: 2))
    }
    
    func testDetailTabs() {
        // Go to detail screen
        let firstMovie = app.collectionViews.cells.element(boundBy: 0)
        XCTAssertTrue(firstMovie.waitForExistence(timeout: 5))
        firstMovie.tap()
        
        // Switch to reviews tab
        app.segmentedControls.buttons["Ulasan"].tap()
        
        // Verify reviews tab content
        if app.staticTexts["Belum ada ulasan"].exists {
            // Handle case where no reviews
        } else {
            XCTAssertTrue(app.staticTexts.element(boundBy: 0).waitForExistence(timeout: 2))
        }
        
        // Switch to trailer tab
        app.segmentedControls.buttons["Trailer"].tap()
        
        // Verify trailer tab content
        if app.staticTexts["Trailer tidak tersedia"].exists {
            // Handle case where no trailer
        } else {
            XCTAssertTrue(app.otherElements["YouTubePlayer"].waitForExistence(timeout: 2))
        }
    }
    
    func testSearch() {
        // Enter search text
        app.searchFields["Cari film..."].tap()
        app.searchFields["Cari film..."].typeText("Test")
        
        // Verify search is working
        XCTAssertTrue(app.collectionViews.cells.firstMatch.waitForExistence(timeout: 2))
    }
}
