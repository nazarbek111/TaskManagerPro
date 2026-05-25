//
//  SoundService.swift
//  TaskManagerPro
//

import Foundation
import AVFoundation
import AudioToolbox

final class SoundService: NSObject {
    static let shared = SoundService()

    private var audioPlayer: AVAudioPlayer?

    func playSuccessSound() {
        // Try to play built-in system-like sound first via AudioServices
        AudioServicesPlaySystemSound(1057) // "SMS Received"-like short sound

        // Optionally, if you want AVAudioPlayer (e.g., for a bundled sound), try to load it safely
        guard let url = Bundle.main.url(forResource: "success", withExtension: "wav") else {
            return // No bundled sound, fallback already played
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer = player
            player.prepareToPlay()
            player.play()
        } catch {
            // Silently fail; do not crash the app
        }
    }
}
