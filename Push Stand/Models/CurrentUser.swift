//
//  CurrentUser.swift
//  Push Stand
//
//  Created by Isaac Swindle on 12/28/23.
//

import Foundation

class CurrentUser {
    var email: String?
    var uid: String?

    static let shared = CurrentUser()

    private init() {
        email = ""
        uid = ""
    }
}
