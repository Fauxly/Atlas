//
//  ATSpawn.swift
//  Atlas
//
//  Created by Fix’s Trick’s on 07.07.2026.
//

import Foundation

public final class ATSpawn {

    private let backend: ATSpawnBackend

    public init(backend: ATSpawnBackend = ATPosixSpawnBackend()) {
        self.backend = backend
    }

    /// Выполнить команду асинхронно через экземпляр класса.
    /// elevated: true — запускает процесс от root через persona-override (см. ATSpawnBackend).
    public func run(binaryPath: String, arguments: [String], elevated: Bool = false) async throws -> ATSpawnResult {
        let correctedPath = ATPathManager.shared.makePath(binaryPath)
        return try await backend.execute(binaryPath: correctedPath, arguments: arguments, environment: nil, elevated: elevated)
    }

    /// Статический метод для вызовов напрямую вида ATSpawn.runCommand(...)
    public static func runCommand(_ binaryPath: String, arguments: [String] = [], elevated: Bool = false) async throws -> ATSpawnResult {
        let launcher = ATSpawn()
        return try await launcher.run(binaryPath: binaryPath, arguments: arguments, elevated: elevated)
    }
}
