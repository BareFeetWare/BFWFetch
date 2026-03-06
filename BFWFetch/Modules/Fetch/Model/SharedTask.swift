//
//  SharedTask.swift
//  BFWFetch
//

/// An actor that coalesces concurrent async calls into a single in-flight task.
/// Multiple callers of `run(_:)` while a task is in progress will await the same result.
public actor SharedTask<T: Sendable> {
    
    private var task: Task<T, any Error>?
    
    public init() {}
    
    /// Runs the operation, or returns the result of an already in-flight operation.
    public func run(_ operation: @escaping @Sendable () async throws -> T) async throws -> T {
        if let task {
            return try await task.value
        }
        let task = Task {
            defer { self.task = nil }
            return try await operation()
        }
        self.task = task
        return try await task.value
    }
    
}
