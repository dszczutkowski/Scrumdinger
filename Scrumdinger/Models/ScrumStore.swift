//
//  ScrumStore.swift
//  Scrumdinger
//
//  Created by Dave Szczutkowski on 27/06/2022.
//

import Foundation
import SwiftUI

class ScrumStore: ObservableObject {
    @Published var scrums: [DailyScrum] = []
    
    private static func fileUrl() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
            .appendingPathComponent("scrums.data")
    }
    
    static func load() async throws -> [DailyScrum] {
        /// Calling withCheckedThrowingContinuation suspends the load function, then passes a continuation into a closure that you provide. A continuation is a value that represents the code after an awaited function.
        try await withCheckedThrowingContinuation { continuation in
            load { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let scrums):
                    continuation.resume(returning: scrums)
                }
            }
        }
    }
    
    ///Result is a single type that represents the outcome of an operation, whether it’s a success or failure. The load function accepts a completion closure that it calls asynchronously with either an array of scrums or an error.
    static func load(completion: @escaping (Result<[DailyScrum], Error>)->Void) {
        // Dispatch queues are first in, first out (FIFO) queues to which your application can submit tasks. Background tasks have the lowest priority of all tasks.
        DispatchQueue.global(qos: .background).async {
            do {
                let fileUrl = try fileUrl()
                // Because scrums.data doesn’t exist when a user launches the app for the first time, you call the completion handler with an empty array if there’s an error opening the file handle.
                guard let file = try? FileHandle(forReadingFrom: fileUrl) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let dailyScrums = try JSONDecoder().decode(([DailyScrum]).self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(dailyScrums))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// The save function returns a value that callers of the function may not use. The @discardableResult attribute disables warnings about the unused return value.
    @discardableResult
    static func save(scrums: [DailyScrum]) async throws -> Int {
        try await withCheckedContinuation { continuation in
            save(scrums: scrums) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error as! Never)
                case .success(let scrumsSaved):
                    continuation.resume(returning: scrumsSaved)
                }
            }
        }
    }
    
    static func save(scrums: [DailyScrum], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(scrums)
                let outfile = try fileUrl()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(scrums.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
