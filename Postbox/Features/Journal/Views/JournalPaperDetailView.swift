//
//  JournalPaperDetailView.swift
//  Postbox
//
//  Created by Codex on 12/08/26.
//

import SwiftUI

struct JournalPaperDetailView: View {
    let onClose: () -> Void

    @State private var baseScale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0

    private let minimumScale: CGFloat = 1.0
    private let maximumScale: CGFloat = 2.4
    private let dismissScale: CGFloat = 0.82
    private let paperAspectRatio: CGFloat = 1.42

    private var currentScale: CGFloat {
        min(maximumScale, max(0.72, baseScale * gestureScale))
    }

    var body: some View {
        GeometryReader { proxy in
            let paperWidth = min(proxy.size.width * 0.62, 760)
            let paperHeight = paperWidth * paperAspectRatio
            let layoutPaperWidth = paperWidth * baseScale
            let layoutPaperHeight = paperHeight * baseScale

            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    detailToolbar
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    ScrollView([.vertical, .horizontal], showsIndicators: false) {
                        VStack {
                            paperCanvas(width: paperWidth, height: paperHeight)
                                .scaleEffect(currentScale, anchor: .top)
                                .frame(width: layoutPaperWidth, height: layoutPaperHeight, alignment: .top)
                        }
                        .frame(
                            minWidth: proxy.size.width,
                            minHeight: proxy.size.height - 116,
                            alignment: .top
                        )
                        .padding(.bottom, 120)
                    }
                    .simultaneousGesture(zoomGesture)
                }
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 1.02)))
    }

    private var detailToolbar: some View {
        HStack {
            ToolButton(
                id: "detailBack",
                action: onClose,
                assetName: "button_back",
                toolTipText: "",
                coordinateSpaceName: "none"
            )

            ToolButton(
                id: "detailSpacer",
                action: {},
                assetName: "button_back",
                toolTipText: "",
                coordinateSpaceName: "none"
            )
            .disabled(true)
            .opacity(0)
            
            Spacer()

            HStack(spacing: 12) {
                ToolButton(id: "detailMagicPen", action: {}, assetName: "button_magicpen", toolTipText: "", coordinateSpaceName: "none")
                ToolButton(id: "detailText", action: {}, assetName: "button_text", toolTipText: "", coordinateSpaceName: "none")
                ToolButton(id: "detailScribble", action: {}, assetName: "button_pencil", toolTipText: "", coordinateSpaceName: "none")
                ToolButton(id: "detailPhoto", action: {}, assetName: "button_image", toolTipText: "", coordinateSpaceName: "none")
                ToolButton(id: "detailMic", action: {}, assetName: "button_mic", toolTipText: "", coordinateSpaceName: "none")
                ToolButton(id: "detaillayer", action: {}, assetName: "button_layer", toolTipText: "", coordinateSpaceName: "none")

            }

            Spacer()

            HStack(spacing: 12) {
                ToolButton(id: "detailTrash", action: {}, assetName: "button_trash", toolTipText: "", coordinateSpaceName: "none")
                ToolButton(id: "detailDone", action: onClose, assetName: "button_checkmark", toolTipText: "", coordinateSpaceName: "none")
            }
        }
    }

    private func paperCanvas(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .top) {
            Image("halaman_kertas_kosong")
                .resizable()
                .scaledToFit()
                .frame(width: width, height: height)

            Text("07 August 2026")
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(.secondary)
                .padding(.top, height * 0.065)
        }
        .contentShape(Rectangle())
    }

    private var zoomGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0.01)
            .updating($gestureScale) { value, state, _ in
                state = value.magnification
            }
            .onEnded { value in
                let proposedScale = baseScale * value.magnification

                if proposedScale < dismissScale {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        onClose()
                    }
                    return
                }

                baseScale = min(maximumScale, max(minimumScale, proposedScale))
            }
    }
}

#Preview(traits: .landscapeRight) {
    JournalPaperDetailView(onClose: {})
}
