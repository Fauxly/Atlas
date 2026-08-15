//
//  ATUpdatesViewController.swift
//  Atlas
//

import UIKit

/// Отдельная вкладка "Обновления" — показывает только те установленные пакеты,
/// для которых в подключённых репозиториях есть более новая версия. Тап по строке
/// открывает карточку пакета с уже готовой кнопкой "Обновить (vX → vY)".
public final class ATUpdatesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()

    private struct UpdateItem {
        let installed: ATInstalledPackage
        let available: ATPackage
    }

    private var updates: [UpdateItem] = []

    /// Полный каталог из всех репозиториев — приходит извне из ATCustomTabBarController.
    var allPackages: [ATPackage] = [] {
        didSet { rebuildUpdatesList() }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ATTheme.ink
        setupTableView()
        setupEmptyLabel()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Каждый раз при заходе на вкладку перечитываем dpkg status —
        // пользователь мог установить/обновить что-то с другого экрана.
        rebuildUpdatesList()
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UpdateCell")
        view.addSubview(tableView)
    }

    private func setupEmptyLabel() {
        emptyLabel.text = "UPDATES_EMPTY".localized
        emptyLabel.textColor = ATTheme.textSecondary
        emptyLabel.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 60),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -60)
        ])
    }

    private func rebuildUpdatesList() {
        let installed = ATStatusParser.shared.readInstalledPackages()

        updates = installed.compactMap { pkg in
            // Находим максимальную доступную версию этого пакета в каталоге
            guard let latest = allPackages
                .filter({ $0.packageID == pkg.id })
                .max(where: { ATDependencyChecker.compareVersions($0.version, "<<", $1.version) })
            else { return nil }

            // Только если реально новее установленной
            guard ATDependencyChecker.compareVersions(latest.version, ">>", pkg.version) else { return nil }

            return UpdateItem(installed: pkg, available: latest)
        }

        tableView.reloadData()
        emptyLabel.isHidden = !updates.isEmpty
        tableView.isHidden = updates.isEmpty
    }

    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updates.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "UpdateCell")
        cell.backgroundColor = .clear

        let focusBackground = UIView()
        focusBackground.backgroundColor = ATTheme.surfaceFocused
        focusBackground.layer.cornerRadius = 8
        cell.selectedBackgroundView = focusBackground

        let item = updates[indexPath.row]

        cell.textLabel?.text = item.installed.name
        cell.textLabel?.textColor = ATTheme.textPrimary
        cell.textLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)

        cell.detailTextLabel?.text = String(format: "UPDATES_VERSION_CHANGE".localized, item.installed.version, item.available.version)
        cell.detailTextLabel?.textColor = ATTheme.brass
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)

        return cell
    }

    // MARK: - UITableViewDelegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = updates[indexPath.row]
        let detailsVC = ATPackageDetailsViewController(package: item.available)
        navigationController?.pushViewController(detailsVC, animated: true)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }

    // Свап цвета текста при фокусе — та же логика, что в Настройках/Установленном
    public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let nextIndexPath = context.nextFocusedIndexPath,
           let cell = tableView.cellForRow(at: nextIndexPath) {
            coordinator.addCoordinatedAnimations({
                cell.textLabel?.textColor = ATTheme.ink
                cell.detailTextLabel?.textColor = ATTheme.ink.withAlphaComponent(0.7)
            }, completion: nil)
        }

        if let previousIndexPath = context.previouslyFocusedIndexPath {
            tableView.reloadRows(at: [previousIndexPath], with: .none)
        }
    }
}

// MARK: - Array max helper

private extension Array {
    func max(where comparator: (Element, Element) -> Bool) -> Element? {
        guard !isEmpty else { return nil }
        return self.reduce(self[0]) { comparator($0, $1) ? $1 : $0 }
    }
}
