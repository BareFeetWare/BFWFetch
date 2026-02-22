//
//  CodableValueTests.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 25/8/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

import Testing
import Foundation
@testable import BFWFetch

@Suite("CodableValue Tests")
struct CodableValueTests {
    
    // MARK: - Equatable Tests
    
    @Suite("Equatable Conformance")
    struct EquatableTests {
        
        @Test("String values are equal")
        func stringEquality() {
            let value1: CodableValue = "hello"
            let value2: CodableValue = "hello"
            let value3: CodableValue = "world"
            #expect(value1 == value2)
            #expect(value1 != value3)
        }
        
        @Test("Int values are equal")
        func intEquality() {
            let value1: CodableValue = 42
            let value2: CodableValue = 42
            let value3: CodableValue = 100
            #expect(value1 == value2)
            #expect(value1 != value3)
        }
        
        @Test("Double values are equal")
        func doubleEquality() {
            let value1: CodableValue = 3.14
            let value2: CodableValue = 3.14
            let value3: CodableValue = 2.71
            #expect(value1 == value2)
            #expect(value1 != value3)
        }
        
        @Test("Bool values are equal")
        func boolEquality() {
            let value1: CodableValue = true
            let value2: CodableValue = true
            let value3: CodableValue = false
            #expect(value1 == value2)
            #expect(value1 != value3)
        }
        
        @Test("Null values are equal")
        func nullEquality() {
            let value1: CodableValue = .null
            let value2: CodableValue = .null
            #expect(value1 == value2)
        }
        
        @Test("Array values are equal")
        func arrayEquality() {
            let value1: CodableValue = [1, 2, 3]
            let value2: CodableValue = [1, 2, 3]
            let value3: CodableValue = [1, 2, 4]
            let value4: CodableValue = [1, 2]
            #expect(value1 == value2)
            #expect(value1 != value3)
            #expect(value1 != value4)
        }
        
        @Test("Dictionary values are equal")
        func dictionaryEquality() {
            let value1: CodableValue = ["name": "John", "age": 30]
            let value2: CodableValue = ["name": "John", "age": 30]
            let value3: CodableValue = ["name": "Jane", "age": 30]
            let value4: CodableValue = ["name": "John"]
            #expect(value1 == value2)
            #expect(value1 != value3)
            #expect(value1 != value4)
        }
        
        @Test("Nested structures are equal")
        func nestedEquality() {
            let value1: CodableValue = [
                "user": [
                    "name": "John",
                    "age": 30,
                    "tags": ["swift", "ios"]
                ]
            ]
            let value2: CodableValue = [
                "user": [
                    "name": "John",
                    "age": 30,
                    "tags": ["swift", "ios"]
                ]
            ]
            let value3: CodableValue = [
                "user": [
                    "name": "John",
                    "age": 30,
                    "tags": ["swift", "macos"]
                ]
            ]
            #expect(value1 == value2)
            #expect(value1 != value3)
        }
        
        @Test("Different types are not equal")
        func differentTypesInequality() {
            let string: CodableValue = "42"
            let int: CodableValue = 42
            let double: CodableValue = 42.0
            let bool: CodableValue = true
            let null: CodableValue = .null
            #expect(string != int)
            #expect(int != double)
            #expect(string != bool)
            #expect(int != null)
        }
    }
    
    // MARK: - removingDuplicates Tests
    
    @Suite("removingDuplicates Function")
    struct RemovingDuplicatesTests {
        
