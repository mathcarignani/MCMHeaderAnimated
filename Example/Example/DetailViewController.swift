//
//  DetailViewController.swift
//  Example
//
//  Created by Mathias Carignani on 5/19/15.
//  Copyright (c) 2015 Mathias Carignani. All rights reserved.
//

import UIKit
import MCMHeaderAnimated

class DetailViewController: UIViewController {
    
    var element: NSDictionary! = nil
    
    @IBOutlet weak var header: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        header.backgroundColor = self.element.objectForKey("color") as! UIColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension DetailViewController: MCMHeaderAnimatedDelegate {
    
    func headerView() -> UIView {
        // Selected cell
        return self.header
    }
    
    func headerCopy(subview: UIView) -> UIView {
        var headerN = UIView()
        headerN.backgroundColor = self.element.objectForKey("color") as! UIColor
        return headerN
    }
    
}
