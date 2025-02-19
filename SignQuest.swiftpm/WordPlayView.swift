//
//  WordPlayView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/7/25
//

import SwiftUI

struct WordPlayView: View {
    private let recognitionDuration: TimeInterval = 0.8  // recognition duration
    private let letterDisplayDuration: TimeInterval = 0.8  // letter display duration

    @Environment(\.presentationMode) var presentationMode
    @State private var prediction: (label: String, confidence: Double)?
    @State private var currentLevel = 0 // current level
    @State private var currentLetterIndex = 0 // current letter index
    @State private var showingLevelPicker = false
    @State private var matchStartTime: Date?
    @State private var lastPrediction: String?
    @State private var showingBalloons = false
    @State private var cameraWidth: CGFloat = 500
    @State private var cameraHeight: CGFloat = 500
    @State private var levelPickerOffset: CGFloat = UIScreen.main.bounds.height
    
    // game level settings
    private let levels = ["HELLO", "WORLD", "APPLE", "WWDC", "LAKE", "BABY"]
    
    // current word
    private var currentWord: String {
        levels[currentLevel]
    }
    
    // add a struct to track the display status of each letter
    struct LetterDisplay: Identifiable {
        let id = UUID()
        let letter: String
        let createdAt: Date
    }
    
    @State private var activeLetters: [LetterDisplay] = []

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
                    
