//
//  ATStatusParser.swift
//  Atlas
//
//  Created by Fix’s Trick’s on 08.07.2026.
//
import Foundation

public final class ATStatusParser {

    public static let shared = ATStatusParser()

    // Определяем путь к файлу в зависимости от префикса джейлбрейка
    private var statusFilePath: String {
        // Проверяем наличие rootless-префикса palera1n
        let rootlessPath = "/var/jb/var/lib/dpkg/status"
        if FileManager.default.fileExists(atPath: rootlessPath) {
            return rootlessPath
        }
        return "/var/lib/dpkg/status" // Стандартный rootful путь
    }

    public func readInstalledPackages() -> [ATInstalledPackage] {
        let path = statusFilePath

        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            print("Atlas: Не удалось прочитать статус-файл по пути \(path)")
            return getMockPackages() // Если запускаем на симуляторе Mac — отдаем заглушки
        }

        var installedPackages: [ATInstalledPackage] = []

        // В файле dpkg status каждый пакет разделен двойным переносом строки
        let rawPackages = content.components(separatedBy: "\n\n")

        for rawPkg in rawPackages {
            if rawPkg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { continue }

            let fields = parseFields(from: rawPkg)

            guard let id = fields["package"], !id.isEmpty else { continue }

            // Поле Status — это три слова: <want> <flag> <status>, например "install ok installed".
            // Раньше здесь была проверка через .contains("installed"), которая ложно засчитывала
            // "half-installed" (прерванная установка/удаление) как полностью установленный пакет.
            // Нам нужен ИМЕННО статус "installed" третьим словом — только он значит, что пакет
            // реально и полностью установлен и с ним можно работать (в том числе удалять).
            guard let status = fields["status"] else { continue }
            let statusWords = status.split(separator: " ")
            guard statusWords.count == 3, statusWords[2] == "installed" else { continue }

            let name = fields["name"] ?? id
            let version = fields["version"] ?? ""
            let description = formattedDescription(fields["description"] ?? "")
            let section = fields["section"] ?? ""

            let package = ATInstalledPackage(id: id, name: name, version: version, description: description, section: section)
            installedPackages.append(package)
        }

        // Сортируем по алфавиту
        return installedPackages.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    // MARK: - Private

    /// Разбирает один блок control-полей (одна запись пакета) в словарь [ключ в нижнем регистре: значение].
    /// Учитывает многострочные поля (например Description) через строки-продолжения с ведущим пробелом.
    private func parseFields(from rawRecord: String) -> [String: String] {
        var fields: [String: String] = [:]
        var lastKey: String?

        let lines = rawRecord.components(separatedBy: .newlines)

        for rawLine in lines {
            if let first = rawLine.first, (first == " " || first == "\t"), let key = lastKey {
                let continuation = String(rawLine.dropFirst())
                let piece = (continuation.trimmingCharacters(in: .whitespaces) == ".") ? "" : continuation
                let existing = fields[key] ?? ""
                fields[key] = existing.isEmpty ? piece : existing + "\n" + piece
                continue
            }

            guard let colonIndex = rawLine.firstIndex(of: ":") else { continue }

            let key = rawLine[rawLine.startIndex..<colonIndex]
                .trimmingCharacters(in: .whitespaces)
                .lowercased()
            let value = rawLine[rawLine.index(after: colonIndex)...]
                .trimmingCharacters(in: .whitespaces)

            fields[key] = value
            lastKey = key
        }

        return fields
    }

    private func formattedDescription(_ raw: String) -> String {
        guard !raw.isEmpty else { return "" }
        let components = raw.components(separatedBy: "\n")
        guard components.count > 1 else { return raw }
        let synopsis = components[0]
        let details = components.dropFirst().joined(separator: "\n")
        return details.isEmpty ? synopsis : "\(synopsis)\n\n\(details)"
    }

    // Заглушки для теста на симуляторе Xcode, чтобы экран не был пустым
    private func getMockPackages() -> [ATInstalledPackage] {
        return [
            ATInstalledPackage(id: "org.coolstar.tweakinject", name: "TweakInject", version: "1.3.0", description: "Тайм-инъекции для tvOS твиков", section: "Tweaks"),
            ATInstalledPackage(id: "com.nito.update", name: "nito update helper", version: "0.4-2", description: "Помощник обновления системных демонов", section: "Utilities"),
            ATInstalledPackage(id: "bash", name: "Bash Terminal Shell", version: "5.2.15", description: "Командная оболочка Bourne-Again SHell", section: "Terminal")
        ]
    }
}
