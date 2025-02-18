//
//  TipView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/16/25
//

import SwiftUI

struct TipView: View {
    @Environment(\.presentationMode) var presentationMode
    let letter: String
    
    // add map for gesture descriptions
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
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // letter display
                    Text(letter)
                        .font(.system(size: 110, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.top, 20)
                    
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
                        
                        Text(gestureDescriptions[letter] ?? "Description not available")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(5)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Gesture Guide")
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