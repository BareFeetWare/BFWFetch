//
//  MultipartBodyTests.swift
//  BFWFetchTests
//
//  Created by Tom Brodhurst-Hill on 21/4/2026.
//  Copyright © 2026 BareFeetWare. All rights reserved.
//

import Testing
import Foundation
@testable import BFWFetch

@Suite("Multipart Body Tests")
struct MultipartBodyTests {
    
    // MARK: - Helpers
    
    private static func sampleRequest(parts: [HTTP.Body.Part]) throws -> URLRequest {
        try URLRequest(url: URL(string: "https://example.com")!)
            .httpBody(encoding: .parts(parts))
    }
    
    private static func boundary(request: URLRequest) throws -> String {
        let contentType = try #require(request.value(forHTTPHeaderField: "Content-Type"))
        let prefix = "multipart/form-data; boundary="
        try #require(contentType.hasPrefix(prefix))
        return String(contentType.dropFirst(prefix.count))
    }
    
    private static func bodyString(request: URLRequest) throws -> String {
        let body = try #require(request.httpBody)
        return try #require(String(data: body, encoding: .utf8))
    }
    
    // MARK: - Tests
    
    @Test("Content-Type header is multipart/form-data with a non-empty boundary")
    func contentTypeHeader() throws {
        let request = try Self.sampleRequest(parts: [.text(name: "k", value: "v")])
        let boundary = try Self.boundary(request: request)
        #expect(!boundary.isEmpty)
    }
    
    @Test("Single text part has CRLF blank line between header and value")
    func singleTextPart() throws {
        let request = try Self.sampleRequest(parts: [.text(name: "field", value: "value")])
        let boundary = try Self.boundary(request: request)
        let bodyString = try Self.bodyString(request: request)
        let expected = "--\(boundary)\r\n"
            + "Content-Disposition: form-data; name=\"field\"\r\n"
            + "\r\n"
            + "value\r\n"
            + "--\(boundary)--\r\n"
        #expect(bodyString == expected)
    }
    
    @Test("Multiple text parts preserve order")
    func multipleTextParts() throws {
        let request = try Self.sampleRequest(parts: [
            .text(name: "a", value: "1"),
            .text(name: "b", value: "2"),
        ])
        let boundary = try Self.boundary(request: request)
        let bodyString = try Self.bodyString(request: request)
        let expected = "--\(boundary)\r\n"
            + "Content-Disposition: form-data; name=\"a\"\r\n"
            + "\r\n"
            + "1\r\n"
            + "--\(boundary)\r\n"
            + "Content-Disposition: form-data; name=\"b\"\r\n"
            + "\r\n"
            + "2\r\n"
            + "--\(boundary)--\r\n"
        #expect(bodyString == expected)
    }
    
    @Test("File part has filename, Content-Type, blank line, raw bytes")
    func filePart() throws {
        let fileBytes = Data([0x89, 0x50, 0x4E, 0x47])  // arbitrary binary
        let request = try Self.sampleRequest(parts: [
            .file(name: "photo", filename: "p.png", mimeType: .png, data: fileBytes),
        ])
        let boundary = try Self.boundary(request: request)
        let body = try #require(request.httpBody)
        
        let expectedHeader = "--\(boundary)\r\n"
            + "Content-Disposition: form-data; name=\"photo\"; filename=\"p.png\"\r\n"
            + "Content-Type: image/png\r\n"
            + "\r\n"
        let expectedFooter = "\r\n--\(boundary)--\r\n"
        var expected = Data(expectedHeader.utf8)
        expected.append(fileBytes)
        expected.append(Data(expectedFooter.utf8))
        #expect(body == expected)
    }
    
    @Test("Text part skips Content-Type line when mimeType is nil")
    func textPartHasNoContentType() throws {
        let request = try Self.sampleRequest(parts: [.text(name: "k", value: "v")])
        let bodyString = try Self.bodyString(request: request)
        #expect(!bodyString.contains("Content-Type:"))
    }
    
    @Test("File part with same name as another part is preserved (RFC 7578 §4.3)")
    func duplicatePartNames() throws {
        let request = try Self.sampleRequest(parts: [
            .file(name: "photo", filename: "a.jpg", mimeType: .jpeg, data: Data([0x01])),
            .file(name: "photo", filename: "b.jpg", mimeType: .jpeg, data: Data([0x02])),
        ])
        let bodyString = try Self.bodyString(request: request)
        // Both file parts are present, both with name="photo".
        let nameOccurrences = bodyString.components(separatedBy: "name=\"photo\"").count - 1
        #expect(nameOccurrences == 2)
        #expect(bodyString.contains("filename=\"a.jpg\""))
        #expect(bodyString.contains("filename=\"b.jpg\""))
    }
    
    @Test("Empty parts list still produces a closing boundary")
    func emptyParts() throws {
        let request = try Self.sampleRequest(parts: [])
        let boundary = try Self.boundary(request: request)
        let bodyString = try Self.bodyString(request: request)
        #expect(bodyString == "--\(boundary)--\r\n")
    }
    
    @Test("Mixed text and file parts emit text first, then file, in order")
    func mixedParts() throws {
        let fileBytes = Data([0xAB, 0xCD])
        let request = try Self.sampleRequest(parts: [
            .text(name: "alpha", value: "one"),
            .file(name: "blob", filename: "b.bin", mimeType: .octetStream, data: fileBytes),
        ])
        let boundary = try Self.boundary(request: request)
        let body = try #require(request.httpBody)
        
        let textHeader = "--\(boundary)\r\n"
            + "Content-Disposition: form-data; name=\"alpha\"\r\n"
            + "\r\n"
            + "one\r\n"
        let fileHeader = "--\(boundary)\r\n"
            + "Content-Disposition: form-data; name=\"blob\"; filename=\"b.bin\"\r\n"
            + "Content-Type: application/octet-stream\r\n"
            + "\r\n"
        let footer = "\r\n--\(boundary)--\r\n"
        var expected = Data(textHeader.utf8)
        expected.append(Data(fileHeader.utf8))
        expected.append(fileBytes)
        expected.append(Data(footer.utf8))
        #expect(body == expected)
    }
}
