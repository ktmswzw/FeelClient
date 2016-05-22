//
//  AudioPlayer.swift
//  AudioRecorder
//
//  Created by Vincent on 16/5/22.
//  Copyright © 2016年 com.xecoder.test. All rights reserved.
//

import AVFoundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer!
    
    override init() {
        
    }
    
    func startPlaying(message: voiceMessage) {
        if (audioPlayer != nil && audioPlayer.playing) {
            stopPlaying()
        }
        
        let voiceData = NSData(contentsOfURL: message.voicePath)
        
        do {
            try audioPlayer = AVAudioPlayer(data: voiceData!)
        } catch{
            return
        }
        audioPlayer.delegate = self
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            // no-op
        }
        
        audioPlayer.play()
    }
    
    
    func stopPlaying() {
        audioPlayer.stop()
    }
}
