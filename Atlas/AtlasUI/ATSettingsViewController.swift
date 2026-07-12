//
//  ATSettingsViewController.swift
//  Atlas
//

import UIKit

final class ATSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private enum Section: Int, CaseIterable {
        case language
        case general
        case storage
        case repositories
        case about
    }

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let languages: [ATLanguage] = [.russian, .english]

    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TAB_SETTINGS".localized
        view.backgroundColor = ATTheme.ink
        setupTableView()
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LanguageCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StorageCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResetRepositoriesCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AutoUpdateCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AboutCell")
        view.addSubview(tableView)
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .language: return "SETTINGS_LANGUAGE_SECTION".localized
        case .general: return "SETTINGS_GENERAL_SECTION".localized
        case .storage: return "SETTINGS_STORAGE_SECTION".localized
        case .repositories: return "SETTINGS_REPOSITORIES_SECTION".localized
        case .about: return "SETTINGS_ABOUT_SECTION".localized
        case .none: return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .language: return languages.count
        case .general: return 1
        case .storage: return 1
        case .repositories: return 1
        case .about: return 2
        case .none: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .language:
            return languageCell(for: indexPath)
        case .general:
            return autoUpdateCell(for: indexPath)
        case .storage:
            return storageCell(for: indexPath)
        case .repositories:
            return resetRepositoriesCell(for: indexPath)
        case .about:
            return aboutCell(for: indexPath)
        case .none:
            return UITableViewCell()
        }
    }

    private func languageCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath)
        cell.backgroundColor = .clear

        let language = languages[indexPath.row]
        let isSelected = language == ATLocalizationManager.currentLanguage

        let focusBackground = UIView()
        focusBackground.backgroundColor = ATTheme.surfaceFocused
        focusBackground.layer.cornerRadius = 8
        cell.selectedBackgroundView = focusBackground

        if #available(tvOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = language.displayName
            content.textProperties.color = ATTheme.textPrimary
            content.textProperties.font = UIFont.systemFont(ofSize: 28, weight: .medium)
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = language.displayName
            cell.textLabel?.textColor = ATTheme.textPrimary
        }

        cell.accessoryType = isSelected ? .checkmark : .none
        cell.tintColor = ATTheme.brass

        return cell
    }

    private func storageCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StorageCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "StorageCell")
        cell.backgroundColor = .clear

        let focusBackground = UIView()
        focusBackground.backgroundColor = ATTheme.surfaceFocused
        focusBackground.layer.cornerRadius = 8
        cell.selectedBackgroundView = focusBackground

        let sizeText = byteFormatter.string(fromByteCount: ATFileManager.shared.cacheSize())

        if #available(tvOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = "SETTINGS_CLEAR_CACHE".localized
            content.secondaryText = sizeText
            content.textProperties.color = ATTheme.textPrimary
            content.textProperties.font = UIFont.systemFont(ofSize: 28, weight: .medium)
            content.secondaryTextProperties.color = ATTheme.textSecondary
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = "SETTINGS_CLEAR_CACHE".localized
            cell.textLabel?.textColor = ATTheme.textPrimary
            cell.detailTextLabel?.text = sizeText
            cell.detailTextLabel?.textColor = ATTheme.textSecondary
        }

        return cell
    }

    private func resetRepositoriesCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResetRepositoriesCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ResetRepositoriesCell")
        cell.backgroundColor = .clear

        let focusBackground = UIView()
        focusBackground.backgroundColor = ATTheme.surfaceFocused
        focusBackground.layer.cornerRadius = 8
        cell.selectedBackgroundView = focusBackground

        let count = ATRepositoryManager.shared.repositories.count
        let countText = String(format: "SETTINGS_REPOSITORIES_COUNT".localized, count)

        if #available(tvOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = "SETTINGS_RESET_REPOSITORIES".localized
            content.secondaryText = countText
            content.textProperties.color = ATTheme.textPrimary
            content.textProperties.font = UIFont.systemFont(ofSize: 28, weight: .medium)
            content.secondaryTextProperties.color = ATTheme.textSecondary
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = "SETTINGS_RESET_REPOSITORIES".localized
            cell.textLabel?.textColor = ATTheme.textPrimary
            cell.detailTextLabel?.text = countText
            cell.detailTextLabel?.textColor = ATTheme.textSecondary
        }

        return cell
    }

    private func autoUpdateCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoUpdateCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "AutoUpdateCell")
        cell.backgroundColor = .clear

        let focusBackground = UIView()
        focusBackground.backgroundColor = ATTheme.surfaceFocused
        focusBackground.layer.cornerRadius = 8
        cell.selectedBackgroundView = focusBackground

        let isOn = ATAppSettings.autoUpdateOnLaunch
        let stateText = isOn ? "SETTINGS_STATE_ON".localized : "SETTINGS_STATE_OFF".localized

        if #available(tvOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = "SETTINGS_AUTO_UPDATE".localized
            content.secondaryText = stateText
            content.textProperties.color = ATTheme.textPrimary
            content.textProperties.font = UIFont.systemFont(ofSize: 28, weight: .medium)
            content.secondaryTextProperties.color = isOn ? ATTheme.brass : ATTheme.textSecondary
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = "SETTINGS_AUTO_UPDATE".localized
            cell.textLabel?.textColor = ATTheme.textPrimary
            cell.detailTextLabel?.text = stateText
            cell.detailTextLabel?.textColor = isOn ? ATTheme.brass : ATTheme.textSecondary
        }

        return cell
    }

    private func aboutCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell") ?? UITableViewCell(style: .default, reuseIdentifier: "AboutCell")
        cell.backgroundColor = .clear

        let focusBackground = UIView()
        focusBackground.backgroundColor = ATTheme.surfaceFocused
        focusBackground.layer.cornerRadius = 8
        cell.selectedBackgroundView = focusBackground

        let title = indexPath.row == 0 ? "SETTINGS_ABOUT".localized : "SETTINGS_DIAGNOSTIC_LOG".localized

        if #available(tvOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = title
            content.textProperties.color = ATTheme.textPrimary
            content.textProperties.font = UIFont.systemFont(ofSize: 28, weight: .medium)
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = title
            cell.textLabel?.textColor = ATTheme.textPrimary
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch Section(rawValue: indexPath.section) {
        case .language:
            handleLanguageSelection(at: indexPath)
        case .general:
            handleAutoUpdateToggle()
        case .storage:
            handleClearCacheTapped()
        case .repositories:
            handleResetRepositoriesTapped()
        case .about:
            handleAboutRowSelected(at: indexPath)
        case .none:
            break
        }
    }
    
    private func handleAutoUpdateToggle() {
        ATAppSettings.autoUpdateOnLaunch.toggle()
        tableView.reloadSections(IndexSet(integer: Section.general.rawValue), with: .automatic)
    }
    
    private func handleAboutRowSelected(at indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationController?.pushViewController(ATAboutViewController(), animated: true)
        } else {
            navigationController?.pushViewController(ATLogViewController(), animated: true)
        }
    }
    
    private func handleResetRepositoriesTapped() {
        let alert = UIAlertController(
            title: "SETTINGS_RESET_REPOSITORIES_CONFIRM_TITLE".localized,
            message: "SETTINGS_RESET_REPOSITORIES_CONFIRM_MESSAGE".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "SETTINGS_RESET_REPOSITORIES_CONFIRM_BUTTON".localized, style: .destructive) { [weak self] _ in
            ATRepositoryManager.shared.resetToDefault()
            self?.tableView.reloadSections(IndexSet(integer: Section.repositories.rawValue), with: .automatic)
        })
        alert.addAction(UIAlertAction(title: "SETTINGS_RESTART_CANCEL".localized, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    private func handleLanguageSelection(at indexPath: IndexPath) {
        let language = languages[indexPath.row]
        guard language != ATLocalizationManager.currentLanguage else { return }

        let alert = UIAlertController(
            title: "SETTINGS_RESTART_TITLE".localized,
            message: "SETTINGS_RESTART_MESSAGE".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "SETTINGS_RESTART_CONFIRM".localized, style: .destructive) { _ in
            ATLocalizationManager.currentLanguage = language
            // Жёсткий выход — пользователь открывает приложение заново вручную с главного экрана.
            // На джейлбрейкнутом устройстве это приемлемо; через App Store такое не прошло бы ревью,
            // но Atlas туда и не попадёт.
            exit(0)
        })
        alert.addAction(UIAlertAction(title: "SETTINGS_RESTART_CANCEL".localized, style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    private func handleClearCacheTapped() {
        let currentSize = ATFileManager.shared.cacheSize()
        guard currentSize > 0 else { return }

        let alert = UIAlertController(
            title: "SETTINGS_CLEAR_CACHE_CONFIRM_TITLE".localized,
            message: byteFormatter.string(fromByteCount: currentSize),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "SETTINGS_CLEAR_CACHE_CONFIRM_BUTTON".localized, style: .destructive) { [weak self] _ in
            ATFileManager.shared.clearCache()
            self?.tableView.reloadSections(IndexSet(integer: Section.storage.rawValue), with: .automatic)
        })
        alert.addAction(UIAlertAction(title: "SETTINGS_RESTART_CANCEL".localized, style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    // tvOS сам поднимает сфокусированную строку светлой карточкой — без свапа цвета текста
    // на тёмный светлый текст на светлом фоне становится невидимым при наведении фокуса.
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextIndexPath = context.nextFocusedIndexPath,
           let cell = tableView.cellForRow(at: nextIndexPath) {
            coordinator.addCoordinatedAnimations({
                self.applyTextColor(to: cell, primary: ATTheme.ink, secondary: ATTheme.ink.withAlphaComponent(0.7))
            }, completion: nil)
        }
        
        if let previousIndexPath = context.previouslyFocusedIndexPath {
            // Перерисовываем строку заново через cellForRowAt — так восстанавливается ТОЧНАЯ
            // исходная раскраска (например, латунный/серый цвет статуса "Включено"/"Выключено"),
            // а не единый жёстко заданный "цвет вне фокуса" на все строки без разбора.
            tableView.reloadRows(at: [previousIndexPath], with: .none)
        }
    }
    
    private func applyTextColor(to cell: UITableViewCell, primary: UIColor, secondary: UIColor) {
        if #available(tvOS 14.0, *), var content = cell.contentConfiguration as? UIListContentConfiguration {
            content.textProperties.color = primary
            content.secondaryTextProperties.color = secondary
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.textColor = primary
            cell.detailTextLabel?.textColor = secondary
        }
    }
}
