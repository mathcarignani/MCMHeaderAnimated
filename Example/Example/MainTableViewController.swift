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
    
    private var elements: NSArray! = []
    private var lastSelected: NSIndexPath! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.elements = [
            ["color": UIColor(red: 25/255.0, green: 181/255.0, blue: 254/255.0, alpha: 1.0)],
            ["color": UIColor(red: 54/255.0, green: 215/255.0, blue: 183/255.0, alpha: 1.0)],
            ["color": UIColor(red: 210/255.0, green: 77/255.0, blue: 87/255.0, alpha: 1.0)],
            ["color": UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)]
        ]
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elements.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mainCell", forIndexPath: indexPath) as! MainTableViewCell
        
        cell.background.layer.cornerRadius = 10;
        cell.background.clipsToBounds = true
        cell.header.backgroundColor = self.elements.objectAtIndex(indexPath.row).objectForKey("color") as? UIColor
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180.0
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "viewDetail" {
            self.lastSelected = self.tableView.indexPathForSelectedRow
            let element = self.elements.objectAtIndex(self.tableView.indexPathForSelectedRow!.row)
            
            let destination = segue.destinationViewController as! DetailViewController
            destination.element = element as! NSDictionary
            destination.transitioningDelegate = self.transitionManager
            
            self.transitionManager.destinationViewController = destination
        }
    }
    
}

extension MainTableViewController: MCMHeaderAnimatedDelegate {
    
    func headerView() -> UIView {
        // Selected cell
        let cell = self.tableView.cellForRowAtIndexPath(self.lastSelected) as! MainTableViewCell
        return cell.header
    }
    
    func headerCopy(subview: UIView) -> UIView {
        let cell = tableView.cellForRowAtIndexPath(self.lastSelected) as! MainTableViewCell
        let header = UIView(frame: cell.header.frame)
        header.backgroundColor = self.elements.objectAtIndex(self.lastSelected.row).objectForKey("color") as? UIColor
        return header
    }
    
}