        @Test("Remove duplicate values from dictionary")
        func dictionaryRemoveDuplicates() throws {
            let original: CodableValue = [
                "name": "John",
                "age": 30,
                "city": "New York",
                "country": "USA"
            ]
            let compared: CodableValue = [
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
            let original: CodableValue = [
                "name": "John",
                "age": 30
            ]
            let compared: CodableValue = [
                "name": "John",
                "age": 30
            ]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultDict = try result.dictionary()
            #expect(resultDict.isEmpty)
        }
        
        @Test("Keep all values when no duplicates in dictionary")
        func dictionaryKeepAllNoDuplicates() throws {
            let original: CodableValue = [
                "name": "John",
                "age": 30,
                "city": "New York"
            ]
            let compared: CodableValue = [
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
        
        @Test("Keep values not in compared dictionary")
        func dictionaryKeepUniqueKeys() throws {
            let original: CodableValue = [
                "name": "John",
                "age": 30,
                "email": "john@example.com"
            ]
            let compared: CodableValue = [
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
        
        @Test("Remove duplicate values from array")
        func arrayRemoveDuplicates() throws {
            let original: CodableValue = [1, 2, 3, 4, 5]
            let compared: CodableValue = [1, 20, 3, 40]
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
            let original: CodableValue = [1, 2, 3]
            let compared: CodableValue = [1, 2, 3]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultArray = try result.array()
            #expect(resultArray.isEmpty)
        }
        
        @Test("Keep all values when array is longer than compared")
        func arrayKeepExtraElements() throws {
            let original: CodableValue = [1, 2, 3, 4, 5]
            let compared: CodableValue = [1, 2]
            let result = try original.removingDuplicates(comparedValue: compared)
            let resultArray = try result.array()
            
            // Should keep index 2, 3, 4 (out of bounds in compared)
            #expect(resultArray.count == 3)
            #expect(resultArray[0] == 3)
            #expect(resultArray[1] == 4)
            #expect(resultArray[2] == 5)
        }
        
        @Test("Scalar values return null when equal")
        func scalarEqualReturnsNull() throws {
            let original: CodableValue = "hello"
            let compared: CodableValue = "hello"
            let result = try original.removingDuplicates(comparedValue: compared)
            #expect(result == .null)
        }
        
        @Test("Scalar values return self when different")
        func scalarDifferentReturnsSelf() throws {
            let original: CodableValue = "hello"
            let compared: CodableValue = "world"
            let result = try original.removingDuplicates(comparedValue: compared)
            #expect(result == "hello")
        }
        
        @Test("Nested dictionary removes duplicates")
        func nestedDictionaryRemoveDuplicates() throws {
            let original: CodableValue = [
                "user": [
                    "name": "John",
                    "age": 30,
                    "city": "New York"
                ],
                "status": "active"
            ]
            let compared: CodableValue = [
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
            let value: CodableValue = ["id": "123"]
            let template = "vehicles/{id}/drivers"
            let result = value.inserted(into: template)
            #expect(result == "vehicles/123/drivers")
        }
        
        @Test("Replace multiple placeholders")
        func multiplePlaceholders() {
            let value: CodableValue = [
                "vehicleId": "456",
                "driverId": "789"
            ]
            let template = "vehicles/{vehicleId}/drivers/{driverId}"
            let result = value.inserted(into: template)
            #expect(result == "vehicles/456/drivers/789")
        }
        
        @Test("Leave unmatched placeholders unchanged")
        func unmatchedPlaceholders() {
            let value: CodableValue = ["id": "123"]
            let template = "vehicles/{id}/drivers/{name}"
            let result = value.inserted(into: template)
            #expect(result == "vehicles/123/drivers/{name}")
        }
        
        @Test("Handle underscore in key names")
        func underscoreInKeys() {
            let value: CodableValue = ["user_id": "abc123"]
            let template = "users/{user_id}/profile"
            let result = value.inserted(into: template)
            #expect(result == "users/abc123/profile")
        }
        
        @Test("Handle numeric values in placeholders")
        func numericPlaceholders() {
            let value: CodableValue = ["id123": "value"]
            let template = "items/{id123}"
            let result = value.inserted(into: template)
            #expect(result == "items/value")
        }
        
        @Test("Return unchanged when no placeholders")
        func noPlaceholders() {
            let value: CodableValue = ["id": "123"]
            let template = "vehicles/all/drivers"
            let result = value.inserted(into: template)
            #expect(result == "vehicles/all/drivers")
        }
        
        @Test("Return unchanged when value is not dictionary")
        func nonDictionaryValue() {
            let value: CodableValue = "not a dictionary"
            let template = "vehicles/{id}/drivers"
            let result = value.inserted(into: template)
            #expect(result == "vehicles/{id}/drivers")
        }
        
        @Test("Handle empty dictionary")
        func emptyDictionary() {
            let value: CodableValue = [:]
            let template = "vehicles/{id}/drivers"
            let result = value.inserted(into: template)
            #expect(result == "vehicles/{id}/drivers")
        }
    }
}
