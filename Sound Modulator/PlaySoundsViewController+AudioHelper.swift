//
//  PlaySoundsViewController+AudioHelper.swift
//  Sound Modulator
//
//  Created by Pritam Hinger on 21/06/16.
//  Copyright © 2016 AppDevelapp. All rights reserved.
//

import UIKit
import AVFoundation

extension PlaySoundsViewController{
    //MARK:- Enum
    enum PlayingState { case Playing, NotPlaying }
    
    //MARK:- UI Helper Functions
    func setUpControlsForState(state: PlayingState){
        switch state {
        case .Playing:
            setUpPlayButtons(false);
            stopPlayingButton.enabled = true;
        case .NotPlaying:
            setUpPlayButtons(true);
            stopPlayingButton.enabled = false;
        }
    }
    
    func setUpPlayButtons(enabled: Bool){
        snailButton.enabled = enabled;
        rabbitButton.enabled = enabled;
        chipmunkButton.enabled = enabled;
        vaderButton.enabled = enabled;
        echoButton.enabled = enabled;
        reverbButton.enabled = enabled;
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: AlertMessages.DismissAlert, style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK:- Audio Helper Functions
    
    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordingURL)
        } catch {
            showAlert(AlertMessages.AudioFileError, message: String(error))
        }
        print("Audio has been setup")
    }
    
    func playSound(rate rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // initialize audio engine components
        audioEngine = AVAudioEngine()
        
        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attachNode(changeRatePitchNode)
        
        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.MultiEcho1)
        audioEngine.attachNode(echoNode)
        
        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.Cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attachNode(reverbNode)
        
        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, atTime: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTimeForNodeTime(lastRenderTime) {
                
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // schedule a stop timer for when audio finishes playing
            self.stopTimer = NSTimer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(self.stopTimer!, forMode: NSDefaultRunLoopMode)
        }
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(AlertMessages.AudioEngineError, message: String(error))
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
    }

    //MARK:- Utility Functions
    func connectAudioNodes(nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    func stopAudio() {
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        setUpControlsForState(.NotPlaying);
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    //MARK:- Structure
    struct AlertMessages {
        static let DismissAlert = "Dismiss";
        static let AudioFileError = "Audio File Error";
        static let AudioEngineError = "Audio Engine Error";
    }
}
