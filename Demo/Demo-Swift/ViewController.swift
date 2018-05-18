//
//  ViewController.swift
//  Demo
//
//  Created by Klaus on 2018/5/18.
//  Copyright © 2018年 KlausLiu. All rights reserved.
//

import UIKit
import Toast

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toast(_ sender: Any) {
        Toast.show("To be, or not to be: that is the question.To be, or not to be: that is the question.To be, or not to be: that is the question.")
    }
    
    @IBAction func countinuous(_ sender: Any) {
        Toast.show("第一个toast")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Toast.show("第二个toast")
        }
    }
    
}

