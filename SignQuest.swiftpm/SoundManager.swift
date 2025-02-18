//
//  SoundManager.swift
//  SignQuest
//
//  Created by YoungHypo on 2/16/25
//


import AVFoundation

@MainActor
final class SoundManager {
    static let shared = SoundManager()
    private var players: [String: AVAudioPlayer] = [:]
    
    private init() {
        // preload all sounds
        preloadSound(filename: "success", type: "mp3")
        preloadSound(filename: "rise", type: "mp3")
    }
    
    private func preloadSound(filename: String, type: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: type) else { return }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[filename] = player
        } catch {
            print("Failed to load sound \(filename): \(error.localizedDescription)")
        }
    }
    
    func playSound(_ filename: String) {
        Task { @MainActor in
            players[filename]?.play()
        }
    }
} 