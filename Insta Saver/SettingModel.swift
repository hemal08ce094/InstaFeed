//
//  SettingModel.swift
//  InstaSaver
//
//  Created by Vyacheslav Bakinskiy on 1/18/21.
//

import UIKit

enum SettingType {
    case rate
    case policy
}

struct SettingModel {
    var type: SettingType
    var name: String
    var icon: UIImage?
}
