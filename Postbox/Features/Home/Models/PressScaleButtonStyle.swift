//
//  PressScaleButtonStyle.swift
//  Postbox
//
//  Created by Theona Arlinton on 11/08/26.
//

import SwiftUI


struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(
                configuration.isPressed ? 0.985 : 1,
                anchor: .bottom
            )
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
