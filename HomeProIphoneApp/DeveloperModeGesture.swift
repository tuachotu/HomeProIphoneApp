//
//  DeveloperModeGesture.swift
//  HomeProIphoneApp
//
//  Created by Vikrant Singh on 8/9/25.
//

import SwiftUI

struct DeveloperModeGesture: ViewModifier {
    @State private var showingDeveloperSettings = false
    @State private var fingerCount = 0
    @State private var gestureTimer: Timer?
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // Count the number of fingers touching the screen
                        // This is a simplified approach - we'll use a long press with 3+ seconds
                    }
            )
            .onLongPressGesture(minimumDuration: 3.0, maximumDistance: 50) {
                // Trigger developer mode
                showingDeveloperSettings = true
            }
            .sheet(isPresented: $showingDeveloperSettings) {
                DeveloperSettingsView()
            }
    }
}

// More sophisticated gesture detector for multi-touch
struct MultiTouchGesture: ViewModifier {
    @State private var showingDeveloperSettings = false
    @GestureState private var touchCount = 0
    @State private var longPressTimer: Timer?
    
    func body(content: Content) -> some View {
        content
            .gesture(
                SimultaneousGesture(
                    // First finger
                    DragGesture(minimumDistance: 0)
                        .updating($touchCount) { _, state, _ in
                            state = 1
                        },
                    // Second finger
                    DragGesture(minimumDistance: 0)
                        .updating($touchCount) { _, state, _ in
                            state = max(state, 2)
                        }
                )
            )
            .onChange(of: touchCount) { count in
                if count >= 2 {
                    // Start timer for 3-finger long press
                    longPressTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                        if touchCount >= 2 {
                            showingDeveloperSettings = true
                        }
                    }
                } else {
                    // Cancel timer if not enough fingers
                    longPressTimer?.invalidate()
                    longPressTimer = nil
                }
            }
            .sheet(isPresented: $showingDeveloperSettings) {
                DeveloperSettingsView()
            }
    }
}

// Simple approach using just long press (easier to trigger)
struct SimpleDeveloperModeGesture: ViewModifier {
    @State private var showingDeveloperSettings = false
    @State private var pressStartTime: Date?
    @State private var tapCount = 0
    @State private var tapTimer: Timer?
    
    func body(content: Content) -> some View {
        content
            .onTapGesture(count: 1) {
                tapCount += 1
                
                // Reset tap count after 2 seconds
                tapTimer?.invalidate()
                tapTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                    tapCount = 0
                }
                
                // If 5 taps in sequence, show developer mode
                if tapCount >= 5 {
                    showingDeveloperSettings = true
                    tapCount = 0
                    tapTimer?.invalidate()
                }
            }
            .sheet(isPresented: $showingDeveloperSettings) {
                DeveloperSettingsView()
            }
    }
}

extension View {
    func developerModeGesture() -> some View {
        self.modifier(SimpleDeveloperModeGesture())
    }
    
    func multiTouchDeveloperMode() -> some View {
        self.modifier(MultiTouchGesture())
    }
}