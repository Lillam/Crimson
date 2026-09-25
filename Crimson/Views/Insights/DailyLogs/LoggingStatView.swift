//
//  LoggingStatView.swift
//  Crimson
//
//  Created by Liam Taylor on 25/09/2026.
//

import SwiftUI

/// How many days have anything noted on them.
///
/// Not a chart — it's one number. It's also the honest caveat for the cards
/// around it: forty days out of a year means those averages are thin, and the
/// user should be able to see that without being told.
struct LoggingStatView: View {
    @Environment(DayLogStore.self) var days

    let scope: InsightsScope

    private var logged: Int {
        days.logs(since: scope.start()).count
    }

    /// Roughly how many days the window covers, for the share.
    private var window: Int {
        scope.months * 30
    }

    private var share: Int {
        window > 0 ? Int((Double(logged) / Double(window) * 100).rounded()) : 0
    }

    var body: some View {
        StatTileView(
            label: "Days Logged",
            value: "\(logged)",
            unit: logged == 0 ? scope.phrase : "\(share)% of the \(scope.phrase)"
        )
    }
}

#Preview(traits: .sampleData) {
    LoggingStatView(scope: .twelveMonths)
        .padding(20)
}
