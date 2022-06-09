//
//  AppUserModel.swift
//  FiveApp
//
//  Created by Barbara Kos on 08.06.2022..
//

import Foundation

struct AppUser {
    let username: String
    let email: String
    let admin: Bool
    
    var profilePicFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    var safeEmail: String {
        let safeEmail = email.replacingOccurrences(of: ".", with: "-")
        return safeEmail
    }
}

