//
//  Router.swift
//  BusQRGenerator
//
//  Created by Alumno-015 on 28/05/24.
//

import SwiftUI
import Foundation

class Router: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    static let shared: Router = Router()
}
