//
//  Services.swift
//  FunchApp
//
//  Created by Geon Woo lee on 2/17/24.
//

import Foundation

final class Services: ServiceType {
    var userService: UserServiceType
    
    init() {
        self.userService = UserService.shared
    }
}
