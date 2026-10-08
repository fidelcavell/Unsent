//
//  ToolButton.swift
//  Postbox
//
//  Created by Fidel Fausta Cavell on 10/08/26.
//

import SwiftUI

/// One published frame + tooltip pair. A view that renders `ToolButton` collects
/// these (see `ToolButtonFramePreferenceKey`) to draw tooltips in its own
/// top-level layer, entirely outside `ToolButton`'s own layout.
struct ToolButtonFramePreference: Equatable {
    let id: String
    let frame: CGRect
    let tooltipText: String
}

struct ToolButtonFramePreferenceKey: PreferenceKey {
    static var defaultValue: [ToolButtonFramePreference] = []
    static func reduce(value: inout [ToolButtonFramePreference], nextValue: () -> [ToolButtonFramePreference]) {
        value.append(contentsOf: nextValue())
    }
}

/// Publishes the frame (in a given named coordinate space) of whatever it's
/// attached to, tagged with an id + tooltip string, without adding anything
/// to the view's own visual layout — it only draws an invisible background.
struct TooltipFramePublisher: ViewModifier {
    let id: String
    let tooltipText: String
    let coordinateSpaceName: String
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ToolButtonFramePreferenceKey.self,
                    value: [
                        ToolButtonFramePreference(
                            id: id,
                            frame: proxy.frame(in: .named(coordinateSpaceName)),
                            tooltipText: tooltipText
                        )
                    ]
                )
            }
        )
    }
}

struct ToolButton: View {
    /// Unique id for this button, used to match it up with its published frame.
    var id: String
    var action: () -> Void
    var assetName: String
    var toolTipText: String
    var iconSize: CGFloat = 60
    
    /// While true, taps are ignored — set this to `showOnboarding` from the
    /// parent so the real action can't fire while the onboarding overlay is up.
    var isDisabled: Bool = false
    
    /// Name of the coordinate space the parent set up (e.g. via
    /// `.coordinateSpace(name: "onboardingSpace")`) so the published frame
    /// lines up correctly with wherever the parent draws the tooltip.
    var coordinateSpaceName: String = "onboardingSpace"
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .clipShape(Circle())
        }
        .disabled(isDisabled)
        .publishesTooltipFrame(id: id, tooltipText: toolTipText, in: coordinateSpaceName)
    }
}

#Preview {
    ToolButton(
        id: "text",
        action: {},
        assetName: "button_text",
        toolTipText: "Tap here to add text"
    )
}
