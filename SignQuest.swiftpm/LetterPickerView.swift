//
//  LetterPickerView.swift
//  SignQuest
//
//  Created by YoungHypo on 2/16/25
//

import SwiftUI

struct LetterPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedLetter: String
    @Binding var isARMode: Bool
    let letters: [String]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 4)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(letters, id: \.self) { letter in
                        Button(action: {
                            if isARMode {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isARMode = false
                                }
                                // delay a short time to wait for the camera view to load
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    selectedLetter = letter
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                selectedLetter = letter
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text(letter)
                                .font(.title3.bold())
                                .frame(width: 60, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(letter == selectedLetter ? Color.blue : Color(UIColor.secondarySystemBackground))
                                )
                                .foregroundColor(letter == selectedLetter ? .white : .primary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Letter")
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