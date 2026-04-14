//
//  JSONTests.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 25/8/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

import Testing
import Foundation
@testable import BFWFetch

@Suite("JSON Tests")
struct JSONTests {
    
    // MARK: - Equatable Tests
    
    @Suite("Equatable Conformance")
    struct EquatableTests {
        
        @Test("String JSONs are equal")
        func stringEquality() {
            let json1: JSON = "hello"
            let json2: JSON = "hello"
            let json3: JSON = "world"
            #expect(json1 == json2)
            #expect(json1 != json3)
        }
        
        @Test("Int JSONs are equal")
        func intEquality() {
            let json1: JSON = 42
            let json2: JSON = 42
            let json3: JSON = 100
            #expect(json1 == json2)
            #expect(json1 != json3)
        }
        
        @Test("Double JSONs are equal")
        func doubleEquality() {
            let json1: JSON = 3.14
            let json2: JSON = 3.14
            let json3: JSON = 2.71
            #expect(json1 == json2)
            #expect(json1 != json3)
        }
        
        @Test("Bool JSONs are equal")
        func boolEquality() {
            let json1: JSON = true
            let json2: JSON = true
            let json3: JSON = false
            #expect(json1 == json2)
            #expect(json1 != json3)
        }
        
        @Test("Null JSONs are equal")
        func nullEquality() {
            let json1: JSON = .null
            let json2: JSON = .null
            #expect(json1 == json2)
        }
        
        @Test("Array JSONs are equal")
        func arrayEquality() {
            let json1: JSON = [1, 2, 3]
            let json2: JSON = [1, 2, 3]
            let json3: JSON = [1, 2, 4]
            let json4: JSON = [1, 2]
            #expect(json1 == json2)
            #expect(json1 != json3)
            #expect(json1 != json4)
        }
        
        @Test("Dictionary JSONs are equal")
        func dictionaryEquality() {
            let json1: JSON = ["name": "John", "age": 30]
            let json2: JSON = ["name": "John", "age": 30]
            let json3: JSON = ["name": "Jane", "age": 30]
            let json4: JSON = ["name": "John"]
            #expect(json1 == json2)
            #expect(json1 != json3)
            #expect(json1 != json4)
        }
        
        @Test("Nested structures are equal")
        func nestedEquality() {
            let json1: JSON = [
                "user": [
                    "name": "John",
                    "age": 30,
                    "tags": ["swift", "ios"]
                ]
            ]
            let json2: JSON = [
                "user": [
                    "name": "John",
                    "age": 30,
                    "tags": ["swift", "ios"]
                ]
            ]
            let json3: JSON = [
                "user": [
                    "name": "John",
                    "age": 30,
                    "tags": ["swift", "macos"]
                ]
            ]
            #expect(json1 == json2)
            #expect(json1 != json3)
        }
        
        @Test("Different types are not equal")
        func differentTypesInequality() {
            let stringJSON: JSON = "42"
            let intJSON: JSON = 42
            let doubleJSON: JSON = 42.0
            let boolJSON: JSON = true
            let nullJSON: JSON = .null
            #expect(stringJSON != intJSON)
            #expect(intJSON != doubleJSON)
            #expect(stringJSON != boolJSON)
            #expect(intJSON != nullJSON)
        }
    }
    
    // MARK: - removingDuplicates Tests
    
    @Suite("removingDuplicates Function")
    struct RemovingDuplicatesTests {
        
        @Test("Remove duplicate JSONs from dictionary")
        func dictionaryRemoveDuplicates() throws {
            let original: JSON = [
                "name": "John",
                "age": 30,
                "city": "New York",
                "country": "USA"
            ]
            let compared: JSON = [
                "name": "John",
                "age": 25,
                "city": "New York"
            ]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultDict = try result.dictionary()
            
            // Should keep "age" (different), "country" (not in compared)
            // Should remove "name" and "city" (same values)
            #expect(resultDict.count == 2)
            #expect(resultDict["age"] == 30)
            #expect(resultDict["country"] == "USA")
            #expect(resultDict["name"] == nil)
            #expect(resultDict["city"] == nil)
        }
        
        @Test("Remove all duplicates from dictionary")
        func dictionaryRemoveAllDuplicates() throws {
            let original: JSON = [
                "name": "John",
                "age": 30
            ]
            let compared: JSON = [
                "name": "John",
                "age": 30
            ]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultDict = try result.dictionary()
            #expect(resultDict.isEmpty)
        }
        
        @Test("Keep all JSONs when no duplicates in dictionary")
        func dictionaryKeepAllNoDuplicates() throws {
            let original: JSON = [
                "name": "John",
                "age": 30,
                "city": "New York"
            ]
            let compared: JSON = [
                "name": "Jane",
                "age": 25,
                "city": "Boston"
            ]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultDict = try result.dictionary()
            #expect(resultDict.count == 3)
            #expect(resultDict["name"] == "John")
            #expect(resultDict["age"] == 30)
            #expect(resultDict["city"] == "New York")
        }
        
        @Test("Keep JSONs not in compared dictionary")
        func dictionaryKeepUniqueKeys() throws {
            let original: JSON = [
                "name": "John",
                "age": 30,
                "email": "john@example.com"
            ]
            let compared: JSON = [
                "name": "John"
            ]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultDict = try result.dictionary()
            
            // Should keep "age" and "email" (not in compared), remove "name" (duplicate)
            #expect(resultDict.count == 2)
            #expect(resultDict["age"] == 30)
            #expect(resultDict["email"] == "john@example.com")
            #expect(resultDict["name"] == nil)
        }
        
