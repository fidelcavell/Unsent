//
//  JournalEditorView.swift
//  Postbox
//
//  Created by habil on 09/08/26.
//

import SwiftUI
import SwiftData

struct JournalEditorView: View {
    @Environment(JournalViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("hasToolOnboarding") private var hasToolOnboarding: Bool = false
    @AppStorage("hasMagicPenOnboarding") private var hasMagicPenOnboarding: Bool = false
    @AppStorage("hasEmotionStampOnboarding") private var hasEmotionStampOnboarding: Bool = false
    @AppStorage("hasNavOnboarding") private var hasNavOnboarding: Bool = false
    @AppStorage("hasLayerOnboarding") private var hasLayerOnboarding: Bool = false
    
    @State private var showToolOnboarding: Bool = false
    @State private var showMagicPenOnboarding: Bool = false
    @State private var showEmotionStampOnboarding: Bool = false
    @State private var showNavOnboarding: Bool = false
    @State private var showLayerOnboarding: Bool = false
    @State private var showPaperDetail: Bool = false
    
    @State private var showSealAnimation = false
    @State private var selectedEmotionImage: Image? = nil // TODO: pull from wherever the chosen stamp actually lives
    
    // Used to draw step 4's tooltips stuck to the right of the real buttons,
    // in a completely separate top-level layer — this never touches their layout.
    @State private var toolButtonFrames: [String: ToolButtonFramePreference] = [:]
    
    // Name of the shared coordinate space every tooltip-publishing view and the
    // tooltip-drawing layer both agree on, so positions line up correctly.
    private let coordinateSpaceName = "onboardingSpace"
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    ToolButton(
                        id: "back",
                        action: {
                            dismiss()
                        },
                        assetName: "button_back",
                        toolTipText: "",
                        coordinateSpaceName: "none"
                    )
                    
                    // To create equal spacing between section
                    ToolButton(
                        id: "",
                        action: {
                            print("Back button clicked")
                        },
                        assetName: "button_back",
                        toolTipText: "",
                        coordinateSpaceName: "none"
                    )
                    .disabled(true)
                    .opacity(0)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        ToolButton(
                            id: "magicPen",
                            action: {
                                handleMagicPenAction {
                                    print("Magic pen button clicked")
                                }
                            },
                            assetName: "button_magicpen",
                            toolTipText: "Tap here to get a writing idea",
                            isDisabled: showToolOnboarding || showMagicPenOnboarding,
                            coordinateSpaceName: coordinateSpaceName
                        )
                        
                        ToolButton(
                            id: "text",
                            action: {
                                handleToolbarAction {
                                    print("Text button clicked")
                                }
                            },
                            assetName: "button_text",
                            toolTipText: "Tap here to add text",
                            isDisabled: showToolOnboarding,
                            coordinateSpaceName: coordinateSpaceName
                        )
                        
                        ToolButton(
                            id: "scribble",
                            action: {
                                handleToolbarAction {
                                    print("Scribble or Draw button clicked")
                                }
                            },
                            assetName: "button_pencil",
                            toolTipText: "Tap here to draw or write with your brush",
                            isDisabled: showToolOnboarding,
                            coordinateSpaceName: coordinateSpaceName
                        )
                        
                        ToolButton(
                            id: "photo",
                            action: {
                                handleToolbarAction {
                                    print("Photo button clicked")
                                }
                            },
                            assetName: "button_image",
                            toolTipText: "Tap here to add image from photo library",
                            isDisabled: showToolOnboarding,
                            coordinateSpaceName: coordinateSpaceName
                        )
                        
                        ToolButton(
                            id: "mic",
                            action: {
                                handleToolbarAction {
                                    print("Mic button clicked")
                                }
                            },
                            assetName: "button_mic",
                            toolTipText: "Tap here to add your voice to pages",
                            isDisabled: showToolOnboarding,
                            coordinateSpaceName: coordinateSpaceName
                        )
                        
                        ToolButton(
                            id: "layer",
                            action: {
                                handleLayerAction {
                                    print("Layer button clicked")
                                }
                            },
                            assetName: "button_layer",
                            toolTipText: "Tap and drag to reorder layers (top items in the front)",
                            isDisabled: showToolOnboarding || showLayerOnboarding,
                            coordinateSpaceName: coordinateSpaceName
                        )
                    }
                    .opacity(showToolOnboarding || showMagicPenOnboarding || showLayerOnboarding ? 0 : 1)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        ToolButton(
                            id: "trash",
                            action: {
                                print("Trash button clicked")
                            },
                            assetName: "button_trash",
                            toolTipText: "",
                            coordinateSpaceName: "none"
                        )
                        
