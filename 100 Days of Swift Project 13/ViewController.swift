//
//  ViewController.swift
//  100 Days of Swift Project 13
//
//  Created by Seb Vidal on 15/12/2021.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    @IBOutlet var radius: UISlider!
    @IBOutlet var scale: UISlider!
    @IBOutlet var changeFilter: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCoreImage()
    }
    
    func setupNavBar() {
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
    }
    
    func setupCoreImage() {
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    @objc func importPicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        dismiss(animated: true)
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(radius.value * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(scale.value * 10, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey) { currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey) }
        
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            self.imageView.image = processedImage
        }
    }
    
    @IBAction func changeFilter(_ sender: Any) {
        let alertController = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
        present(alertController, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        guard let actionTitle = action.title else {
            return
        }
        
        changeFilter.titleLabel?.text = actionTitle
        
        guard currentImage != nil else {
            return
        }

        currentFilter = CIFilter(name: actionTitle)
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    @IBAction func save(_ sender: Any) {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            let alertController = UIAlertController(title: "Save Failed", message: "There was no image selected to save.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alertController, animated: true)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alertController = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
        } else {
            let alertController = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
        }
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func radiusChanged(_ sender: Any) {
        applyProcessing()
    }
    
    @IBAction func scaleChanged(_ sender: Any) {
        applyProcessing()
    }
    
}

