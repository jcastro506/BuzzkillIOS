//
//  BudgetDetailsWidgetBundle.swift
//  BudgetDetailsWidget
//
//  Created by Josh Castro on 2/16/25.
//

import WidgetKit
import SwiftUI

@main
struct BudgetDetailsWidgetBundle: WidgetBundle {
    var body: some Widget {
        BudgetDetailsWidget()
        BudgetDetailsWidgetLiveActivity()
    }
}
