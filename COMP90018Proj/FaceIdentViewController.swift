//
//  FaceIdentViewController.swift
//  COMP90018Proj
//
//  Created by Kai Zhang on 28/9/17.
//  Copyright © 2017 Unimelb. All rights reserved.
//

import UIKit

class FaceIdentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use test image here
        uploadPhoto(image: #imageLiteral(resourceName: "testImage"))
        
        // Inform server the file is uploaded using a http GET request
        identify()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadPhoto(image:UIImage) {
        let connectionString = "DefaultEndpointsProtocol=https;AccountName=faceimg;AccountKey=vjckPyJ37aWuElE81It17cMOZvy54+1pAXYEQWzmRyCqlqpYEOpST6ZZ1LO1dgtwtjs5P7wV3Bwih3B5q9vUrg==;EndpointSuffix=core.windows.net"
        //        let containerURL = "https://faceimg.blob.core.windows.net/faceimgs"
        
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
    }
    
    func identify(){
        var request = URLRequest(url: URL(string: "https://facedbidentify.herokuapp.com/api/identify")!)
        
        request.httpMethod = "GET"
        
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
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }

}
