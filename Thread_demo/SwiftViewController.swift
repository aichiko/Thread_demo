//
//  SwiftViewController.swift
//  Thread_demo
//
//  Created by 24hmb on 2016/11/21.
//  Copyright © 2016年 24hmb. All rights reserved.
//

import UIKit

class SwiftViewController: UIViewController {
    
    lazy var imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 300))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.orange;
        
        self.view.addSubview(self.imageView)
        self.imageView.center = self.view.center
        
        //Thread 的类方法和实例方法开辟线程，用法跟属性跟OC类似
        
        Thread.detachNewThreadSelector(#selector(threadMethods), toTarget: self, with: nil)
        
        Thread.detachNewThread { 
            
        }
        
        _ = Thread.init {
            
        }
        
        _ = Thread.init(target: self, selector: #selector(threadMethods), object: nil)
    }

    func threadMethods() {
        
        let url = URL.init(string: "http://imgsrc.baidu.com/forum/w%3D580/sign=07bcb87477f082022d9291377bfafb8a/2da7adec54e736d185d9d05f9f504fc2d76269cd.jpg")
        
        Thread.sleep(forTimeInterval: 3)
        
        do {
            let data = try Data.init(contentsOf: url!)
            self.performSelector(onMainThread: #selector(updateImageView(_:)), with: data, waitUntilDone: true)
        } catch {
            debugPrint(error)
        }
    }
    
    func updateImageView(_ data: Data) {
        //更新image
        let image = UIImage.init(data: data)
        self.imageView.image = image;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
