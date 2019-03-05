//
//  SignUpViewController.swift
//  Music-room
//
//  Created by raphael ghirelli on 1/25/19.
//  Copyright © 2019 raphael ghirelli. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import GoogleSignIn

class SignUpViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var stackViewContainer: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var stackViewContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var LoginRegisterSegment: UISegmentedControl!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: UIButton!
    
    var spinner: UIView?
    var isKeyboardActive = false
    var keyboardHeight: CGFloat?
    var textFieldArray: [UITextField]?
    var originY: CGFloat?
   
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.parallaxMode = .alwaysOff
        return hud
    }()
    
    @IBAction func handleLoginRegisterSegment(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        UIView.animate(withDuration: 0.20) {
            self.navigationController?.navigationBar.topItem?.title = sender.selectedSegmentIndex == 0 ? "Login" : "Register"
            let buttonTitle = sender.selectedSegmentIndex == 0 ? "Login" : "Register"
            self.registerButton.setTitle(buttonTitle, for: .normal)
            self.userNameTextField.isHidden = sender.selectedSegmentIndex == 0 ? true : false
            let newMultiplier:CGFloat =  sender.selectedSegmentIndex == 0 ? 0.33 / 2 : 0.3
            self.stackViewContainerHeight = self.stackViewContainerHeight.setMultiplier(multiplier: newMultiplier)
        }
        if (self.isKeyboardActive) {
            self.moveView()
        }
    }
    
    
    @IBAction func fbLogin(_ sender: UIButton) {
        hud.textLabel.text = "Signing in with Facebook..."
        hud.show(in: view)
        FacebookManager.signInWithFacebook(in: self) { (message, error, facebookUser) in
            if let err = error {
                Helpers.dismissHud(self.hud, text: "Error", detailText: "\(message) \(err.localizedDescription)", delay: 3)
                return
            }
            guard let facebookUser = facebookUser else {
                Helpers.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user", delay: 3)
                return
            }
            
            print("Successfully signed in with Facebook with Spark User: \(facebookUser)")
            Helpers.dismissHud(self.hud, text: "Success", detailText: "Successfully signed in with Facebook", delay: 3)
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.toUserHomeController()
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (data, err) in
            if err != nil {
                print(err!)
                let alert = Alert.errorAlert(title: "Couln't connect", message: err?.localizedDescription)
                self.present(alert, animated: true)
            } else {
                if !((data?.user.isEmailVerified)!) {
                    let alert = Alert.errorAlert(title: "Email needs to be verified", message: "Check your inbox or resend an email", cancelButton: true, completion: {
                        data?.user.sendEmailVerification(completion: { (err) in
                            var message, title: String?
                            if err != nil {
                                message = "Couldn't send email verification"
                                title = "Email verification"
                            } else {
                                title = "Email sent"
                                message = "Email has been succesfully sent"
                            }
                            let alert = Alert.errorAlert(title: title!, message: message!)
                            self.present(alert, animated: true)
                        })
                    })
                    self.present(alert, animated: true)
                } else {
                    Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (str, err) in
                        print(str)
                    })
                     self.toUserHomeController()
                    
                }
            }
            UIViewController.removeSpinner(spinner: self.spinner!)
        }
        
    }
    
    
    func register() {
        if !(isValidEmail(emailTextField.text!)) {
            let emailAlert =  Alert.errorAlert(title: "Invalid Email", message: "Email is invalid, please enter a valid email address")
            present(emailAlert, animated: true)
            UIViewController.removeSpinner(spinner: spinner!)
            return
        }
        let user = User(email: emailTextField.text!, password: passwordTextField.text!, displayName: userNameTextField.text!)
        FirebaseManager.createUser(user: user) { (data, response, err) in
            if err != nil {
                print("err ----> ", err)
                UIViewController.removeSpinner(spinner: self.spinner!)
            }
            else if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                let result = jsonHelper.convertJSONToObject(data: data)
                if let _ = result {
                    print("setting err")
                    let errorAlert = Alert.errorAlert(title: "Can't create user", message: (result!["message"] as! String))
                    DispatchQueue.main.async {
                        self.present(errorAlert, animated: true)
                    }
                    UIViewController.removeSpinner(spinner: self.spinner!)
                }
            }
            else {
                Auth.auth().signIn(withEmail: user.email, password: user.password, completion: { (data, err) in
                    if err == nil {
                        data?.user.sendEmailVerification(completion: { (err) in
                            let emailSent = Alert.errorAlert(title: "User created", message: "Email confirmation has been sent", cancelButton: false, completion: {
                                self.LoginRegisterSegment.selectedSegmentIndex = 0
                                self.handleLoginRegisterSegment(self.LoginRegisterSegment)
                            })
                            DispatchQueue.main.async {
                                self.present(emailSent, animated: true)
                            }
                            UIViewController.removeSpinner(spinner: self.spinner!)
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any?) {
        spinner = UIViewController.displaySpinner(onView: self.view)
        if LoginRegisterSegment.selectedSegmentIndex == 0 {
            login()
        } else {
            register()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            toUserHomeController()
        }
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        originY = view.frame.origin.y
        textFieldArray = [userNameTextField, passwordTextField, emailTextField]
        setUpLayers()
        setTextFieldPadding()
        userNameTextField.isHidden = true
        let newMultiplier:CGFloat =  0.33 / 2
        stackViewContainerHeight = stackViewContainerHeight.setMultiplier(multiplier: newMultiplier)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        navigationController?.navigationBar.topItem?.title = "Login"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        userNameTextField.text = ""
        passwordTextField.text = ""
        emailTextField.text = ""
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        print("Will show")
        isKeyboardActive = true
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            moveView()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Will Hide")
        isKeyboardActive = false
        moveView()
    }
    
    private func moveView() {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        if (isKeyboardActive) {
            view.frame.origin.y = originY! - (keyboardHeight! - (screenHeight - registerButton.frame.maxY) + 10)
        } else {
            view.frame.origin.y = originY!
        }
    }
    
    func setTextFieldPadding() {
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        textFieldArray?.forEach({ (textField) in
            textField.setLeftPaddingPoints(5)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            signUp(nil)
        }
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setUpLayers() {
        stackViewContainer.layer.cornerRadius = 5
        registerButton.layer.cornerRadius = 5
        facebookLoginButton.layer.cornerRadius = 5
        googleLoginButton.layer.cornerRadius = 5
        let fbLogo = UIImage(named: "fbWhiteLogo")
        let googleLogo = UIImage(named: "btn_google_light_normal_ios")
        googleLoginButton.tintColor = .clear
        googleLoginButton.layer.masksToBounds = true
        googleLoginButton.setImage(googleLogo, for: .normal)
        googleLoginButton.imageView?.contentMode = .scaleAspectFit
        googleLoginButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: -30 , bottom: 2, right: 0)
        googleLoginButton.layer.masksToBounds = true
        facebookLoginButton.setImage(fbLogo, for: .normal)
        facebookLoginButton.imageView?.contentMode = .scaleAspectFit
        facebookLoginButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: -20 , bottom: 5, right: 0)
        facebookLoginButton.layer.masksToBounds = true
    }
    
    func isValidEmail(_ testStr : String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    private func toUserHomeController() {
        let vc = TabBarController()
        present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: -
    //MARK: Google Register/Signin Handlers
    @IBAction func googleSignIn(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                return
            }
            self.checkIfGoogleDataExist(completion: { (exist) in
                if !exist {
                    let registerData = RegisterData(accessibility: Accessibility(permission: false, friends: false), displayName: user.profile.name, friends: [String](), is_linked_to_deezer: false, is_linked_to_facebook: false, is_linked_to_google: false, pref_music: [String]())
                    FirebaseManager.Firestore_Users_Collection.document(Auth.auth().currentUser!.uid).setData(registerData.dictionary, completion: { (err) in
                        if let err = err { print(err); return }
                    })
                }
                DispatchQueue.main.async {
                    self.toUserHomeController()
                }
            })
        }
    }
    
    private func checkIfGoogleDataExist(completion: @escaping (Bool) -> ()) {
        let docRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (snapshot, err) in
            if snapshot?.data() == nil {
                completion(false)
                return
            }
            completion(true)
        }
    }
    

    
}
