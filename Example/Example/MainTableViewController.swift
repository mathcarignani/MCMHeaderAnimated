
//
//  MainTableViewController.swift
//  Example
//
//  Created by Mathias Carignani on 5/19/15.
//  Copyright (c) 2015 Mathias Carignani. All rights reserved.
//

import UIKit
import MCMHeaderAnimated

class MainTableViewController: UITableViewController {
    
    private let transitionManager = MCMHeaderAnimated()
    
    var elements: NSArray! = []
    var lastSelected: IndexPath! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.elements = [UIColor(red: 25/255.0, green: 181/255.0, blue: 254/255.0, alpha: 1.0), UIColor(red: 54/255.0, green: 215/255.0, blue: 183/255.0, alpha: 1.0), UIColor(red: 210/255.0, green: 77/255.0, blue: 87/255.0, alpha: 1.0), UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)]
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath as IndexPath) as! MainTableViewCell
        
        cell.background.layer.cornerRadius = 10;
        cell.background.clipsToBounds = true
        cell.header.backgroundColor = self.elements.object(at: indexPath.row) as? UIColor

        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180.0
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewDetail" {
            self.lastSelected = (self.tableView.indexPathForSelectedRow as NSIndexPath!) as IndexPath!
            let element = self.elements.object(at: self.tableView.indexPathForSelectedRow!.row)
            
            let destination = segue.destination as! DetailViewController
            destination.color = element as! UIColor
            destination.transitioningDelegate = self.transitionManager
            
            self.transitionManager.destinationViewController = destination
        }
    }
}

extension MainTableViewController: MCMHeaderAnimatedDelegate {
    
    func headerView() -> UIView {
        // Selected cell
        let cell = self.tableView.cellForRow(at: self.lastSelected) as! MainTableViewCell
        return cell.header
    }
    
    func headerCopy(_ subview: UIView) -> UIView {
        let cell = tableView.cellForRow(at: self.lastSelected) as! MainTableViewCell
        let header = UIView(frame: cell.header.frame)
        header.backgroundColor = self.elements.object(at: self.lastSelected.row) as? UIColor
        
        return header
    }
}
