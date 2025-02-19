//
//  SignSchoolView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/7/25
//

import SwiftUI

struct SignSchoolView: View {
    // Time constants
    private let recognitionDuration: TimeInterval = 0.8  // recognition duration
    private let transitionDuration: TimeInterval = 0.3   // transition duration
    private let shakeInterval: TimeInterval = 0.1        // shake interval
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentLetter = "A"
    @State private var showingLetterPicker = false
    @State private var prediction: (label: String, confidence: Double)?
    @State private var matchTimer: Timer?
    @State private var matchStartTime: Date?
    @State private var showingTip = false
    @State private var letterScale = 1.0
    @State private var letterOpacity = 1.0
    @State private var isRotating = false
    @State private var labelOffset: CGFloat = 0
    @State private var isARMode = false
    @State private var isLoadingAR = false
    @State private var showingBalloons = false
    @State private var letterPickerOffset: CGFloat = UIScreen.main.bounds.height
    
    private let letters = Array("ABCDEFGHIKLMNOPQRSTUVWXY").map(String.init)
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                // Navigation bar
                HStack {
                    NavigationButton(
                        icon: "chevron.left",
                        title: "Back",
                        action: { presentationMode.wrappedValue.dismiss() }
                    )
                    
                    Spacer()
                    
                    // Letter picker button with animation
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            letterPickerOffset = 0
                        }
                    }) {
                        HStack(spacing: 10) {
                            Text("Letter:")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .offset(x: labelOffset)
                            Text(currentLetter)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
                                .scaleEffect(letterScale)
                                .opacity(letterOpacity)
                                .rotation3DEffect(
                                    .degrees(isRotating ? 360 : 0),
                                    axis: (x: 0.0, y: 1.0, z: 0.0)
                                )
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    NavigationButton(
                        icon: "chevron.right",
                        title: "Next",
                        action: performLetterTransition
                    )
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .disabled(showingBalloons)
                
                // Camera/AR view
                ZStack {
                    if isARMode {
                        HandModelView(currentLetter: currentLetter)
                            .frame(width: 500)
                            .frame(height: 400)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)
                    } else {
                        CameraView(prediction: Binding(
                            get: { prediction },
                            set: { newValue in
                                prediction = newValue
                                handlePredictionChange(newValue)
                            }
                        ))
                        .frame(width: 500)
                        .frame(height: 400)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                    }
                    
                    // Loading overlay
                    if isLoadingAR {
                        ZStack {
                            Color.black.opacity(0.5)
                            VStack(spacing: 15) {
                                ProgressView()
                                    .scaleEffect(1.8)
                                    .tint(.white)
                                Text("Loading 3D Model...")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                            }
                        }
                        .transition(.opacity)
                        .frame(width: 500)
                        .frame(height: 400)
                    }
                    
                    // Balloons animation overlay
                    if showingBalloons {
                        BalloonView(startPosition: -5)
                            .frame(width: 500)
                            .frame(height: 400)
                            .clipped()
                    }
                    
                    // AR toggle button
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                if !isARMode {
                                    // switch to AR mode
                                    withAnimation {
                                        isLoadingAR = true
                                    }
                                    // delay a short time to switch to AR mode
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isARMode = true
                                        }
                                        // wait for the model to load and then hide the loading animation
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            withAnimation {
                                                isLoadingAR = false
                                            }
                                        }
                                    }
                                } else {
                                    // switch back to camera mode
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isARMode = false
                                    }
                                }
                            }) {
                                Image(systemName: isARMode ? "camera.fill" : "arkit")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
                                    )
                            }
                            .padding(10)
                            .disabled(isLoadingAR)
                        }
                    }
                    .padding(.top, 330)
                }
                .padding(.horizontal, 30)
                

                Spacer()
                
                // Bottom section
                VStack(spacing: 20) {
                    // Prediction label
                   if let prediction = prediction {
                        HStack(spacing: 15) {
                            Text(prediction.label)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(prediction.label == currentLetter ? .green : .primary)
                            Text(String(format: "%.1f%%", prediction.confidence * 100))
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 300, height: 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    } else {
                        Text("Waiting for gesture...")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                            .frame(width: 300, height: 40)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                    }
                    
                    // Hint button
                    Button(action: { showingTip = true }) {
                        HStack(spacing: 20) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 24))
                        }
                        .frame(width: 80, height: 50)
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
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )
                        )
                        .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            
            letterPickerLayer
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingTip) {
            TipView(letter: currentLetter)
        }
    }
    
    private var letterPickerLayer: some View {
        ZStack {
            // transparent background
            if letterPickerOffset < UIScreen.main.bounds.height {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            letterPickerOffset = UIScreen.main.bounds.height
                        }
                    }
            }
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Text("Select Letter")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            letterPickerOffset = UIScreen.main.bounds.height
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 30) {
                    ForEach(letters, id: \.self) { letter in
                        Button(action: {
                            if isARMode {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isARMode = false
                                }
                                // delay a short time to wait for the camera view to load
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    currentLetter = letter
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        letterPickerOffset = UIScreen.main.bounds.height
                                    }
                                }
                            } else {
                                currentLetter = letter
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    letterPickerOffset = UIScreen.main.bounds.height
                                }
                            }
                        }) {
                            Text(letter)
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(letter == currentLetter ? Color.blue : Color(UIColor.secondarySystemBackground))
                                .foregroundColor(letter == currentLetter ? .white : .primary)
                                .cornerRadius(15)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .frame(width: 500)
            .frame(height: 650)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(25)
            .shadow(radius: 10)
            .offset(y: letterPickerOffset)
        }
        .ignoresSafeArea()
    }
    
    // detecting the prediction
    private func handlePredictionChange(_ newPrediction: (label: String, confidence: Double)?) {
        // Skip prediction handling if balloons are showing
        guard !showingBalloons else { return }
        
        if let prediction = newPrediction, prediction.label == currentLetter {
            if matchStartTime == nil {
                matchStartTime = Date()
            } else if Date().timeIntervalSince(matchStartTime!) >= recognitionDuration {
                // Reset matchStartTime to prevent multiple triggers
                matchStartTime = nil
                
                // Play success sound and show animations
                SoundManager.shared.playSound("success")
                
                // show balloon animation after a short delay
                showSuccessAnimation()

                // execute letter transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    performLetterTransition()
                }
            }
        } else {
            matchStartTime = nil
        }
    }
    
    // Add success animation
    private func showSuccessAnimation() {
        showingBalloons = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            showingBalloons = false
        }
    }
    
    // add transition animation
    private func performLetterTransition() {
        // if in AR mode, switch back to camera mode
        if isARMode {
            withAnimation(.easeInOut(duration: 0.2)) {
                isARMode = false
            }
            // delay a short time to wait for the camera view to load
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                executeTransition()
            }
        } else {
            executeTransition()
        }
    }
    
    // extract the transition animation logic
    private func executeTransition() {
        // add scale and opacity animation
        withAnimation {
            letterScale = 1.5
            letterOpacity = 0
            isRotating = true
        }
        
        // add shake animation for the letter in navigation bar
        withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
            labelOffset = -5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + shakeInterval) {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                labelOffset = 5
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (shakeInterval * 2)) {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                labelOffset = 0
            }
        }
        
        // delay for transition duration and then transition to the next letter
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
            nextLetter()
            
            withAnimation(.spring(response: transitionDuration, dampingFraction: 0.6)) {
                letterScale = 1.0
                letterOpacity = 1.0
                isRotating = false
            }
        }
    }
    
    // logic of next letter
    private func nextLetter() {
        if let currentIndex = letters.firstIndex(of: currentLetter) {
            let nextIndex = (currentIndex + 1) % letters.count
            currentLetter = letters[nextIndex]
        }
    }
}

// Navigation button component
struct NavigationButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                Text(title)
                    .font(.system(size: 20))
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .foregroundColor(.primary)
        }
    }
}
