//
//  ViewController.swift
//  AttendanceLog
//
//  Created by Luke Madronal on 11/12/15.
//  Copyright © 2015 Luke Madronal. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class ViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate  {
    //@IBOutlet var loginButton :UIBarButtonItem!
    
    //MARK: - User Default Methods
    func setUsernameDefault(username: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(username, forKey: "DefaultUsername")
        userDefaults.synchronize()
    }
    
    func getUserNameDefault() ->String {
        if let defaultUserName = NSUserDefaults.standardUserDefaults().stringForKey("DefaultUsername") {
            return defaultUserName
        } else {
            return ""
        }
    }
    
    
    //MARK: - Interactivity Methods
    //    @IBAction func addRecord(sender: UIBarButtonItem) {
    //        if let uCurrentUser = PFUser.currentUser() {
    //            let checkedIn = PFObject(className: "ToDo")
    //            checkedIn.ACL = PFACL(user: uCurrentUser)
    //            checkedIn["toDoDesc"] = toDoTextField.text
    //            checkedIn.saveInBackgroundWithBlock({ (success,error) -> Void in
    //                if success {
    //                    let alert = UIAlertController(title: "Saved", message: "Your to do was saved!", preferredStyle: .Alert)
    //                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
    //                    self.presentViewController(alert, animated: true, completion: nil)
    //                } else {
    //                    let alert = UIAlertController(title: "NOT Saved", message: "Your to do was NOT saved!", preferredStyle: .Alert)
    //                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
    //                    self.presentViewController(alert, animated: true, completion: nil)
    //                }
    //            })
    //        } else {
    //            let alert = UIAlertController(title: "No User", message: "You are not logged in! Go log in first!", preferredStyle: .Alert)
    //            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
    //            self.presentViewController(alert, animated: true, completion: nil)
    //        }
    //    }
    
    //MARK: - Login Methods
    
    //    @IBAction func loginButtonPressed(sender: UIBarButtonItem) {
    //        if let _ = PFUser.currentUser() {
    //            PFUser.logOut()
    //            loginButton.title = "Log In"
    //        } else {
    //            //this needs to be fixed
    //
    //            let loginController = PFLogInViewController()
    //            loginController.delegate = self
    //            let signupController = PFSignUpViewController()
    //            signupController.delegate = self
    //            loginController.signUpController = signupController
    //            loginController.logInView?.usernameField?.text = getUserNameDefault()
    //            presentViewController(loginController, animated: true, completion: nil)
    //
    //        }
    //    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
        setUsernameDefault(logInController.logInView!.usernameField!.text!)
        //loginButton.title = "Log Out"
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Parse Date Recieved Methods
    
    func newDataRecieved(currentUser: PFUser, inOut: String) {
        let checkedIn = PFObject(className: "checkedIn")
        checkedIn.ACL = PFACL(user: currentUser)
        checkedIn["userStatus"] = currentUser.username!+inOut
        checkedIn.saveInBackgroundWithBlock({ (success,error) -> Void in
            if success {
                let alert = UIAlertController(title: "Checked \(inOut)!", message: "You're \(inOut)! Have a great day", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    //    func checkInOut(currentUser: PFUser) {
    //        let checkedIn = PFObject(className: "checkedIn")
    //        checkedIn.ACL = PFACL(user: currentUser)
    //        checkedIn["userStatus"] = currentUser.username!+inOut
    //        checkedIn.saveInBackgroundWithBlock({ (success,error) -> Void in
    //            if success {
    //                let alert = UIAlertController(title: "Checked Out!", message: "You're in! Have a great day", preferredStyle: .Alert)
    //                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
    //                self.presentViewController(alert, animated: true, completion: nil)
    //            }
    //        })
    //    }
    
    func fetchCurrentlySignedInUser() {
        if let uCurrentUser = PFUser.currentUser() {
            let query = PFQuery(className:"checkedIn")
            query.addDescendingOrder("createdAt")
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    
                    if (objects!.count == 0) {
                        self.newDataRecieved(uCurrentUser, inOut: "In")
                    } else if let uObjects = objects {
                        print("userIn is \(String(uObjects[0]["userStatus"]))")
                        if (String(uObjects[0]["userStatus"]) == uCurrentUser.username!+"Out") {
                            print("signing in")
                            self.newDataRecieved(uCurrentUser,inOut: "In")
                        } else {
                            let alert = UIAlertController(title: "Status Found", message: "You are currently checked in, would you like to check out?", preferredStyle: .Alert)
                            
                            alert.addAction(UIAlertAction(title: "Check Out", style: .Default, handler: { (action) -> Void in
                                print("signing in and then out")
                                self.newDataRecieved(uCurrentUser,inOut: "Out")
                            }))
                            
                            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    } else {
                        print("got into nothing in the array")
                    }
                } else {
                    // Log details of the failure
                    //print("Error: \(error!) \(error!.userInfo!)")
                }
            }
        } else {
            let alert = UIAlertController(title: "No User", message: "You are not logged in! Go log in first!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func fetchCurrentlySignedOutUser() {
        if let uCurrentUser = PFUser.currentUser() {
            let query = PFQuery(className:"checkedIn")
            query.addDescendingOrder("createdAt")
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    
                    if let uObjects = objects {
                        print("userStatus is \(String(uObjects[0]["userStatus"]))")
                        if (String(uObjects[0]["userStatus"]) == uCurrentUser.username!+"In") {
                            print("signing in")
                            self.newDataRecieved(uCurrentUser,inOut: "Out")
                        } else {
                            let alert = UIAlertController(title: "Status Found", message: "You already checked out! Have a great day!", preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    } else {
                        print("got into nothing in the array")
                    }
                } else {
                    // Log details of the failure
                    //print("Error: \(error!) \(error!.userInfo!)")
                }
            }
        } else {
            let alert = UIAlertController(title: "No User", message: "You are not logged in! Go log in first!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        PFUser.logOut()
        if let _ = PFUser.currentUser() {
            PFUser.logOut()
            //loginButton.title = "Log In"
        } else {
            //this needs to be fixed
            
            let loginController = PFLogInViewController()
            loginController.delegate = self
            let signupController = PFSignUpViewController()
            signupController.delegate = self
            loginController.signUpController = signupController
            loginController.logInView?.usernameField?.text = getUserNameDefault()
            presentViewController(loginController, animated: true, completion: nil)
            
        }
        //loginButton.title = "LogIn"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchCurrentlySignedOutUser", name: "recievedDataFromMint", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchCurrentlySignedInUser", name: "recievedDataFromBlue", object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

