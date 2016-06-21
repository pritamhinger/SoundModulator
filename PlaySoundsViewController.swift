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
    
    //MARK:- IBOutlets
    @IBOutlet weak var snailButton:UIButton!;
    @IBOutlet weak var rabbitButton:UIButton!;
    @IBOutlet weak var chipmunkButton:UIButton!;
    @IBOutlet weak var vaderButton:UIButton!;
    @IBOutlet weak var echoButton:UIButton!;
    @IBOutlet weak var reverbButton:UIButton!;
    @IBOutlet weak var stopPlayingButton:UIButton!;
    
    //MARK:- Enum
    enum ButtonType:Int {case Snail=2, Rabbit=4, Chipmunk=6, Vader=8, Echo=10, Reverb=12}
    
    //MARK:- Life Cycle Events
    override func viewDidLoad() {
        super.viewDidLoad()
        print(recordingURL);
        // Do any additional setup after loading the view.
        setupAudio()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        setUpControlsForState(PlayingState.NotPlaying);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func playButtonTapped(sender: UIButton){
        
        setUpControlsForState(PlayingState.Playing);
        print("Tag of Button pressed is : \(sender.tag)");
        
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
 
    @IBAction func stopPlayButtonTapped(sender: UIButton){
        stopAudio();
    }

}
