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
    
    // game level settings
    private let levels = ["LOVE", "APPLE", "WWDC", "LAKE", "BABY"]
    
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
                        showingLevelPicker = true
                    }) {
                        HStack(spacing: 8) {
                            Text("Level \(currentLevel + 1):")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                            Text(levels[currentLevel])
                                .font(.title3.bold())
                                .foregroundColor(.blue)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    NavigationButton(
                        icon: "chevron.right",
                        title: "Next",
                        action: nextLevel
                    )
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .disabled(showingBalloons)
                
                // Camera view with overlays
                ZStack {
                    CameraView(prediction: Binding(
                        get: { prediction },
                        set: { newValue in
                            prediction = newValue
                            handlePredictionChange(newValue)
                        }
                    ))
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.6)
                    
                    // display all active 3D letters
                    ForEach(activeLetters) { letterDisplay in
                        Letter3DView(letter: letterDisplay.letter)
                            .frame(width: 300, height: 300)
                            .allowsHitTesting(false)
                    }
                    
                    // Balloons animation overlay
                    if showingBalloons {
                        BalloonView(startPosition: -5)
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.height * 0.6)
                            .clipped()
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(20)
                .padding()
                
                // Bottom section
                VStack(spacing: 20) {
                    // Prediction label
                    if let prediction = prediction {
                        HStack {
                            Text(prediction.label)
                                .font(.title3.bold())
                                .foregroundColor(
                                    currentLetterIndex < currentWord.count && // check if the current letter index is less than the current word count
                                    prediction.label == String(currentWord[currentWord.index(currentWord.startIndex, offsetBy: currentLetterIndex)])
                                    ? .green
                                    : .primary
                                )
                            Text(String(format: "%.1f%%", prediction.confidence * 100))
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.7, height: 30)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    } else {
                        Text("Waiting for gesture...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(width: UIScreen.main.bounds.width * 0.7, height: 30)
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
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingLevelPicker) {
            LevelPickerView(selectedLevel: $currentLevel, levels: levels)
        }
        .onDisappear {
            matchStartTime = nil
            lastPrediction = nil
        }
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

// level picker view
struct LevelPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedLevel: Int
    let levels: [String]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(levels.enumerated()), id: \.offset) { index, word in
                    Button(action: {
                        selectedLevel = index
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("Level \(index + 1)")
                                .foregroundColor(.primary)
                            Text(word)
                                .foregroundColor(.blue)
                                .font(.headline)
                            Spacer()
                            if index == selectedLevel {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose Level")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