                        ToolButton(
                            id: "checkmark",
                            action: {
                                withAnimation { showSealAnimation = true }
                            },
                            assetName: "button_checkmark",
                            toolTipText: "",
                            coordinateSpaceName: "none"
                        )
                    }
                }
                
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                ZStack {
                    Image("halaman_kertas_kosong")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 450)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            openPaperDetail()
                        }
                        .simultaneousGesture(
                            MagnifyGesture(minimumScaleDelta: 0.01)
                                .onEnded { value in
                                    guard value.magnification > 1.08 else { return }
                                    openPaperDetail()
                                }
                        )
                    
                    EmotionStampButton(
                        selectedImage: $selectedEmotionImage,
                        action: {
                            handleEmotionStampAction()
                        }
                    )
                    .opacity(showEmotionStampOnboarding ? 0 : 1)
                    .offset(x: 440, y: -200)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ToolButtonFramePreferenceKey.self,
                                            value: [ToolButtonFramePreference(id: "emotionStamp", frame: geo.frame(in: .named(coordinateSpaceName)), tooltipText: "")])
                        }
                    )
                    
                    JournalNavButton(
                        assetName: "button_back",
                        buttonTitle: "Previous page",
                        xImageAsset: 72,
                        yImageAsset: -210,
                        xnavButton: -640,
                        ynavButton: 600,
                        degree: 4,
                        action: {
                            handleNavAction {
                                print("Previous journal page tapped!")
                            }
                        }
                    )
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ToolButtonFramePreferenceKey.self,
                                            value: [ToolButtonFramePreference(id: "navBack", frame: geo.frame(in: .named(coordinateSpaceName)), tooltipText: "")])
                        }
                    )
                    
                    JournalNavButton(
                        assetName: "button_plus",
                        buttonTitle: "Add new page",
                        xImageAsset: -72,
                        yImageAsset: -210,
                        xnavButton: 630,
                        ynavButton: 600,
                        degree: 4,
                        action: {
                            handleNavAction {
                                print("Add new journal page tapped!")
                            }
                        }
                    )
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ToolButtonFramePreferenceKey.self,
                                            value: [ToolButtonFramePreference(id: "navForward", frame: geo.frame(in: .named(coordinateSpaceName)), tooltipText: "")])
                        }
                    )
                }
                
                Spacer()
            }
            
            // MARK: - Tool Onboarding Overlay
            if showToolOnboarding {
                ToolTipOnboardingView(
                    hasToolOnboarding: $hasToolOnboarding,
                    showToolOnboarding: $showToolOnboarding
                )
            }
            
            // MARK: - Magic Pen Onboarding Overlay
            if showMagicPenOnboarding {
                MagicPenOnboardingView(
                    hasMagicPenOnboarding: $hasMagicPenOnboarding,
                    showMagicPenOnboarding: $showMagicPenOnboarding,
                    toolButtonFrames: $toolButtonFrames
                )
            }
            
            // MARK: - Emotion Stamp Onboarding Overlay
            if showEmotionStampOnboarding {
                EmotionStampOnboardingView(
                    hasEmotionStampOnboarding: $hasEmotionStampOnboarding,
                    showEmotionStampOnboarding: $showEmotionStampOnboarding,
                    toolButtonFrames: $toolButtonFrames
                )
            }
            
            // MARK: - Nav Onboarding Overlay
            if showNavOnboarding {
                JournalNavOnboardingView(
                    hasNavOnboarding: $hasNavOnboarding,
                    showNavOnboarding: $showNavOnboarding,
                    toolButtonFrames: $toolButtonFrames
                )
            }
            
            // MARK: - Layer Onboarding Overlay
            if showLayerOnboarding {
                LayerOnboardingView(
                    hasLayerOnboarding: $hasLayerOnboarding,
                    showLayerOnboarding: $showLayerOnboarding,
                    toolButtonFrames: $toolButtonFrames
                )
            }
            
            if showPaperDetail {
                JournalPaperDetailView {
                    showPaperDetail = false
                }
                .zIndex(10)
            }
            
            if showSealAnimation {
                LetterSealAnimationView(sealImage: selectedEmotionImage, onFinish: {
                    dismiss()
                }) {
                    Image("halaman_kertas_kosong")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 450)
                }
                .transition(.opacity)
                .zIndex(11)
            }
        }
        
        .navigationBarBackButtonHidden(true)
        .coordinateSpace(name: coordinateSpaceName)
        .onPreferenceChange(ToolButtonFramePreferenceKey.self) { prefs in
            var dict: [String: ToolButtonFramePreference] = [:]
            for pref in prefs {
                dict[pref.id] = pref
            }
            toolButtonFrames = dict
            
        }
    }
    
    private func openPaperDetail() {
        withAnimation(.easeInOut(duration: 0.22)) {
            showPaperDetail = true
        }
    }
    
    // MARK: - Toolbar Action Interception
    /// Wraps taps on the 4 toolbar tools.
    /// The first time any of them is tapped, the onboarding overlay is shown
    /// instead of running the real action. Once onboarding has been completed,
    /// subsequent taps run the actual action normally.
    private func handleToolbarAction(_ action: () -> Void) {
        guard hasToolOnboarding else {
            withAnimation(.easeInOut) {
                showToolOnboarding = true
            }
            return
        }
        action()
    }
    
    private func handleMagicPenAction(_ action: () -> Void) {
        guard hasMagicPenOnboarding else {
            withAnimation(.easeInOut) {
                showMagicPenOnboarding = true
            }
            return
        }
        action()
    }
    
    private func handleLayerAction(_ action: () -> Void) {
        guard hasLayerOnboarding else {
            withAnimation(.easeInOut) {
                showLayerOnboarding = true
            }
            return
        }
        action()
    }
    
    private func handleEmotionStampAction() -> Bool {
        guard hasEmotionStampOnboarding else {
            withAnimation(.easeInOut) {
                showEmotionStampOnboarding = true
            }
            return false
        }
        return true
    }
    
    private func handleNavAction(_ action: () -> Void) {
        guard hasNavOnboarding else {
            withAnimation(.easeInOut) {
                showNavOnboarding = true
            }
            return
        }
        action()
    }
}

#Preview (traits: .landscapeRight) {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Journal.self, configurations: configuration)
    
    let context = container.mainContext
    let repository = JournalRepository(modelContext: context)
    let viewModel = JournalViewModel(repository: repository)
    
    UserDefaults.standard.set(false, forKey: "hasToolOnboarding")
    UserDefaults.standard.set(false, forKey: "hasMagicPenOnboarding")
    UserDefaults.standard.set(false, forKey: "hasEmotionStampOnboarding")
    UserDefaults.standard.set(false, forKey: "hasNavOnboarding")
    UserDefaults.standard.set(false, forKey: "hasLayerOnboarding")
    
    return JournalEditorView()
        .environment(viewModel)
        .modelContainer(container)
}
