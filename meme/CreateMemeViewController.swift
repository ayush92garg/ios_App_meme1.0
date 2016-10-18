//
//  ViewController.swift
//  meme
//
//  Created by Ayush Garg on 17/10/16.
//  Copyright © 2016 Headmaster Technologies. All rights reserved.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var camButton: UIBarButtonItem!
    @IBOutlet weak var pickButton:UIBarButtonItem!
    @IBOutlet weak var cancelButton:UIBarButtonItem!
    @IBOutlet weak var actionButton:UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomContraintUiView: NSLayoutConstraint!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 32)!,
        NSStrokeWidthAttributeName : -3.0
        ] as [String : Any]
    
    @IBAction func camButtonClicked(_ sender: AnyObject) {
        pickImage(fromSource: UIImagePickerControllerSourceType.camera)
    }
    
    @IBAction func pickButtonClicked(_ sender: AnyObject) {
        pickImage(fromSource: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    
    @IBAction func cancelButtonClicked(_ sender: AnyObject) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imageView.image = nil
    }
    
    @IBAction func actionButtonClicked(_ sender: AnyObject) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, success, items, error in
            self.saveMeme()
            self.dismiss(animated: true, completion: nil)
        }
        present(activityController, animated: true, completion: nil)
    }
    
    func pickImage(fromSource: UIImagePickerControllerSourceType){
        let pickController = UIImagePickerController()
        pickController.delegate = self
        pickController.sourceType = fromSource
        pickController.allowsEditing = true
        self.present(pickController,animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillShow) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateMemeViewController.keyboardWillHide) , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y = getKeyboardHeight(notification: notification) * (-1)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        if bottomTextField.isFirstResponder {
            return keyboardSize.cgRectValue.height
        } else {
            return 0
        }
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:
            NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == topTextField && textField.text! == "TOP") || (textField == bottomTextField && textField.text! == "BOTTOM"){
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        bottomToolBar.isHidden = true
        topToolBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        bottomToolBar.isHidden = false
        topToolBar.isHidden = false
        
        return memedImage
    }
    
    func setLayoutBasedOnOrientation(){
        if UIDevice.current.orientation.isLandscape {
            bottomContraintUiView.constant = 45
            imageView.frame = CGRect(x: 0,y:0, width:100, height:100)
        }else{
            bottomContraintUiView.constant = 162
            imageView.frame = CGRect(x: 0,y:0, width:343, height:343)
        }
    }

    func saveMeme() {
        //Create the meme
        let memedImage = generateMemedImage()
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView.image!, memedImage: memedImage)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func setupInitialLayoutForTextFields(textField: UITextField, defaultText: String){
        textField.text = defaultText
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupInitialLayoutForTextFields(textField: topTextField, defaultText: "TOP")
        setupInitialLayoutForTextFields(textField: bottomTextField, defaultText: "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLayoutBasedOnOrientation()
        camButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setLayoutBasedOnOrientation()
    }
}
