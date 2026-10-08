//
//  JournalDetailView.swift
//  Postbox
//
//  Created by habil on 09/08/26.
//

import SwiftUI

struct JournalDetailView: View {
    @Environment(JournalViewModel.self) private var viewModel: JournalViewModel?
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasJournalDetailOnboarding") private var hasJournalDetailOnboarding: Bool = false

    @State private var currentPageIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    
    @State private var showDropdown: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var showJournalDetailOnboarding: Bool = false
    @State private var deleteTarget: DeleteTarget? = nil
    
    enum DeleteTarget {
        case paper
        case journal
    }
    
    private let totalPages: Int = 5
    
    private let dates: [String] = [
        "07 August 2026",
        "08 August 2026",
        "09 August 2026",
        "10 August 2026",
        "11 August 2026"
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // MARK: - Top Bar (Enlarged Icons: 68x68)
                topBar
                    .padding(.horizontal, 48)
                    .padding(.top, 32)
                
                Spacer()
                
                // MARK: - Main Content Area (Paper Stack Dead-Centered)
                ZStack {
                    paperStackView
                        .frame(width: 580, height: 740)
                        .zIndex(1)
                }
                .offset(x: -180, y: -30)
                
                Spacer()
            }
            .overlay(alignment: .topTrailing) {
                Image("emotion_stamp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 260)
                    .offset(x: -100, y: 220)
                
            }
            
            // MARK: - Detail Onboarding Overlay
            if showJournalDetailOnboarding {
                JournalDetailOnboardingView(
                    hasJournalDetailOnboarding: $hasJournalDetailOnboarding,
                    showJournalDetailOnboarding: $showJournalDetailOnboarding
                )
                .zIndex(1000)
            }
            
            // MARK: - Delete Confirmation Popup
            if showDeleteConfirmation {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showDeleteConfirmation = false
                        }
                    }
                    .zIndex(2)
                
