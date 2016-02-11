//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Sebas on 1/10/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    @IBOutlet weak var mainTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "addPinAction")
        let refreshButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadAction")
      
        // add the buttons
        navigationItem.rightBarButtonItems = [refreshButton, pinButton]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Done, target: self, action: "logout")
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadUsersData()
    }
    
    //action - add location for current user
    func addPinAction() {
        let postController:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("postView") 
        presentViewController(postController, animated: true, completion: nil)
    }
    
    //action - reload users location
    func reloadAction() {
        reloadUsersData()
    }
    
    //reload users data
    func reloadUsersData() {
        UdacityClient.sharedInstance().getStudentLocations { users, error in
            if let usersData =  users {
                dispatch_async(dispatch_get_main_queue(), {
                   StudentData.sharedInstance().userData = usersData
                    self.mainTable.reloadData()
                })
            } else {
                if error != nil {
                    UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                }
            }
        }
    }
    
    //tableView functions
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserData", forIndexPath: indexPath) 
        
        // set cell data
        let firstName = StudentData.sharedInstance().userData[indexPath.row].firstName
        let lastName = StudentData.sharedInstance().userData[indexPath.row].lastName
        
        cell.textLabel?.text = "\(firstName) \(lastName)"
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    // open url in safari when click
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UdacityClient.sharedInstance().openURL(StudentData.sharedInstance().userData[indexPath.row].mediaURL)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentData.sharedInstance().userData.count
    }
    
    // logout
    func logout() {
        UdacityClient.sharedInstance().logout(self)
    }
}
