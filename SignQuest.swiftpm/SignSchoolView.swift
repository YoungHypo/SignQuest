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
    @State private var tipViewOffset: CGFloat = 0
    @State private var cameraWidth: CGFloat = 500
    @State private var cameraHeight: CGFloat = 500
    
    private let letters = Array("ABCDEFGHIKLMNOPQRSTUVWXY").map(String.init)
    
    private let gestureDescriptions = [
        "A": "Make a fist with your thumb resting against the side of your index finger. The rest of the fingers stay curled down.",
        "B": "Hold all four fingers straight up, keeping them close together, and tuck your thumb across your palm.",
        "C": "Curve your hand to form the shape of the letter \"C,\" with fingers and thumb rounded.",
        "D": "Hold up your index finger while curling your middle, ring, and pinky fingers down. Touch your thumb to the tips of the curled fingers.",
        "E": "Curl all your fingers down toward your palm and let your thumb rest against the tips of your fingers (making an open \"claw\").",
        "F": "Touch the tip of your thumb to the tip of your index finger to form a circle, while holding the other three fingers straight up.",
        "G": "Extend your index finger and thumb horizontally as if you're holding something small. Keep other fingers tucked down.",
        "H": "Extend both your index and middle fingers horizontally, side by side, while keeping the rest folded down.",
        "I": "Make a fist and extend just your pinky finger straight up.",
        "K": "Extend your index and middle fingers upward in a \"V\" shape. Rest your thumb against the base of your middle finger.",
        "L": "Extend your index finger straight up and your thumb horizontally outward to form an \"L\" shape.",
        "M": "Curl all your fingers down over your thumb, but let the thumb poke out between the pinky and ring fingers.",
        "N": "Similar to \"M,\" but let the thumb poke out between the ring and middle fingers.",
        "O": "Bring the tips of all your fingers and your thumb together to form a round circle, like the letter \"O.\"",
        "P": "Hold your hand like \"K\" (make a \"V\" with the index and middle fingers), but rotate your hand downward so the fingers point toward the floor.",
        "Q": "Similar to \"G,\" but tilt your hand downward so that the index finger and thumb point to the floor.",
        "R": "Cross your index and middle fingers over each other, keeping the other fingers curled down and the thumb tucked in.",
        "S": "Make a fist with your thumb resting over the curled fingers.",
        "T": "Make a fist, but stick your thumb under your index finger so that it pokes out between your index and middle fingers.",
        "U": "Extend your index and middle fingers straight up, close together, with the rest of the fingers curled down.",
        "V": "Extend your index and middle fingers straight up, separated in the shape of a \"V.\"",
        "W": "Extend your index, middle, and ring fingers straight up to form the shape of a \"W.\" Keep your thumb and pinky curled down.",
        "X": "Curl your index finger to form a hook in the shape of an \"X.\" Keep the rest of the fingers curled down.",
        "Y": "Extend both your pinky and thumb outward while curling the rest of your fingers into a fist. It resembles a \"shaka\" or \"hang loose\" gesture."
    ]
    
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
                .padding(.top, 20)
                .disabled(showingBalloons)

                // Instruction section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Welcome to Sign School! 🎓")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(spacing: 10) {
                            Image(systemName: "hand.point.up.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 20)
                            Text("Practice ASL alphabet signs through interactive learning")
                                .font(.system(size: 16, weight: .regular))
                        }
                        
                        HStack(spacing: 10) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 20)
                            Text("Tap the bottom ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("hint")
                                .font(.system(size: 18, weight: .bold)) +
                            Text(" button for gesture details")
                                .font(.system(size: 16, weight: .regular))
                        }
                        
                        HStack(spacing: 10) {
                            Image(systemName: "arkit")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 20)
                            Text("View 360° 3D hand model by ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("AR icon")
                                .font(.system(size: 18, weight: .bold)) +
                            Text(" in Camera view")
                                .font(.system(size: 16, weight: .regular))
                        }
                        
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.forward.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 20)
                            Text("Navigate through letters using ")
                                .font(.system(size: 16, weight: .regular)) +
                            Text("Next")
                                .font(.system(size: 18, weight: .bold)) +
                            Text(" or letter picker")
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
                
                // Camera/AR view
                ZStack {
                    if isARMode {
                        HandModelView(currentLetter: currentLetter)
                            .frame(width: cameraWidth)
                            .frame(height: cameraHeight)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(20)

                        VStack {
                            Text("Tap Camera button below to return for gesture recognition 📸")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                                .padding(.bottom, 400)
                        }
                    } else {
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

                        VStack {
                            Text("Please position your palm towards the screen 🖐️")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                                .padding(.bottom, 400)
                        }
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
                        .frame(width: cameraWidth)
                        .frame(height: cameraHeight)
                    }
                    
                    // Balloons animation overlay
                    if showingBalloons {
                        BalloonView(startPosition: -5)
                            .frame(width: cameraWidth)
                            .frame(height: cameraHeight)
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
                                VStack {
                                    Image(systemName: isARMode ? "camera.fill" : "arkit")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            Circle()
                                                .fill(Color.black.opacity(0.3))
                                                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
                                        )
                                    Text(isARMode ? "Camera" : "AR")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(20)
                            .disabled(isLoadingAR)
                        }
                    }
                    .padding(.top, 400)
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
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            tipViewOffset = 0
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 24))
                            Text("Hint")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        .frame(width: 100, height: 50)
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
                .padding(.top, 10)

                Spacer()
            }
            
            letterPickerLayer
            tipLayer
        }
        .navigationBarHidden(true)
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
    
    private var tipLayer: some View {
        ZStack {
            // transparent background
            if tipViewOffset < UIScreen.main.bounds.height {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            tipViewOffset = UIScreen.main.bounds.height
                        }
                    }
            }
            
            VStack(spacing: 20) {
                // title bar
                HStack {
                    Spacer()
                    Text("Gesture Guide")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            tipViewOffset = UIScreen.main.bounds.height
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // letter display
                        Text(currentLetter)
                            .font(.system(size: 110, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, 10)
                        
                        // divider
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal)
                        
                        // gesture description
                        VStack(alignment: .leading, spacing: 15) {
                            Text("How to Sign")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            
                            Text(gestureDescriptions[currentLetter] ?? "Description not available")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(5)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                        .padding(.horizontal)

                        // Add practice encouragement
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "hands.sparkles.fill")
                                    .foregroundColor(.blue)
                                Text("Practice in Camera View 🔔")
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            Text("🎯 Keep your hand steady ✨")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        
                        // Add hand pose image
                        Image("\(currentLetter)")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
            }
            .frame(width: 500)
            .frame(height: 760)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(25)
            .shadow(radius: 10)
            .offset(y: tipViewOffset)
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
