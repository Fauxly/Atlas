//
//  ATSectionHeaderView.swift
//  Atlas
//
//  Created by Fix’s Trick’s on 09.07.2026.
//

//
//  ATSectionHeaderView.swift
//  Atlas
//

import UIKit

final class ATSectionHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "ATSectionHeaderView"

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не поддерживается")
    }

    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = ATTheme.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
