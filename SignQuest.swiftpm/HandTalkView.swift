//
//  HandTalkView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/7/25
//

import SwiftUI

struct HandTalkView: View {
    // Time constants
    private let recognitionDuration: TimeInterval = 0.8  // recognition duration
    private let letterDisplayDuration: TimeInterval = 0.8  // letter display duration

    @Environment(\.presentationMode) var presentationMode
    @State private var prediction: (label: String, confidence: Double)?
    @State private var translatedText = ""
    @State private var isEditing = false
    @State private var matchStartTime: Date?
    @State private var lastPrediction: String?
    @State private var cameraWidth: CGFloat = 500
    @State private var cameraHeight: CGFloat = 360
    @State private var dictionaryOffset: CGFloat = UIScreen.main.bounds.height
    @State private var selectedLetter = "A"
    
    // add a struct to track the display status of each letter
    struct LetterDisplay: Identifiable {
        let id = UUID()
        let letter: String
        let createdAt: Date
    }
    
    @State private var activeLetters: [LetterDisplay] = []
    
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
                    
                    Text("Hand Talk")
                        .font(.system(size: 24, weight: .bold))
                    
                    Spacer()
                    
                    NavigationButton(
                        icon: "text.magnifyingglass",
                        title: "Dict",
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dictionaryOffset = 0
                            }
                        }
                    )
                }
                .padding(.horizontal, 10)
                .padding(.top, 20)
                
                // Introduction section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Start free spelling with your hands! 🗣️")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 10) {
                            Image(systemName: "hand.wave.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 20)
                            Text("Use your ASL skills to spell words freely in TextEditor below")
                                .font(.system(size: 16, weight: .regular))
                        }

                        HStack(spacing: 10) {
                            Image(systemName: "hands.sparkles.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 20)
                            Text("Keep your hand steady for at least ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("0.8 seconds")
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 20)
                            Text("Use ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("Delete")
                                .font(.system(size: 16, weight: .bold)) +
                            Text(", ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("Space")
                                .font(.system(size: 16, weight: .bold)) +
                            Text(" and ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("Clear")
                                .font(.system(size: 16, weight: .bold)) +
                            Text(" to edit your text")
                                .font(.system(size: 16, weight: .regular))
                        }

                        // Add dictionary lookup instruction
                        HStack(spacing: 10) {
                            Image(systemName: "book.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 20)
                            Text("Check ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("Dictionary")
                                .font(.system(size: 16, weight: .bold)) +
                            Text(" in navigation bar for sign gestures")
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
                
                // Camera view with 3D letters overlay
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
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                // Bottom section
                VStack(spacing: 28) {
                    // Prediction label
                    if let prediction = prediction {
                        HStack(spacing: 15) {
                            Text(prediction.label)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
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
                    
                    // Text editor
                    TextEditor(text: $translatedText)
                        .font(.system(size: 20))
                        .frame(width: 300, height: 100)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                        .disableTextEditorEditing()
                    
                    // Control buttons
                    HStack(spacing: 55) {
                        ControlButton(
                            icon: "delete.left.fill",
                            color: .red
                        ) {
                            if !translatedText.isEmpty {
                                translatedText.removeLast()
                            }
                        }
                        
                        ControlButton(
                            icon: "space",
                            color: .blue
                        ) {
                            translatedText += " "
                        }
                        
                        ControlButton(
                            icon: "trash.fill",
                            color: .red
                        ) {
                            translatedText = ""
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
            }
            
            dictionaryLayer
        }
        .navigationBarHidden(true)
        .onDisappear {
            matchStartTime = nil
            lastPrediction = nil
        }
    }
    
    // detecting the prediction
    private func handlePredictionChange(_ newPrediction: (label: String, confidence: Double)?) {
        if let prediction = newPrediction {
            if prediction.label == lastPrediction {
                if matchStartTime == nil {
                    matchStartTime = Date()
                } else if Date().timeIntervalSince(matchStartTime!) >= recognitionDuration {
                    // add a new letter to the display
                    let newLetter = LetterDisplay(letter: prediction.label, createdAt: Date())
                    activeLetters.append(newLetter)
                    
                    // play rise sound
                    SoundManager.shared.playSound("rise")
                    
                    // remove the letter after the display duration
                    DispatchQueue.main.asyncAfter(deadline: .now() + letterDisplayDuration) {
                        activeLetters.removeAll { $0.id == newLetter.id }
                    }
                    
                    translatedText += prediction.label
                    matchStartTime = nil
                    lastPrediction = nil
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
    
    private var dictionaryLayer: some View {
        ZStack {
            // transparent background
            if dictionaryOffset < UIScreen.main.bounds.height {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dictionaryOffset = UIScreen.main.bounds.height
                        }
                    }
            }
            
            VStack(spacing: 20) {
                // title bar
                HStack {
                    Spacer()
                    Text("ASL Dictionary")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dictionaryOffset = UIScreen.main.bounds.height
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Letters grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 4), spacing: 15) {
                    ForEach(letters, id: \.self) { letter in
                        Button(action: {
                            selectedLetter = letter
                        }) {
                            Text(letter)
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(letter == selectedLetter ? Color.blue : Color(UIColor.secondarySystemBackground))
                                .foregroundColor(letter == selectedLetter ? .white : .primary)
                                .cornerRadius(15)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Selected letter image
                VStack(spacing: 15) {
                    Text(selectedLetter)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Image(selectedLetter)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .padding(.horizontal)
                
                Spacer()
            }
            .frame(width: 500)
            .frame(height: 840)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(25)
            .shadow(radius: 10)
            .offset(y: dictionaryOffset)
        }
        .ignoresSafeArea()
    }
}

// Control button component
struct ControlButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(width: 60, height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.8),
                                    color.opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(
                            color: color.opacity(0.3),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                )
                .foregroundColor(.white)
        }
    }
}

// add a custom modifier to disable the editing of TextEditor
extension View {
    func disableTextEditorEditing() -> some View {
        self.onAppear {
            UITextView.appearance().isEditable = false
        }
        .onDisappear {
            UITextView.appearance().isEditable = true
        }
    }
}

#Preview {
    HandTalkView()
}
