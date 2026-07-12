//
//  ATInstalledViewController.swift
//  Atlas
//
//  Created by Fix’s Trick’s on 08.07.2026.
//

import UIKit

public final class ATInstalledViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var installedPackages: [ATInstalledPackage] = []
    
    /// Полный смёрженный каталог из всех репозиториев — приходит извне из ATCustomTabBarController,
    /// сама эта вкладка в сеть не ходит. Нужен только для сравнения версий "установлено vs доступно".
    var allPackages: [ATPackage] = [] {
        didSet { tableView.reloadData() }
    }
    
    /// Последняя известная версия пакета в каталоге репозиториев, если она новее установленной.
    /// nil — либо пакета нет ни в одном репозитории, либо установленная версия уже актуальна.
    private func availableUpdate(for installed: ATInstalledPackage) -> ATPackage? {
        allPackages
            .filter { $0.packageID == installed.id }
            .max { ATDependencyChecker.compareVersions($0.version, "<<", $1.version) }
            .flatMap { latest in
                ATDependencyChecker.compareVersions(latest.version, ">>", installed.version) ? latest : nil
            }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ATTheme.ink
        
        setupTableView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadInstalledPackages()
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        
        // Настройка фокуса для tvOS таблиц
        tableView.remembersLastFocusedIndexPath = true
        
        view.addSubview(tableView)
    }
    
    private func loadInstalledPackages() {
        installedPackages = ATStatusParser.shared.readInstalledPackages()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return installedPackages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstalledCell") ??
        UITableViewCell(style: .subtitle, reuseIdentifier: "InstalledCell")
        
        let package = installedPackages[indexPath.row]
        
        cell.backgroundColor = .clear
        
        // На tvOS фокусируемая ячейка сама получает фоновую подложку через selectedBackgroundView —
        // делаем её в тон теме, а не системный дефолт
        let focusBackground = UIView()
        focusBackground.backgroundColor = ATTheme.surfaceFocused
        focusBackground.layer.cornerRadius = 8
        cell.selectedBackgroundView = focusBackground
        
        cell.textLabel?.text = package.name
        cell.textLabel?.textColor = ATTheme.textPrimary
        cell.textLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        
        if let update = availableUpdate(for: package) {
            cell.detailTextLabel?.text = String(format: "INSTALLED_UPDATE_AVAILABLE".localized, package.version, update.version)
            cell.detailTextLabel?.textColor = ATTheme.brass
        } else {
            cell.detailTextLabel?.text = "\(package.id) • v\(package.version)"
            cell.detailTextLabel?.textColor = ATTheme.textSecondary
        }
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    // tvOS сам поднимает сфокусированную строку в виде светлой карточки и наш
    // selectedBackgroundView эту подложку не перекрывает — переключаем цвет текста:
    // тёмный на фокусе (светлая карточка), светлый в состоянии покоя.
    public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextIndexPath = context.nextFocusedIndexPath,
           let cell = tableView.cellForRow(at: nextIndexPath) {
            coordinator.addCoordinatedAnimations({
                cell.textLabel?.textColor = ATTheme.ink
                cell.detailTextLabel?.textColor = ATTheme.ink.withAlphaComponent(0.7)
            }, completion: nil)
        }
        
        if let previousIndexPath = context.previouslyFocusedIndexPath {
            // Перерисовываем строку заново через cellForRowAt — так восстанавливается ТОЧНАЯ
            // исходная раскраска (латунный бейдж обновления, если он есть), а не жёстко
            // заданный "цвет вне фокуса" на все строки без разбора.
            tableView.reloadRows(at: [previousIndexPath], with: .none)
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let package = installedPackages[indexPath.row]
        let update = availableUpdate(for: package)
        
        let alert = UIAlertController(title: package.name, message: "INSTALLED_ACTION_PROMPT".localized, preferredStyle: .alert)
        
        if let update = update {
            let updateAction = UIAlertAction(title: "INSTALLED_UPDATE_ACTION".localized, style: .default) { [weak self] _ in
                // Переиспользуем уже готовый экран установки — dpkg -i сам корректно
                // обрабатывает апгрейд поверх уже стоящей версии, отдельная логика не нужна.
                let detailsVC = ATPackageDetailsViewController(package: update)
                self?.navigationController?.pushViewController(detailsVC, animated: true)
            }
            alert.addAction(updateAction)
        }
        
        let deleteAction = UIAlertAction(title: "INSTALLED_UNINSTALL".localized, style: .destructive) { _ in
            self.uninstallPackage(id: package.id)
        }
        
        let cancelAction = UIAlertAction(title: "COMMON_CANCEL".localized, style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Uninstall
    
    /// Package ID из control-файлов dpkg — это reverse-DNS идентификатор:
    /// строчные латинские буквы, цифры, точки, дефисы и плюсы (стандарт Debian policy на имя пакета).
    private func isValidPackageID(_ id: String) -> Bool {
        guard !id.isEmpty else { return false }
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789.+-")
        return id.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
    
    private func uninstallPackage(id: String) {
        guard isValidPackageID(id) else {
            let errorAlert = UIAlertController(
                title: "COMMON_ERROR".localized,
                message: "INSTALLED_INVALID_ID".localized,
                preferredStyle: .alert
            )
            errorAlert.addAction(UIAlertAction(title: "COMMON_OK".localized, style: .default, handler: nil))
            present(errorAlert, animated: true, completion: nil)
            return
        }
        
        print("Atlas: Запуск удаления пакета через persona-elevated posix_spawn: \(id)")
        
        let loadingAlert = UIAlertController(
            title: "INSTALLED_UNINSTALLING_TITLE".localized,
            message: String(format: "INSTALLED_UNINSTALLING_MESSAGE".localized, id),
            preferredStyle: .alert
        )
        present(loadingAlert, animated: true, completion: nil)
        
        Task {
            do {
                let dpkgPath = ATPathManager.shared.makePath("/usr/bin/dpkg")
                
                let result = try await ATSpawn.runCommand(dpkgPath, arguments: ["-r", id], elevated: true)
                
                let isSuccess = result.exitCode == 0
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        if isSuccess {
                            let successAlert = UIAlertController(
                                title: "COMMON_SUCCESS".localized,
                                message: String(format: "INSTALLED_UNINSTALL_SUCCESS".localized, id),
                                preferredStyle: .alert
                            )
                            successAlert.addAction(UIAlertAction(title: "COMMON_OK".localized, style: .default) { _ in
                                self.loadInstalledPackages()
                            })
                            self.present(successAlert, animated: true, completion: nil)
                        } else {
                            let errorAlert = UIAlertController(
                                title: "COMMON_ERROR".localized,
                                message: String(format: "INSTALLED_UNINSTALL_ERROR".localized, result.exitCode, result.stderr),
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "COMMON_OK".localized, style: .default, handler: nil))
                            self.present(errorAlert, animated: true, completion: nil)
                        }
                    }
                }
                
            } catch {
                print("Atlas: Критическая ошибка ATSpawn: \(error.localizedDescription)")
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let errorAlert = UIAlertController(
                            title: "INSTALLED_PROCESS_ERROR_TITLE".localized,
                            message: error.localizedDescription,
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "COMMON_OK".localized, style: .default, handler: nil))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
