//
//  ATInfoRowView.swift
//  Atlas
//
//  Created by Fix’s Trick’s on 06.07.2026.
//

//
//  ATInfoRowView.swift
//  Atlas
//

import UIKit

final class ATInfoRowView: UIView {

    // MARK: - UI

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    // MARK: - Init

    init(title: String, value: String) {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        valueLabel.text = value

        titleLabel.textColor = .lightGray
        valueLabel.textColor = .white

        titleLabel.font = .systemFont(ofSize: 28, weight: .regular)
        valueLabel.font = .systemFont(ofSize: 28, weight: .semibold)

        addSubview(titleLabel)
        addSubview(valueLabel)

        NSLayoutConstraint.activate([

            heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),

            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)

        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
