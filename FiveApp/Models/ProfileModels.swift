//
//  ProfileModels.swift
//  FiveApp
//
//  Created by Barbara Kos on 08.06.2022..
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
