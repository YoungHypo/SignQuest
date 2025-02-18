//
//  HomeView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/17/25.
//

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
    @State private var showingHandTalk = false
    @State private var showingWordPlay = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 10) {
                    VStack(spacing: 60) {
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(.linearGradient(
                                colors: [
                                    .green,
                                    .blue,
                                    .purple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        
                        VStack(spacing: 40) {
                            Text("SignQuest")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundStyle(.linearGradient(
                                    colors: [.primary, .primary.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                            
                            Text("ASL Alphabet Learning")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 160)
                    
                    Spacer()
                    
                    VStack(spacing: 50) {
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
                            title: "Hand Talk",
                            icon: "captions.bubble",
                            action: { showingHandTalk = true }
                        )
                        .navigationDestination(isPresented: $showingHandTalk) {
                            HandTalkView()
                        }
                    }
                    .padding(.bottom, 100)
                    
                    Spacer()
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
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                Text(title)
                    .font(.system(size: 28, weight: .semibold))
            }
            .frame(width: UIScreen.main.bounds.width * 0.6, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 20)
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
                        radius: isPressed ? 8 : 15,
                        x: 0,
                        y: isPressed ? 2 : 8
                    )
            )
            .foregroundColor(.white)
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