        @Test("Remove duplicate JSONs from array")
        func arrayRemoveDuplicates() throws {
            let original: JSON = [1, 2, 3, 4, 5]
            let compared: JSON = [1, 20, 3, 40]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultArray = try result.array()
            
            // Should keep index 1 (2 != 20), 3 (4 != 40), and 4 (5, out of bounds)
            // Should remove index 0 (1 == 1) and 2 (3 == 3)
            #expect(resultArray.count == 3)
            #expect(resultArray[0] == 2)
            #expect(resultArray[1] == 4)
            #expect(resultArray[2] == 5)
        }
        
        @Test("Remove all duplicates from array")
        func arrayRemoveAllDuplicates() throws {
            let original: JSON = [1, 2, 3]
            let compared: JSON = [1, 2, 3]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultArray = try result.array()
            #expect(resultArray.isEmpty)
        }
        
        @Test("Keep all JSONs when array is longer than compared")
        func arrayKeepExtraElements() throws {
            let original: JSON = [1, 2, 3, 4, 5]
            let compared: JSON = [1, 2]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultArray = try result.array()
            
            // Should keep index 2, 3, 4 (out of bounds in compared)
            #expect(resultArray.count == 3)
            #expect(resultArray[0] == 3)
            #expect(resultArray[1] == 4)
            #expect(resultArray[2] == 5)
        }
        
        @Test("Scalar JSONs return null when equal")
        func scalarEqualReturnsNull() throws {
            let original: JSON = "hello"
            let compared: JSON = "hello"
            let result = try original.removingDuplicates(comparedValue: compared)
            #expect(result == .null)
        }
        
        @Test("Scalar JSONs return self when different")
        func scalarDifferentReturnsSelf() throws {
            let original: JSON = "hello"
            let compared: JSON = "world"
            let result = try original.removingDuplicates(comparedValue: compared)
            #expect(result == "hello")
        }
        
        @Test("Nested dictionary removes duplicates")
        func nestedDictionaryRemoveDuplicates() throws {
            let original: JSON = [
                "user": [
                    "name": "John",
                    "age": 30,
                    "city": "New York"
                ],
                "status": "active"
            ]
            let compared: JSON = [
                "user": [
                    "name": "John",
                    "age": 25,
                    "city": "New York"
                ],
                "status": "active"
            ]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultDict = try result.dictionary()
            
            // "status" should be removed (duplicate)
            // "user" should remain but only contain "age" (different value)
            #expect(resultDict.count == 1)
            #expect(resultDict["status"] == nil)
            let userDict = try resultDict["user"]?.dictionary()
            #expect(userDict?.count == 1)
            #expect(userDict?["age"] == 30)
            #expect(userDict?["name"] == nil)
            #expect(userDict?["city"] == nil)
        }
    }
    
    // MARK: - inserted Tests
    
    @Suite("inserted Function")
    struct InsertedTests {
        
        @Test("Replace single placeholder")
        func singlePlaceholder() {
            let json: JSON = ["id": "123"]
            let template = "vehicles/{id}/drivers"
            let result = json.inserted(into: template)
            #expect(result == "vehicles/123/drivers")
        }
        
        @Test("Replace multiple placeholders")
        func multiplePlaceholders() {
            let json: JSON = [
                "vehicleId": "456",
                "driverId": "789"
            ]
            let template = "vehicles/{vehicleId}/drivers/{driverId}"
            let result = json.inserted(into: template)
            #expect(result == "vehicles/456/drivers/789")
        }
        
        @Test("Leave unmatched placeholders unchanged")
        func unmatchedPlaceholders() {
            let json: JSON = ["id": "123"]
            let template = "vehicles/{id}/drivers/{name}"
            let result = json.inserted(into: template)
            #expect(result == "vehicles/123/drivers/{name}")
        }
        
        @Test("Handle underscore in key names")
        func underscoreInKeys() {
            let json: JSON = ["user_id": "abc123"]
            let template = "users/{user_id}/profile"
            let result = json.inserted(into: template)
            #expect(result == "users/abc123/profile")
        }
        
        @Test("Handle numeric values in placeholders")
        func numericPlaceholders() {
            let json: JSON = ["id123": "value"]
            let template = "items/{id123}"
            let result = json.inserted(into: template)
            #expect(result == "items/value")
        }
        
        @Test("Return unchanged when no placeholders")
        func noPlaceholders() {
            let json: JSON = ["id": "123"]
            let template = "vehicles/all/drivers"
            let result = json.inserted(into: template)
            #expect(result == "vehicles/all/drivers")
        }
        
        @Test("Return unchanged when JSON is not dictionary")
        func nonDictionary() {
            let json: JSON = "not a dictionary"
            let template = "vehicles/{id}/drivers"
            let result = json.inserted(into: template)
            #expect(result == "vehicles/{id}/drivers")
        }
        
        @Test("Handle empty dictionary")
        func emptyDictionary() {
            let json: JSON = [:]
            let template = "vehicles/{id}/drivers"
            let result = json.inserted(into: template)
            #expect(result == "vehicles/{id}/drivers")
        }
    }
}
