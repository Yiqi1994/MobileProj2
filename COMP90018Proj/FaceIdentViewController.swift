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
        
        let connectionString = "DefaultEndpointsProtocol=https;AccountName=faceimg;AccountKey=vjckPyJ37aWuElE81It17cMOZvy54+1pAXYEQWzmRyCqlqpYEOpST6ZZ1LO1dgtwtjs5P7wV3Bwih3B5q9vUrg==;EndpointSuffix=core.windows.net"
//        let containerURL = "https://faceimg.blob.core.windows.net/faceimgs"
        
        let storageAccount : AZSCloudStorageAccount
        try! storageAccount = AZSCloudStorageAccount(fromConnectionString: connectionString)
        let blobClient = storageAccount.getBlobClient()
        var container : AZSCloudBlobContainer
        container = blobClient.containerReference(fromName: "faceimgs")
        
        let image = UIImage.init(named: "testImage")
        let data = UIImageJPEGRepresentation(image!, 0.5)
        
        let blob = container.blockBlobReference(fromName: "userUploadPhoto")
        blob.upload(from: data!, completionHandler: {(NSError) -> Void in
            NSLog("uploaded")
        })
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
