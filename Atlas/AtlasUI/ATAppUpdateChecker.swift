//
//  ATAppUpdateChecker.swift
//  Atlas
//

import Foundation

struct ATAppUpdateInfo {
    let version: String
    let downloadURL: URL
}

enum ATAppUpdateChecker {

    // Поменяй, если репозиторий когда-нибудь переедет на другой аккаунт/имя
    private static let repoOwner = "fauxly"
    private static let repoName = "Atlas"

    private static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    /// Возвращает информацию об обновлении, если на GitHub есть версия новее текущей.
    /// nil — либо обновлений нет, либо релиз не содержит .deb-ассета.
    static func checkForUpdate() async throws -> ATAppUpdateInfo? {
        let apiURL = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest")!

        var request = URLRequest(url: apiURL)
        // GitHub API требует явный Accept-заголовок и просит указывать User-Agent —
        // без него отдаёт 403 на некоторые запросы.
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Atlas-tvOS", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "ATAppUpdateChecker", code: -1, userInfo: [NSLocalizedDescriptionKey: "ERROR_NO_SERVER_RESPONSE".localized])
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let tagName = json["tag_name"] as? String,
            let assets = json["assets"] as? [[String: Any]]
        else {
            throw NSError(domain: "ATAppUpdateChecker", code: -2, userInfo: [NSLocalizedDescriptionKey: "ERROR_UTF8_DECODE".localized])
        }

        // Тег обычно вида "v1.0.7" — отбрасываем ведущую "v" для сравнения через ATDependencyChecker
        let remoteVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

        guard ATDependencyChecker.compareVersions(remoteVersion, ">>", currentVersion) else {
            return nil
        }

        guard
            let debAsset = assets.first(where: { ($0["name"] as? String)?.hasSuffix(".deb") == true }),
            let downloadURLString = debAsset["browser_download_url"] as? String,
            let downloadURL = URL(string: downloadURLString)
        else {
            return nil
        }

        return ATAppUpdateInfo(version: remoteVersion, downloadURL: downloadURL)
    }
}