                    // Level picker button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            levelPickerOffset = 0
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text("Level \(currentLevel + 1):")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                            Text(levels[currentLevel])
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.blue)
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
                        action: nextLevel
                    )
                }
                .padding(.horizontal, 10)
                .padding(.top, 20)
                .disabled(showingBalloons)
                
                // Introduction section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Game Time! 🎮")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 10) {
                            Image(systemName: "hand.point.up.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                            Text("Use your ASL skills to complete each level ✨")
                                .font(.system(size: 16, weight: .regular))
                        }
                        
                        HStack(spacing: 10) {
                            Image(systemName: "text.cursor")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                            Text("Sign each ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("blue letter")
                                .font(.system(size: 16, weight: .bold)) +
                            Text(" in sequence to spell the word 🔍")
                                .font(.system(size: 16, weight: .regular))
                        }
                        
                        HStack(spacing: 10) {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                            Text("Navigate levels using ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("Next")
                                .font(.system(size: 16, weight: .bold)) +
                            Text(" or level picker 🧭")
                                .font(.system(size: 16, weight: .regular))
                        }

                        HStack(spacing: 10) {
                            Image(systemName: "hands.sparkles.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                            Text("Ready? Start in Camera View below 🚀")
                                .font(.system(size: 16, weight: .regular))
                        }
                    }
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .padding(.horizontal, 30)
                
                // Camera view with overlays
                ZStack {
                    CameraView(prediction: Binding(
                        get: { prediction },
                        set: { newValue in
                            prediction = newValue
                            handlePredictionChange(newValue)
                        }
                    ))
                    .frame(width: cameraWidth)
                    .frame(height: cameraHeight)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                    
                    // display all active 3D letters
                    ForEach(activeLetters) { letterDisplay in
                        Letter3DView(letter: letterDisplay.letter)
                            .frame(width: 300, height: 300)
                            .allowsHitTesting(false)
                    }
                    
                    // Balloons animation overlay
                    if showingBalloons {
                        BalloonView(startPosition: -5)
                            .frame(width: cameraWidth)
                            .frame(height: cameraHeight)
                            .clipped()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)

                // Bottom section
                VStack(spacing: 30) {
                    // Prediction label
                    if let prediction = prediction {
                        HStack(spacing: 15) {
                            Text(prediction.label)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(
                                    currentLetterIndex < currentWord.count &&
                                    prediction.label == String(currentWord[currentWord.index(currentWord.startIndex, offsetBy: currentLetterIndex)])
                                    ? .green
                                    : .primary
                                )
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

                    // Word display
                    HStack(spacing: 12) {
                        ForEach(Array(currentWord.enumerated()), id: \.offset) { index, letter in
                            Text(String(letter))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(letterColor(at: index))
                                .frame(width: 50, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                Spacer()
            }
            
            levelPickerLayer
        }
        .navigationBarHidden(true)
        .onDisappear {
            matchStartTime = nil
            lastPrediction = nil
        }
    }
    
    private var levelPickerLayer: some View {
        ZStack {
            // transparent background
            if levelPickerOffset < UIScreen.main.bounds.height {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            levelPickerOffset = UIScreen.main.bounds.height
                        }
                    }
            }
            
            VStack(spacing: 0) {
                // title bar
                HStack {
                    Spacer()
                    Text("Choose Level")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            levelPickerOffset = UIScreen.main.bounds.height
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 10)
                
                // level list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(levels.enumerated()), id: \.offset) { index, word in
                            Button(action: {
                                currentLevel = index
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    levelPickerOffset = UIScreen.main.bounds.height
                                }
                            }) {
                                HStack {
                                    Text("Level \(index + 1)")
                                        .font(.system(size: 20))
                                        .foregroundColor(.primary)
                                    Text(word)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.blue)
                                    Spacer()
                                    if index == currentLevel {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 20))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(
                                    Rectangle()
                                        .fill(Color(UIColor.secondarySystemBackground))
                                        .opacity(index == currentLevel ? 0.5 : 0)
                                )
                            }
                            
                            if index < levels.count - 1 {
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(Color(UIColor.systemBackground))
            }
            .frame(width: 500)
            .frame(height: 500)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(25)
            .shadow(radius: 10)
            .offset(y: levelPickerOffset)
        }
        .ignoresSafeArea()
    }
    
    private func handlePredictionChange(_ newPrediction: (label: String, confidence: Double)?) {
        // Skip prediction handling if balloons are showing
        guard !showingBalloons else { return }
        
        guard currentLetterIndex < currentWord.count else { return }
        
        let targetLetter = String(currentWord[currentWord.index(currentWord.startIndex, offsetBy: currentLetterIndex)])
        
        if let prediction = newPrediction {
            if prediction.label == lastPrediction && prediction.label == targetLetter {
                if matchStartTime == nil {
                    matchStartTime = Date()
                } else if Date().timeIntervalSince(matchStartTime!) >= recognitionDuration {
                    // successfully match the current letter
                    currentLetterIndex += 1
                    matchStartTime = nil
                    lastPrediction = nil
                    
                    // check if this is the last letter of the word
                    if currentLetterIndex >= currentWord.count {
                        matchStartTime = nil
                        // Play success sound and show balloons for word completion
                        SoundManager.shared.playSound("success")
                        showSuccessAnimation()
                        
                        // delay a short time and automatically enter the next level
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            nextLevel()
                        }
                    } else {
                        // Not the last letter, show 3D letter and play rise sound
                        SoundManager.shared.playSound("rise")
                        showLetterAnimation(targetLetter)
                    }
                }
            } else {
                lastPrediction = prediction.label
                matchStartTime = nil
            }
        } else {
            matchStartTime = nil
            lastPrediction = nil
        }
    }
    
    // next level logic
    private func nextLevel() {
        currentLevel = (currentLevel + 1) % levels.count
        currentLetterIndex = 0
        matchStartTime = nil
        lastPrediction = nil
    }
    
    // letter color logic
    private func letterColor(at index: Int) -> Color {
        if index < currentLetterIndex {
            return .green  // completed letter
        } else if index == currentLetterIndex {
            return .blue   // current letter
        } else {
            return .gray   // uncompleted letter
        }
    }
    
    // Add letter animation
    private func showLetterAnimation(_ letter: String) {
        let newLetter = LetterDisplay(letter: letter, createdAt: Date())
        activeLetters.append(newLetter)
        
        // remove the letter after the display duration
        DispatchQueue.main.asyncAfter(deadline: .now() + letterDisplayDuration) {
            activeLetters.removeAll { $0.id == newLetter.id }
        }
    }
    
    // Add success animation
    private func showSuccessAnimation() {
        showingBalloons = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            showingBalloons = false
        }
    }
}
