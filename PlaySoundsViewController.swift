//
//  PlaySoundsViewController.swift
//  Sound Modulator
//
//  Created by Pritam Hinger on 20/06/16.
//  Copyright © 2016 AppDevelapp. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    //MARK:- Private Variables
    var recordingURL:NSURL!;
    var audioFile: AVAudioFile!;
    var audioEngine: AVAudioEngine!;
    var audioPlayerNode: AVAudioPlayerNode!;
    var stopTimer: NSTimer!;
    var recordedAudio: NSURL!;
    
    // Adding below property to track if the playing is interrupted by User
    var playInterrupted =  false;
    
    //MARK:- IBOutlets
    @IBOutlet weak var snailButton:UIButton!;
    @IBOutlet weak var rabbitButton:UIButton!;
    @IBOutlet weak var chipmunkButton:UIButton!;
    @IBOutlet weak var vaderButton:UIButton!;
    @IBOutlet weak var echoButton:UIButton!;
    @IBOutlet weak var reverbButton:UIButton!;
    @IBOutlet weak var stopPlayingButton:UIButton!;
    
    //MARK:- Enum
    // ButtonType Enum to identify the Button Tap.
    enum ButtonType:Int {case Snail=2, Rabbit=4, Chipmunk=6, Vader=8, Echo=10, Reverb=12}
    
    //MARK:- Life Cycle Events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Up Title of VC
        self.title = "Play Recording View";
        print(recordingURL);
        
        // Setting Up Audio
        setupAudio()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        // As soon as View is to Appear, we want to Setup our controls to
        // NotPlaying State.
        setUpControlsForState(PlayingState.NotPlaying);
    }
    
    // MARK: - IBActions
    //Below is the function called when various play buttons are tapped.
    @IBAction func playButtonTapped(sender: UIButton){
        
        // Setting Controls for Playing State as play button is being tapped.
        setUpControlsForState(PlayingState.Playing);
        print("Tag of Button pressed is : \(sender.tag)");
        
        // Setting playInterrupted as false as this procedure is called to Play audio file
        playInterrupted = false;
        // Switching based on the button Tapped.
        // Each case call playSound with its special Value as parameter
        switch (ButtonType(rawValue: sender.tag)!) {
            case .Snail:
                playSound(rate: 0.75)
            case .Rabbit:
                playSound(rate: 2.25)
            case .Chipmunk:
                playSound(pitch: 500);
            case .Vader:
                playSound(pitch: -500);
            case .Echo:
                playSound(echo: true);
            case .Reverb:
                playSound(reverb: true);
        }
    }
 
    // Below func is triggered to stop playing
    @IBAction func stopPlayButtonTapped(sender: UIButton){
        // Setting PlayInterrupted to true as user has pressed Stop button to forcefully stop playing.
        playInterrupted = true;
        stopAudio();
    }

}
