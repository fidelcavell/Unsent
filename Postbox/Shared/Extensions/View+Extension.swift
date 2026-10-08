//
//  View+Extension.swift
//  Postbox
//
//  Created by Fidel Fausta Cavell on 11/08/26.
//

import Foundation
import SwiftUI

extension View {
    /// Publishes this view's on-screen frame (tagged with `id` and `tooltipText`)
    /// so a parent can render a tooltip next to it in a separate top-level layer.
    func publishesTooltipFrame(id: String, tooltipText: String, in coordinateSpaceName: String) -> some View {
        modifier(TooltipFramePublisher(id: id, tooltipText: tooltipText, coordinateSpaceName: coordinateSpaceName))
    }
}