                deleteConfirmationPopup
                    .zIndex(3)
            }
        }
        .onAppear {
            guard !hasJournalDetailOnboarding else { return }
            showJournalDetailOnboarding = true
        }
        .navigationBarBackButtonHidden(true)
    }
 
    // MARK: - Delete Confirmation Popup
    private var deleteConfirmationPopup: some View {
        let isJournal = deleteTarget == .journal
        let title = isJournal ? "Are you sure to delete entire journal?" : "Are you sure to delete this paper?"
        let message = "What you delete cannot be recovered."
        
        return VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 14, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 16)
            
            VStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        showDeleteConfirmation = false
                    }
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    // TODO: Perform deletion
                    withAnimation {
                        showDeleteConfirmation = false
                    }
                }) {
                    Text("Delete")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(white: 0.95))
                        .cornerRadius(12)
                }
            }
        }
        .padding(32)
        .frame(width: 400)
        .background(
            Image("popup_bg")
                .resizable()
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
    }
    
    // MARK: - Top Bar View (68x68)
    private var topBar: some View {
        HStack {
            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image("button_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
            }
            
            Spacer()
            
            // Action Buttons (Edit & Trash)
            HStack(spacing: 28) {
                Button(action: {}) {
                    Image("button_edit")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                }
                
                Button(action: {
                    withAnimation {
                        // Toggle dropdown visibility
                        showDropdown.toggle()
                    }
                }) {
                    Image("button_trash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                }
                .overlay(alignment: .topTrailing) {
                    if showDropdown {
                        VStack(spacing: 0) {
                            Button(action: {
                                deleteTarget = .paper
                                withAnimation {
                                    showDropdown = false
                                    showDeleteConfirmation = true
                                }
                            }) {
                                Text("Delete This Paper")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                            }
                            
                            Divider()
                            
                            Button(action: {
                                deleteTarget = .journal
                                withAnimation {
                                    showDropdown = false
                                    showDeleteConfirmation = true
                                }
                            }) {
                                Text("Delete Entire Journal")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .frame(width: 180)
                        .background(Color(white: 0.96))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        // Geser ke bawah sejauh tinggi icon (95) + sedikit jarak (10)
                        .offset(y: 105)
                        .zIndex(3000)
                    }
                }
            }
        }
    }
    
    // MARK: - Paper Stack View (Mockup Layout + Realistic Slide Physics)
    private var paperStackView: some View {
        let paperWidth: CGFloat = 580
        let paperHeight: CGFloat = 740
        let stackSpacing: CGFloat = 55
        
        return ZStack {
            ForEach(0..<totalPages, id: \.self) { index in
                let transform = paperTransform(for: index, stackSpacing: stackSpacing)
                
                paperCard(for: index)
                    .frame(width: paperWidth, height: paperHeight)
                    .offset(x: transform.x)
                    .scaleEffect(transform.scale)
                    .rotationEffect(transform.rotation)
                    .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
                    .zIndex(transform.zIndex)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 70
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        if value.translation.width < -threshold && currentPageIndex < totalPages - 1 {
                            currentPageIndex += 1
                        } else if value.translation.width > threshold && currentPageIndex > 0 {
                            currentPageIndex -= 1
                        }
                        dragOffset = 0
                    }
                }
        )
    }
    
    private struct PaperTransform {
        let x: CGFloat
        let scale: CGFloat
        let rotation: Angle
        let zIndex: Double
    }
    
    private func restingX(for diff: Int, stackSpacing: CGFloat) -> CGFloat {
        if diff > 3 {
            return 3 * stackSpacing
        } else if diff < -2 {
            return -2 * stackSpacing
        }
        return CGFloat(diff) * stackSpacing
    }
    
    private func restingRotation(for diff: Int) -> Double {
        if diff > 3 {
            return 3.0 * 2.0
        } else if diff < -2 {
            return -2.0 * 2.0
        }
        return Double(diff) * 2.0
    }
    
    private func paperTransform(for index: Int, stackSpacing: CGFloat) -> PaperTransform {
        let diff = index - currentPageIndex
        
        let swipeDistance: CGFloat = 320
        let dragRatio = max(-1.0, min(1.0, dragOffset / swipeDistance))
        
        let currentRestingX = restingX(for: diff, stackSpacing: stackSpacing)
        let currentRestingRotation = restingRotation(for: diff)
        
        var x = currentRestingX
        let scale: CGFloat = 1.0
        var rotationDegrees = currentRestingRotation
        var zIndex: Double = 100.0 - Double(abs(diff)) * 10.0
        
        // MARK: - SWIPE LEFT → NEXT PAGE
        if dragOffset < 0 {
            
            if index == currentPageIndex {
                // Halaman aktif mengikuti jari
                x = dragOffset
                
                // Sedikit rotasi saat ditarik
                rotationDegrees = Double(dragRatio * 3.5)
                
                zIndex = 200
                
            } else if index < currentPageIndex {
                
                let distance = abs(diff)
                let influence = 1.0 / CGFloat(distance)
                
                x =
                currentRestingX
                + dragOffset * influence * 0.35
                
                let targetRestingRotation = restingRotation(for: diff - 1)
                rotationDegrees = currentRestingRotation + (targetRestingRotation - currentRestingRotation) * abs(Double(dragRatio))
                
                // Tetap di bawah halaman aktif
                zIndex = 100 - Double(distance)
                
            } else {
                
                let targetRestingX = restingX(for: diff - 1, stackSpacing: stackSpacing)
                let targetRestingRotation = restingRotation(for: diff - 1)
                
                // Stack kanan perlahan maju (interpolasi dari current ke target)
                x = currentRestingX - (currentRestingX - targetRestingX) * abs(dragRatio)
                rotationDegrees = currentRestingRotation + (targetRestingRotation - currentRestingRotation) * abs(Double(dragRatio))
                
                zIndex = 100 - Double(abs(diff))
            }
        }
        
        // MARK: - SWIPE RIGHT → PREVIOUS PAGE
        else if dragOffset > 0 {
            
            if index == currentPageIndex - 1 {
                
                // Halaman sebelumnya masuk dari kiri
                let startX = -stackSpacing
                
                x = startX + dragOffset
                
                let startRotation = restingRotation(for: -1)
                rotationDegrees = startRotation + (0 - startRotation) * Double(dragRatio)
                
                zIndex = 200
                
            } else if index < currentPageIndex - 1 {
                
                // Stack yang lebih jauh di kiri
                let distance = abs(diff)
                let influence = 1.0 / CGFloat(distance)
                
                x =
                currentRestingX
                + dragOffset * influence * 0.35
                
                let targetRestingRotation = restingRotation(for: diff + 1)
                rotationDegrees = currentRestingRotation + (targetRestingRotation - currentRestingRotation) * Double(dragRatio)
                
                zIndex = 100 - Double(distance)
                
            } else {
                
                let targetRestingX = restingX(for: diff + 1, stackSpacing: stackSpacing)
                let targetRestingRotation = restingRotation(for: diff + 1)
                
                // Halaman aktif + halaman kanan mundur perlahan
                x = currentRestingX + (targetRestingX - currentRestingX) * dragRatio
                rotationDegrees = currentRestingRotation + (targetRestingRotation - currentRestingRotation) * Double(dragRatio)
                
                zIndex = 100 - Double(abs(diff))
            }
        }
        
        return PaperTransform(
            x: x,
            scale: scale,
            rotation: .degrees(rotationDegrees),
            zIndex: zIndex
        )
    }
    
    // Helper to render individual paper content
    private func paperCard(for index: Int) -> some View {
        ZStack(alignment: .top) {
            Image("halaman_surat_kosong")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            VStack(spacing: 16) {
                Text(dates[index % dates.count])
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundColor(.secondary)
                    .padding(.top, 58)
                
                VStack(spacing: 24) {
                    DecorativeWavyLine()
                    DecorativeWavyLine()
                    DecorativeWavyLine()
                    DecorativeWavyLine()
                    DecorativeWavyLine()
                }
                .padding(.top, 24)
                .padding(.horizontal, 64)
            }
        }
    }
}

// Decorative wavy lines matching mockup illustration style (iPad Scale)
struct DecorativeWavyLine: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 6))
            path.addCurve(
                to: CGPoint(x: 270, y: 6),
                control1: CGPoint(x: 68, y: -6),
                control2: CGPoint(x: 202, y: 18)
            )
        }
        .stroke(Color.black.opacity(0.7), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
        .frame(width: 270, height: 12)
    }
}

#Preview (traits: .landscapeRight) {
    UserDefaults.standard.set(false, forKey: "hasJournalDetailOnboarding")
    return JournalDetailView()
}


