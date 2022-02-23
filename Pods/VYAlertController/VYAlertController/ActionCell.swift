//
//  ActionCell.swift
//  VYAlertController
//
//  Created by Vladyslav Yakovlev on 10/1/18.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

final class ActionCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    static let reuseId = "ActionCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        titleLabel.frame = contentView.bounds
        contentView.addSubview(titleLabel)
    }
    
    func setupTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setupTitleFont(_ font: UIFont) {
        titleLabel.font = font
    }
    
    func setupTitleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
