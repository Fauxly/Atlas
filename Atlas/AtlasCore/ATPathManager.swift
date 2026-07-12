//
//  ATPathManager.swift
//  Atlas
//
//  Created by Fix’s Trick’s on 07.07.2026.
//
import Foundation

public final class ATPathManager {
    
    public static let shared = ATPathManager()
    
    /// Текущий префикс для POSIX-окружения.
    /// Будет пустой строкой "" для твоей Rootful системы.
    public let jbPrefix: String
    
    /// Флаг, определяющий, работает ли приложение в Rootless режиме
    public let isRootless: Bool
    
    private init() {
        // Проверяем существование /var/jb
        if FileManager.default.fileExists(atPath: "/var/jb") {
            self.jbPrefix = "/var/jb"
            self.isRootless = true
            print("Atlas: Обнаружено окружение ROOTLESS. Префикс: /var/jb")
        } else {
            self.jbPrefix = ""
            self.isRootless = false
            print("Atlas: Обнаружено окружение ROOTFUL. Префикс отсутствует (корень)")
        }
    }
    
    /// Обертка для сборки любого POSIX-пути
    public func makePath(_ path: String) -> String {
        if isRootless && path.hasPrefix("/var/jb") {
            return path
        }
        return jbPrefix + path
    }
}
