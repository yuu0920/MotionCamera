//
//  MotionViewController.swift
//  MotionCamera
//
//  Created by Yuu Tanimura on 2018/04/16.
//  Copyright © 2018年 Yuu Tanimura. All rights reserved.
//

import UIKit

class MotionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var movieURL: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let opencv = OpenCVDiff()
        let arr:[UIImage] = opencv.diff(movieURL as URL!)
        imageView.image = UIImage.animatedImage(with: arr, duration: TimeInterval(1))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
