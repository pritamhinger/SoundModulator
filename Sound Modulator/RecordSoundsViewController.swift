//
//  ViewController.swift
//  Sound Modulator
//
//  Created by Pritam Hinger on 20/06/16.
//  Copyright © 2016 AppDevelapp. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingStatusLabel: UILabel!
    
    //MARK:- Private Variables
    var audioRecorder: AVAudioRecorder!;
    
    //MARK:- Enum
    enum RecordingState { case Recording, NotRecording }
    
    //MARK:- Struct
    
    // Below Struct contains string used in this View Controller
    struct StringConstants {
        static let RecordingStatus = "Tap to stop Recording >>";
        static let NotRecordingStatus = "<< Tap to Record";
        static let PlayRecordingSegueIdentifier = "playRecording";
        static let RecordingFileName = "recordedVoice.wav";
    }
    
    //MARK:- LifeCycle Events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting controls for Not Recording State
        setUpControlsForState(RecordingState.NotRecording);
        
        // Setting title of View Controller
        self.title = "Recording View";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- IBActions
    
    //Below is the Function to be triggered when Recording Button is tapped.
    @IBAction func startRecording(sender: AnyObject) {
        // On Being tapped, we change state to Recording and accordingly
        // Set controls
        setUpControlsForState(RecordingState.Recording);
        
        // Getting Directories in Document Domain and then setting first path to 
        // dirPath variable
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String;
        
        // Getting File name
        let recordingName = StringConstants.RecordingFileName;
        
        // Preparing path Array
        let pathArray = [dirPath, recordingName];
        
        // Creating file path from Path Component array created in last line
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        
        // Getting AVAudioSession instance
        let session = AVAudioSession.sharedInstance()
        
        // Configuring AVAudioSession instance to Play and Record.
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        // Initiating AVAudioRecorder Instance for Recording.
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        
        //Setting Delegate to Current View Controller.
        // Below line of Code tells AVAudioRecorderDelegate what VC to call on 
        // finishing its tasks
        audioRecorder.delegate = self;
        audioRecorder.meteringEnabled = true
        
        // Sending message to instane of AVAudioRecorder to Prepare for recording
        audioRecorder.prepareToRecord()
        
        // Sending message to instance of AVAudioRecorder to record
        audioRecorder.record()
    }
    
    //Below func is triggered when StopRecording Buttons is TappedIn.
    @IBAction func stopRecording(sender: AnyObject) {
        setUpControlsForState(RecordingState.NotRecording);
        
        //Calling Stop method of AVAudioRecorder to stop recording
        audioRecorder.stop();
        
        //Getting singleton instance of AVAudioSession
        let audioSession = AVAudioSession.sharedInstance();
        
        //Setting AVAudioSession Active property to false
        try! audioSession.setActive(false)
    }
    
    //MARK:- AVAudioRecorderDelegate methods
    
    //Below methods is called when AVAudioRecorder Instance is finished saving 
    //the audio file
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        // Flag will be true when recording saved successfully.
        if(flag){
            self.performSegueWithIdentifier(StringConstants.PlayRecordingSegueIdentifier, sender: audioRecorder.url);
        }
        else{
            print("Error saving the recorded file.")
        }
    }
    
    //MARK:- Seque Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Checking if the Segue Identifier is the one we want.
        if(segue.identifier == StringConstants.PlayRecordingSegueIdentifier){
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController;
            
            // Force casting sender as NSURL
            // It is safe to force cast here as we ourself send NSURL instance
            // from audioRecorderDidFinishRecording
            let recordingURL = sender as! NSURL;
            
            // Setting Recording URL in Destination VC
            playSoundsVC.recordingURL = recordingURL;
        }
    }
    
    //MARK:- Private Functions
    
    // Below function set control's states depending on the Recording state passed.
    func setUpControlsForState(state: RecordingState){
        if (state == RecordingState.Recording){
            startRecordingButton.enabled = false;
            stopRecordingButton.enabled = true;
            recordingStatusLabel.text = StringConstants.RecordingStatus;
        }
        else if (state == RecordingState.NotRecording){
            startRecordingButton.enabled = true;
            stopRecordingButton.enabled = false;
            recordingStatusLabel.text = StringConstants.NotRecordingStatus;
        }
        else{
            // Leaving it blank if we have state other than Recording/NotRecording
            // like Pause or Reset etc.
        }
    }
}

