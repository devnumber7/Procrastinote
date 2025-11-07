//
//  ProcastinoteWidgetBundle.swift
//  ProcastinoteWidget
//
//  Created by Aryan Palit on 11/7/25.
//

import WidgetKit
import SwiftUI

@main
struct ProcastinoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        ProcastinoteWidget()
        ProcastinoteWidgetControl()
        ProcastinoteWidgetLiveActivity()
    }
}
