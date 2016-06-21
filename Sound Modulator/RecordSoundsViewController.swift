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
    struct StringConstants {
        static let RecordingStatus = "Tap to stop Recording >>";
        static let NotRecordingStatus = "<< Tap to Record";
        static let PlayRecordingSegueIdentifier = "playRecording";
    }
    
    //MARK:- LifeCycle Events
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUpControlsForState(RecordingState.NotRecording);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- IBActions
    @IBAction func startRecording(sender: AnyObject) {
        setUpControlsForState(RecordingState.Recording);
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self;
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
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
        if(segue.identifier == StringConstants.PlayRecordingSegueIdentifier){
            let playSoundsVC = segue.destinationViewController as! PlaySoundsViewController;
            let recordingURL = sender as! NSURL;
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
            // Leaving it blank if we have state other Recording/NotRecording
            // like Pause or Reset etc.
        }
    }
}

