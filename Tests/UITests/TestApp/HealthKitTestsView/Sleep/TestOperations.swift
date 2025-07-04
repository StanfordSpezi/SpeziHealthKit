//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct TestError: Error {
    struct SourceLocation {
        let file: StaticString
        let function: StaticString
        let line: UInt
    }
    
    let message: String
    let sourceLocation: SourceLocation
    
    fileprivate init(message: String, sourceLocation: SourceLocation) {
        self.message = message
        self.sourceLocation = sourceLocation
    }
}


func unwrap<T>(
    _ value: T?,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) throws(TestError) -> T {
    if let value {
        return value
    } else {
        throw .init(
            message: "Unexpectedly found nil when unwrapping '\(T?.self)'",
            sourceLocation: .init(file: file, function: function, line: line)
        )
    }
}

func expectEqual<T: Equatable>(
    _ lhs: T,
    _ rhs: T,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) throws(TestError) {
    guard lhs != rhs else {
        return
    }
    throw .init(message: "\(lhs) != \(rhs)", sourceLocation: .init(file: file, function: function, line: line))
}

func expect(
    _ value: Bool,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) throws(TestError) {
    guard value else {
        return
    }
    throw .init(message: "!\(value)", sourceLocation: .init(file: file, function: function, line: line))
}
