//
//  ViewController.swift
//  meme
//
//  Created by Ayush Garg on 17/10/16.
//  Copyright © 2016 Headmaster Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var camButton: UIBarButtonItem!
    @IBOutlet weak var pickButton:UIBarButtonItem!
    @IBOutlet weak var cancelButton:UIBarButtonItem!
    @IBOutlet weak var actionButton:UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
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
        self.present(pickController,animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide) , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if view.frame.origin.y >= 0 && self.bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y <= 0 && self.bottomTextField.isFirstResponder{
            view.frame.origin.y += getKeyboardHeight(notification: notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
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
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
//            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.frame = frameForImage(image: image, imageView: imageView)
            imageView.clipsToBounds = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func frameForImage(image:UIImage, imageView:UIImageView) -> CGRect{
        
        let imageRatio = image.size.width / image.size.height
        let viewRatio = imageView.frame.size.width / imageView.frame.size.height
        
        if(imageRatio < viewRatio)
        {
            let scale = imageView.frame.size.height / image.size.height
            let width = scale * image.size.width
            let topLeftX = (imageView.frame.size.width - width) * 0.5
            return CGRect(x: topLeftX,y: 0, width: width, height: imageView.frame.size.height);
        }else{
            let scale = imageView.frame.size.width / image.size.width;
            
            let height = scale * image.size.height;
            
            let topLeftY = (imageView.frame.size.height - height) * 0.5;
            
            return CGRect(x: 0, y: topLeftY, width: imageView.frame.size.width, height: height);
        }
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

    func saveMeme() {
        //Create the meme
        let memedImage = generateMemedImage()
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imageView.image!, memedImage: memedImage)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        topTextField.text = "TOP"
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .center
        topTextField.delegate = self
        bottomTextField.text = "BOTTOM"
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = .center
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        camButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
}
