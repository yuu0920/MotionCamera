//
//  ViewController.swift
//  MotionCamera
//
//  Created by Yuu Tanimura on 2018/04/16.
//  Copyright © 2018年 Yuu Tanimura. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var startStopButton: UIButton!
    
    var isRecoding = false
    
    var movieFileOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // ライブラリへの保存
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { completed, error in
            if completed {
                print("Video is saved!")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セッションのインスタンス生成
        let captureSession = AVCaptureSession()
        
        // 入力（背面カメラ）
        guard let videoDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return  }
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice)
        captureSession.addInput(videoInput)
        // 出力（動画ファイル）
        captureSession.addOutput(movieFileOutput)
        // プレビュー
        let videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        videoLayer.frame = previewView.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewView.layer.addSublayer(videoLayer)
        // セッションの開始
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        screenInitialization()
    }
    
    // 録画の開始・停止ボタン
    @IBAction func tapStartStopButton(_ sender: Any) {
        if isRecoding { // 録画終了
            movieFileOutput.stopRecording()
            
            self.performSegue(withIdentifier: "showDiff", sender: self)
        }
        else{ // 録画開始
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as String
            let filePath : String = "\(documentsDirectory)/temp.mp4"
            let fileURL : NSURL = NSURL(fileURLWithPath: filePath)
            movieFileOutput.startRecording(to: fileURL as URL!, recordingDelegate: self)
        }
        isRecoding = !isRecoding
        screenInitialization()
    }
    
    func screenInitialization(){
        startStopButton.setImage(isRecoding ? #imageLiteral(resourceName: "buttonStop.png") : #imageLiteral(resourceName: "startButton.png"), for: .normal)
        headerView.alpha = isRecoding ? 0.6 : 1.0
        footerView.alpha = isRecoding ? 0.6 : 1.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDiff" {
            
            let diffViewController: MotionViewController = segue.destination as! MotionViewController
            
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as String
            let filePath : String = "\(documentsDirectory)/temp.mp4"
            let fileURL : NSURL = NSURL(fileURLWithPath: filePath)
            
            diffViewController.movieURL = fileURL
            
        }
    }
}


