//
//  CodableUserDefaultTests.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 23/2/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Testing
import Foundation
@testable import BFWFetch

@Suite("Codable+UserDefaults Tests")
struct CodableUserDefaultTests {
    
    private struct Person: Codable, Equatable {
        let name: String
        let age: Int
    }
    
    // MARK: - Helpers
    
    private func cleanUp(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // MARK: - Read Optional
    
    @Suite("userDefault() returning Optional")
    struct ReadOptionalTests {
        
        @Test("Returns nil when no value stored")
        func returnsNilWhenEmpty() {
            let key = "test_read_optional_nil"
            UserDefaults.standard.removeObject(forKey: key)
            let result: Person? = Person.userDefault(forKey: key)
            #expect(result == nil)
        }
        
        @Test("Returns value when stored")
        func returnsStoredValue() throws {
            let key = "test_read_optional_value"
            let person = Person(name: "Alice", age: 30)
            let data = try JSONEncoder().encode(person)
            UserDefaults.standard.set(data, forKey: key)
            defer { UserDefaults.standard.removeObject(forKey: key) }
            let result: Person? = Person.userDefault(forKey: key)
            #expect(result == person)
        }
        
        @Test("Returns nil when data is corrupted")
        func returnsNilForCorruptedData() {
            let key = "test_read_optional_corrupted"
            UserDefaults.standard.set(Data([0xFF, 0xFE]), forKey: key)
            defer { UserDefaults.standard.removeObject(forKey: key) }
            let result: Person? = Person.userDefault(forKey: key)
            #expect(result == nil)
        }
    }
    
    // MARK: - Read with Default
    
    @Suite("userDefault(default:) returning non-optional")
    struct ReadDefaultTests {
        
        @Test("Returns default when no value stored")
        func returnsDefaultWhenEmpty() {
            let key = "test_read_default_empty"
            UserDefaults.standard.removeObject(forKey: key)
            let fallback = Person(name: "Default", age: 0)
            let result = Person.userDefault(forKey: key, default: fallback)
            #expect(result == fallback)
        }
        
        @Test("Returns stored value over default")
        func returnsStoredValueOverDefault() throws {
            let key = "test_read_default_stored"
            let person = Person(name: "Bob", age: 25)
            let data = try JSONEncoder().encode(person)
            UserDefaults.standard.set(data, forKey: key)
            defer { UserDefaults.standard.removeObject(forKey: key) }
            let fallback = Person(name: "Default", age: 0)
            let result = Person.userDefault(forKey: key, default: fallback)
            #expect(result == person)
        }
    }
    
    // MARK: - Write
    
    @Suite("setUserDefault()")
    struct WriteTests {
        
        @Test("Stores a value that can be read back")
        func roundTrip() {
            let key = "test_write_roundtrip"
            defer { UserDefaults.standard.removeObject(forKey: key) }
            let person = Person(name: "Charlie", age: 40)
            person.setUserDefault(forKey: key)
            let result: Person? = Person.userDefault(forKey: key)
            #expect(result == person)
        }
        
        @Test("Overwrites a previous value")
        func overwrite() {
            let key = "test_write_overwrite"
            defer { UserDefaults.standard.removeObject(forKey: key) }
            let first = Person(name: "One", age: 1)
            first.setUserDefault(forKey: key)
            let second = Person(name: "Two", age: 2)
            second.setUserDefault(forKey: key)
            let result: Person? = Person.userDefault(forKey: key)
            #expect(result == second)
        }
    }
    
    // MARK: - Write Optional
    
    @Suite("Optional setUserDefault()")
    struct WriteOptionalTests {
        
        @Test("Stores a non-nil optional value")
        func storesNonNil() {
            let key = "test_write_optional_nonnil"
            defer { UserDefaults.standard.removeObject(forKey: key) }
            let person: Person? = Person(name: "Dana", age: 35)
            person.setUserDefault(forKey: key)
            let result: Person? = Person.userDefault(forKey: key)
            #expect(result == person)
        }
        
        @Test("Removes value when setting nil")
        func removesOnNil() {
            let key = "test_write_optional_nil"
            let person = Person(name: "Eve", age: 28)
            person.setUserDefault(forKey: key)
            let nilPerson: Person? = nil
            nilPerson.setUserDefault(forKey: key)
            let result: Person? = Person.userDefault(forKey: key)
            #expect(result == nil)
        }
    }
    
    // MARK: - Primitive Types
    
    @Suite("Primitive Codable types")
    struct PrimitiveTests {
        
        @Test("String round trip")
        func stringRoundTrip() {
            let key = "test_primitive_string"
            defer { UserDefaults.standard.removeObject(forKey: key) }
            "hello".setUserDefault(forKey: key)
            let result: String? = String.userDefault(forKey: key)
            #expect(result == "hello")
        }
        
        @Test("Int round trip")
        func intRoundTrip() {
            let key = "test_primitive_int"
            defer { UserDefaults.standard.removeObject(forKey: key) }
            42.setUserDefault(forKey: key)
            let result = Int.userDefault(forKey: key, default: 0)
            #expect(result == 42)
        }
        
        @Test("Array of strings round trip")
        func arrayRoundTrip() {
            let key = "test_primitive_array"
            defer { UserDefaults.standard.removeObject(forKey: key) }
            let urls = ["https://a.com", "https://b.com"]
            urls.setUserDefault(forKey: key)
            let result: [String]? = [String].userDefault(forKey: key)
            #expect(result == urls)
        }
    }
}
