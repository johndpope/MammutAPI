//
// Created by Esteban Torres on 17.04.17.
// Copyright (c) 2017 Esteban Torres. All rights reserved.
//

import Foundation
import XCTest
@testable import MammutAPI

internal class StatusMapperTests: XCTestCase {
    var subject: StatusMapper!

    override func setUp()  {
        subject = StatusMapper()
    }

    // MARK: `data` mapping tests
    func test_map_emptyData_failure_invalidJSON() throws {
        let result = subject.map(data: Data())
        let error: MammutAPIError.MappingError = try AssertNotNilAndUnwrap(result.error)
        XCTAssertEqual(error, MammutAPIError.MappingError.invalidJSON)
    }

    func test_map_invalidData_failure_incompleteModel() throws {
        let data = try Fixture.loadData(from: "IncompleteJSON.json")
        XCTAssertNotNil(data)
        let result = subject.map(data: data)
        XCTAssertNil(result.value)
        let error: MammutAPIError.MappingError = try AssertNotNilAndUnwrap(result.error)
        XCTAssertEqual(error, MammutAPIError.MappingError.incompleteModel)
    }

    func test_map_validData_success() throws {
        let data = try Fixture.loadData(from: "Status.json")
        XCTAssertNotNil(data)
        let result = subject.map(data: data)
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.value)
    }

    func test_map_validData_success_withExpectedValues() throws {
        let fileName = "Status.json"
        let data = try Fixture.loadData(from: fileName)
        let expectedData = try Fixture.loadJSON(from: fileName)
        XCTAssertNotNil(expectedData)
        let result = subject.map(data: data)
        if case .success(let status) = result {
            XCTAssertEqual(status.id, expectedData["id"] as! Int)
        } else {
            XCTFail("Should have returned a parsed «Status»")
        }
    }

    // MARK: `json` mapping tests

    func test_map_invalidJSON_failure_incompleteModel() throws {
        let json = try Fixture.loadJSON(from: "IncompleteJSON.json")
        XCTAssertNotNil(json)
        let result = subject.map(json: json)
        XCTAssertNil(result.value)
        let error: MammutAPIError.MappingError = try AssertNotNilAndUnwrap(result.error)
        XCTAssertEqual(error, MammutAPIError.MappingError.incompleteModel)
    }

    func test_map_validJSON_success() throws {
        let json = try Fixture.loadJSON(from: "Status.json")
        XCTAssertNotNil(json)
        let result = subject.map(json: json)
        XCTAssertNil(result.error)
        XCTAssertNotNil(result.value)
    }

    func test_map_validJSON_success_withExpectedValues() throws {
        let fileName = "Status.json"
        let json = try Fixture.loadJSON(from: fileName)
        let expectedData = try Fixture.loadJSON(from: fileName)
        XCTAssertNotNil(expectedData)
        let result = subject.map(json: json)
        if case .success(let status) = result {
            XCTAssertEqual(status.id, expectedData["id"] as! Int)
        } else {
            XCTFail("Should have returned a parsed «Status»")
        }
    }

    func test_mapData_mapJSON_producesSameModel() throws {
        let fileName = "Status.json"
        let json = try Fixture.loadJSON(from: fileName)
        let data = try Fixture.loadData(from: fileName)
        XCTAssertNotNil(json)
        XCTAssertNotNil(data)

        let mappedFromJSON = subject.map(json: json)
        let mappedFromData = subject.map(data: data)
        let statusFromJSON: Status = try AssertNotNilAndUnwrap(mappedFromJSON.value)
        let statusFromData: Status = try AssertNotNilAndUnwrap(mappedFromData.value)
        XCTAssertEqual(statusFromData, statusFromJSON)
    }

    func test_map_jsonWithoutApplication_setsApplicationToNil() throws {
        let fileName = "Status.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertNil(status.application)
    }

    func test_map_jsonWithApplication_setsApplicationToValidApplicationObject() throws {
        let fileName = "StatusWithApplication.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertNotNil(status.application)
    }

    func test_map_jsonWithAttachments_setsAttachmentsToValidAttachmentsObjects() throws {
        let fileName = "StatusWithAttachments.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertGreaterThanOrEqual(status.mediaAttachments.count, 3)
    }

    func test_map_jsonWithoutAttachments_setsAttachmentsToEmptyArray() throws {
        let fileName = "Status.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertEqual(status.mediaAttachments.count, 0)
    }

    func test_map_jsonWith1InvalidAnd2ValidAttachments_setsAttachmentsToArrayOf2() throws {
        let fileName = "StatusWithInvalidAttachments.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertEqual(status.mediaAttachments.count, 2)
    }

    func test_map_jsonWithMentions_setsMentionsToValidMentionObjects() throws {
        let fileName = "StatusWithMentions.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertGreaterThanOrEqual(status.mentions.count, 3)
    }

    func test_map_jsonWithoutMentions_setsMentionsToEmptyArray() throws {
        let fileName = "Status.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertEqual(status.mentions.count, 0)
    }

    func test_map_jsonWithTags_setsTagsToValidTagObjects() throws {
        let fileName = "StatusWithTags.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertGreaterThanOrEqual(status.tags.count, 3)
    }

    func test_map_jsonWithoutTags_setsTagsToEmptyArray() throws {
        let fileName = "Status.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertEqual(status.tags.count, 0)
    }

    func test_map_jsonWithoutReblog_setsReblogToNil() throws {
        let fileName = "Status.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertNil(status.reblog)
    }

    func test_map_jsonWithReblog_setsReblogToValidStatusObject() throws {
        let fileName = "StatusWithReblog.json"
        let json = try Fixture.loadJSON(from: fileName)
        let result = subject.map(json: json)
        let status: Status = try AssertNotNilAndUnwrap(result.value)
        XCTAssertNil(result.error)
        XCTAssertNotNil(status.reblog)
    }
}

