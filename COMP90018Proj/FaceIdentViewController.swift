//
//  FaceIdentViewController.swift
//  COMP90018Proj Front-End Application
//
//  Created by Kai Zhang, Yiqi Yu, Lisha Qiu
//  Copyright © 2017 Unimelb. All rights reserved.
//

import UIKit
import ESTabBarController_swift
import ImagePicker
import CoreData
import SwiftyButton

class FaceIdentViewController: UIViewController,UITabBarControllerDelegate,
    UITabBarDelegate,ImagePickerDelegate{

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var namefiled: UILabel!
    @IBOutlet weak var crimefiled: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.init(red:244.0/255.0, green: 245.0 / 255.0, blue: 245.0/255,alpha: 1.0)

        // set button target to this view
        button.addTarget(self, action: #selector(buttonTouched(button:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func buttonTouched(button: UIButton) {
        var config = Configuration()
        config.doneButtonTitle = "Done"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.recordLocation = false
        // config.allowVideoSelection = true

        let imagePicker = ImagePickerController()
        imagePicker.configuration = config
        imagePicker.delegate = self
        imagePicker.imageLimit = 1

        present(imagePicker, animated: true, completion: nil)
    }

    // upload photo to azure stroage account for face identification
    func uploadPhoto(image:UIImage) {
        // connection string for azure storage account
        let connectionString = "DefaultEndpointsProtocol=https;AccountName=faceimg;AccountKey=vjckPyJ37aWuElE81It17cMOZvy54+1pAXYEQWzmRyCqlqpYEOpST6ZZ1LO1dgtwtjs5P7wV3Bwih3B5q9vUrg==;EndpointSuffix=core.windows.net"

        // initialize connection resources
        let storageAccount : AZSCloudStorageAccount
        try! storageAccount = AZSCloudStorageAccount(fromConnectionString: connectionString)
        let blobClient = storageAccount.getBlobClient()
        var container : AZSCloudBlobContainer
        container = blobClient.containerReference(fromName: "faceimgs")

        let data = UIImageJPEGRepresentation(image, 0.5)

        let blob = container.blockBlobReference(fromName: "userUploadPhoto")
        blob.upload(from: data!, completionHandler: {(NSError) -> Void in
            NSLog("uploaded")
        })
        self.activityIndicator.startAnimating()
    }

    // send identify request to back-end server
    func identify(){
        // back-end server api
        var request = URLRequest(url: URL(string: "https://facedbidentify.herokuapp.com/api/identify")!)

        // initial request
        request.httpMethod = "GET"

        // send request and process result
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else
            {
                print("error=\(String(describing: error))")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
            {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }

            let responseString = String(data: data, encoding: .utf8)
            var responseStrArray = responseString?.components(separatedBy: ",")

            // response string is person's name and crime detail, connect by ","
            let faceIdentStr: String = responseStrArray![0]
            let crimeInfoStr: String = responseStrArray![1]

            // get criminal's image from Azure Stroage Account
            let imageurl:String = "https://faceimg.blob.core.windows.net/faceimgs/"+faceIdentStr

            // show result in view
            self.namefiled.text = faceIdentStr
            self.crimefiled.text = crimeInfoStr
            let url = NSURL(string: imageurl)!
            let identifiedImage = try!Data(contentsOf: url as URL)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.imageView.image = UIImage(data: identifiedImage)
        }
        task.resume()
    }

    // cancel button actions inside image picker
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
        print("cancel picker")

    }

    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)

          imageView.image = images[0]
          uploadPhoto(image: #imageLiteral(resourceName: "testImage"))
          identify()
    }

}
