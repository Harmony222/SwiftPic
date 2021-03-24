//
//  ProfileViewController.swift
//  SwiftPic
//
//  Created by Harmony Scarlet on 3/23/21.
//

import UIKit
import Parse
import RSKImageCropper

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate {
     
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var picker : UIImagePickerController!
    var image : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUserInfo()
    }
    
    func setUserInfo() {
        let user = PFUser.current()!
        userNameLabel.text = user.username
        
        if let profileImageFile = (user["image"] as? PFFileObject) {
//        if profileImageFile != nil {
            let urlString = profileImageFile.url!
            let url = URL(string: urlString)!
            profileImageView.af.setImage(withURL: url)
        } else {
            profileImageView.image = UIImage(named: "user")
        }
        profileImageView.layer.masksToBounds = true
        let radius = profileImageView.frame.height/2
        profileImageView.layer.cornerRadius = radius
    }
    
    @IBAction func onSetProfileImageButton(_ sender: Any) {
        self.picker = UIImagePickerController()
        self.picker.delegate = self
        self.picker.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.picker.sourceType = .camera
        } else {
            self.picker.sourceType = .photoLibrary
        }
        
        present(self.picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // present circular image picker
        // https://github.com/Sushobhitbuiltbyblank/RSKImageCropper-use-in-Swift-project/tree/master/RSkImageSwift
        // https://stackoverflow.com/questions/32196861/add-a-circular-cropping-component-for-uiimagepicker
        self.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.picker.dismiss(animated: false, completion: {})
        let imageCropVC = RSKImageCropViewController.init(image: self.image, cropMode: RSKImageCropMode.circle)
        imageCropVC.delegate = self
        self.present(imageCropVC, animated: true, completion: nil)
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        // once image is selected and cropped, scale image and save to user profile
        let size = CGSize(width: 130, height: 130)
        let scaledImage = croppedImage.af.imageAspectScaled(toFill: size)
        let user = PFUser.current()!
        let imageData = scaledImage.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
    
        user["image"] = file
        user.saveInBackground { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            } else {
                print("error")
            }
        }
        
        // set profile imageView to new image
        profileImageView.image = scaledImage
        
//        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        // https://stackoverflow.com/questions/56588843/uiapplication-shared-delegate-equivalent-for-scenedelegate-xcode11
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginViewController
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