// MARK: - Linux Support

extension StatusMapperTests {
    static var allTests: [(String, (StatusMapperTests) -> () throws -> Void)] {
        return [
                ("test_map_emptyData_failure_invalidJSON", test_map_emptyData_failure_invalidJSON),
                ("test_map_invalidData_failure_incompleteModel", test_map_invalidData_failure_incompleteModel),
                ("test_map_validData_success", test_map_validData_success),
                ("test_map_validData_success_withExpectedValues", test_map_validData_success_withExpectedValues),
                ("test_map_invalidJSON_failure_incompleteModel", test_map_invalidJSON_failure_incompleteModel),
                ("test_map_validJSON_success", test_map_validJSON_success),
                ("test_map_validJSON_success_withExpectedValues", test_map_validJSON_success_withExpectedValues),
                ("test_mapData_mapJSON_producesSameModel", test_mapData_mapJSON_producesSameModel),
                ("test_map_jsonWithoutApplication_setsApplicationToNil", test_map_jsonWithoutApplication_setsApplicationToNil),
                ("test_map_jsonWithApplication_setsApplicationToValidApplicationObject", test_map_jsonWithApplication_setsApplicationToValidApplicationObject),
                ("test_map_jsonWithAttachments_setsAttachmentsToValidAttachmentsObjects", test_map_jsonWithAttachments_setsAttachmentsToValidAttachmentsObjects),
                ("test_map_jsonWithoutAttachments_setsAttachmentsToEmptyArray", test_map_jsonWithoutAttachments_setsAttachmentsToEmptyArray),
                ("test_map_jsonWith1InvalidAnd2ValidAttachments_setsAttachmentsToArrayOf2", test_map_jsonWith1InvalidAnd2ValidAttachments_setsAttachmentsToArrayOf2),
                ("test_map_jsonWithMentions_setsMentionsToValidMentionObjects", test_map_jsonWithMentions_setsMentionsToValidMentionObjects),
                ("test_map_jsonWithoutMentions_setsMentionsToEmptyArray", test_map_jsonWithoutMentions_setsMentionsToEmptyArray),
                ("test_map_jsonWithTags_setsTagsToValidTagObjects", test_map_jsonWithTags_setsTagsToValidTagObjects),
                ("test_map_jsonWithoutTags_setsTagsToEmptyArray", test_map_jsonWithoutTags_setsTagsToEmptyArray),
                ("test_map_jsonWithoutReblog_setsReblogToNil", test_map_jsonWithoutReblog_setsReblogToNil),
                ("test_map_jsonWithReblog_setsReblogToValidStatusObject", test_map_jsonWithReblog_setsReblogToValidStatusObject)
        ]
    }
}
