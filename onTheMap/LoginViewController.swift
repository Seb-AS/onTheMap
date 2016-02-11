//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Sebas on 1/10/16.
//  Copyright © 2016 Sebas. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, ShowsAlert {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    @IBOutlet weak var loginWithFacebookButton: FBSDKLoginButton!
    @IBOutlet weak var loginWithFacebookContainer: UIView!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Configure tap recognizer */
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        loginWithFacebookButton.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            print("User logged in...")
            goToNextView()
        } else {
            print("User not logged in...")
        }
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            onFailedLogin(error)
        }
        else if result.isCancelled {
            showAlert(message: "Facebook login cancelled.")
        }
        else {
             loginWithFacebookButton.hidden = true
             loginWithFacebookContainer.hidden = true
             goToNextView()
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out...")
    }
    
    override func viewWillAppear(animated: Bool) {
        addKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardDismissRecognizer()
        unsubscribeToKeyboardNotifications()
    }
    
    //Login actions
    @IBAction func loginAction(sender: UIButton) {
        
        if emailField.text!.isEmpty {
            presentFailureMessage("Please enter your username.")
            return
        }
        if passwordField.text!.isEmpty {
            presentFailureMessage("Please enter your password.")
            return
        }
        
        showActivityIndicator()
        //hide keyboard
        view.endEditing(true)
        
        //request to login user
        UdacityClient.sharedInstance().userLogin(emailField.text!, password: passwordField.text!) { (result, error) -> Void in
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                    self.hideActivityIndicator()
                })
            }
            else {
                // show map tab view
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.studentKey = result!
                dispatch_async(dispatch_get_main_queue(), {
                    UdacityClient.sharedInstance().getStudentLocations { users, error in
                        if error != nil {
                            self.presentFailure(error!)
                            self.hideActivityIndicator()
                        }
                        else {
                            self.goToNextView()
                        }
                    }
                })
            }
        }
    }

    func onFailedLogin(error: NSError) {
        presentFailure(error)
    }
    
    func presentFailure(error: NSError) {
        var message = "Sorry, we couldn't log you in. Please check your credentials and try again."
        
        if error.domain == NSURLErrorDomain {
            message = "Sorry, we seem to be having trouble connecting to the login server."
        } else {
            let httpResponse = error.userInfo["httpResponse"] as? NSHTTPURLResponse
            if httpResponse != nil {
                if [400, 403].contains(httpResponse!.statusCode) {
                    message = "Sorry, that account was not found or your credentials are invalid."
                }
            }
        }
        presentFailureMessage(message)
    }
    
    func presentFailureMessage(message:String) {
        showAlert(message: message);
    }

    //Open signup url
    @IBAction func signupAction(sender: UIButton) {
        // set url
        let signUpURL = "https://www.udacity.com/account/auth#!/signup"
        // open url in browser
        UIApplication.sharedApplication().openURL(NSURL(string: signUpURL)!)
    }
    
    //go to next view
    func goToNextView() {
        let tabBarController:UITabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
        self.presentViewController(tabBarController, animated: true, completion: hideActivityIndicator)
    }
    
    func goToHomeView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    //Activity indicator
    func showActivityIndicator() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        loginButton.hidden = true
        loginWithFacebookButton.hidden = true
        loginWithFacebookContainer.hidden = true
    }
    
    func hideActivityIndicator() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        loginButton.hidden = false
        loginWithFacebookButton.hidden = false
        loginWithFacebookContainer.hidden = false
        emailField.text = ""
        passwordField.text = ""
    }
    
    //Keyboard Fixes
    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardAdjusted == true {
            view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}

