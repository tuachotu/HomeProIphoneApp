//
//  ThreeFingerGesture.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/9/25.
//

import SwiftUI

struct ThreeFingerDeveloperGesture: ViewModifier {
    @State private var showingDeveloperSettings = false
    @State private var touchPositions: [CGPoint] = []
    @State private var gestureStartTime: Date?
    @State private var gestureTimer: Timer?
    
    func body(content: Content) -> some View {
        content
            .background(
                // Invisible overlay to capture gestures
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged { value in
                                handleGestureChanged(value)
                            }
                            .onEnded { _ in
                                handleGestureEnded()
                            }
                    )
            )
            .sheet(isPresented: $showingDeveloperSettings) {
                DeveloperSettingsView()
            }
    }
    
    private func handleGestureChanged(_ value: DragGesture.Value) {
        let currentTime = Date()
        
        if gestureStartTime == nil {
            gestureStartTime = currentTime
            touchPositions = [value.location]
        } else {
            // Update touch positions
            if !touchPositions.contains(where: { abs($0.x - value.location.x) < 50 && abs($0.y - value.location.y) < 50 }) {
                touchPositions.append(value.location)
            }
        }
        
        // Check if we have enough touch points and enough time has passed
        if touchPositions.count >= 3 {
            if gestureTimer == nil {
                gestureTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                    if touchPositions.count >= 3 {
                        triggerDeveloperMode()
                    }
                    resetGesture()
                }
            }
        }
    }
    
    private func handleGestureEnded() {
        // Small delay before resetting to allow for multi-touch detection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            resetGesture()
        }
    }
    
    private func triggerDeveloperMode() {
        showingDeveloperSettings = true
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    private func resetGesture() {
        gestureStartTime = nil
        touchPositions = []
        gestureTimer?.invalidate()
        gestureTimer = nil
    }
}

// Alternative simpler approach using sequential taps
struct SequentialTapDeveloperGesture: ViewModifier {
    @State private var showingDeveloperSettings = false
    @State private var tapCount = 0
    @State private var lastTapTime: Date = Date()
    @State private var resetTimer: Timer?
    
    private let requiredTaps = 7
    private let maxTimeBetweenTaps: TimeInterval = 1.0
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                handleTap()
            }
            .sheet(isPresented: $showingDeveloperSettings) {
                DeveloperSettingsView()
            }
    }
    
    private func handleTap() {
        let now = Date()
        
        // Reset if too much time has passed
        if now.timeIntervalSince(lastTapTime) > maxTimeBetweenTaps {
            tapCount = 1
        } else {
            tapCount += 1
        }
        
        lastTapTime = now
        
        // Reset timer
        resetTimer?.invalidate()
        resetTimer = Timer.scheduledTimer(withTimeInterval: maxTimeBetweenTaps + 0.1, repeats: false) { _ in
            tapCount = 0
        }
        
        // Check if we've reached the required number of taps
        if tapCount >= requiredTaps {
            triggerDeveloperMode()
            tapCount = 0
        }
    }
    
    private func triggerDeveloperMode() {
        showingDeveloperSettings = true
        
        // Add haptic feedback pattern
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impactFeedback.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            impactFeedback.impactOccurred()
        }
    }
}

extension View {
    func threeFingerDeveloperGesture() -> some View {
        self.modifier(ThreeFingerDeveloperGesture())
    }
    
    func sequentialTapDeveloperGesture() -> some View {
        self.modifier(SequentialTapDeveloperGesture())
    }
}