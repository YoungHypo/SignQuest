//
//  HomeView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/7/25
//

import SwiftUI
import CoreML

struct HomeView: View {
    @State private var showingSignSchool = false
    @State private var showingHandSpell = false
    @State private var showingWordPlay = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 10) {
                    // hand wave logo and title
                    VStack(spacing: 40) {
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.linearGradient(
                                colors: [
                                    .green,
                                    .blue,
                                    .purple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        
                        VStack(spacing: 30) {
                            Text("SignQuest")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.linearGradient(
                                    colors: [.primary, .primary.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                            
                            Text("ASL Alphabet Learning")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 160)
                    
                    Spacer()
                    
                    // main buttons
                    VStack(spacing: 40) {
                        MainButton(
                            title: "Sign School",
                            icon: "text.book.closed.fill",
                            action: { showingSignSchool = true }
                        )
                        .navigationDestination(isPresented: $showingSignSchool) {
                            SignSchoolView()
                        }
                        
                        MainButton(
                            title: "Word Play",
                            icon: "gamecontroller.fill",
                            action: { showingWordPlay = true }
                        )
                        .navigationDestination(isPresented: $showingWordPlay) {
                            WordPlayView()
                        }
                        
                        MainButton(
                            title: "Hand Spell",
                            icon: "captions.bubble",
                            action: { showingHandSpell = true }
                        )
                        .navigationDestination(isPresented: $showingHandSpell) {
                            HandSpellView()
                        }
                    }
                    .padding(.bottom, 100)
                    
                    Spacer()

                    // Add platform requirement notice
                    VStack(spacing: 8) {
                        Text("⚠️ This playground requires Mac Catalyst platform with camera access 📸")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Main Button Component
struct MainButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 22, weight: .semibold))
            }
            .frame(width: 360, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.blue.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: Color.blue.opacity(0.3),
                        radius: isPressed ? 6 : 12,
                        x: 0,
                        y: isPressed ? 2 : 6
                    )
            )
            .foregroundColor(.white)
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
