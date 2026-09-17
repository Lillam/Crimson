//
//  Router.swift
//  Crimson
//
//  Created by Liam Taylor on 07/06/2026.
//

import Foundation

@Observable
class Router {
    var currentRoute: Route = .calendar
    
    init() {
        // Debug hook: launch with `-initialRoute insights` (or calendar,
        // day, settings) to open on that tab — handy for screenshots.
        if let name = UserDefaults.standard.string(forKey: "initialRoute"),
           let route = Route.allCases.first(where: { $0.base.id.removingDotSuffix == name }) {
            currentRoute = route
        }
    }
    
    func navigate(to route: Route) {
        currentRoute = route
    }
    
    func isCurrent(_ route: Route) -> Bool {
        return route.base == currentRoute.base
    }
}
