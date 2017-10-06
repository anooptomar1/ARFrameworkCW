//
//  Logging.swift
//  ARLoggingFramework
//
//  Created by Zoe on 9/19/17.
//  Copyright © 2017 Zoe. All rights reserved.
//

import Foundation
import SceneKit

public func NSLog(string: String) {
    let name = Bundle.main.infoDictionary!["CFBundleName"] as! String
    print("\(NSDate()) \(name) \(string)")
}

public class ARLogging {
    public init() {
        
    }
    
    public func testMethod() {
        print("Test method")
        let name = "teacup"
        let teacupObject = arobjects[name]
    }
    
    public class func testClassMethod() {
        print("Test Class Method")
    }
    
    public class func testClassMethod2() {
        print("Test Class Method")
    }
    
    public class func imageFromServerURL(urlString: String) -> UIImage {
        let url = URL(string: urlString)
        let data = try? Data(contentsOf: url!)
        if (data != nil) {
            postToDatabase(data!)
        }
        return UIImage(data: data!)!
    }
    
    public class func modelFromUrl(urlString: String) -> SCNScene {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!
        let bundle = Bundle.main
        let path = bundle.path(forResource: "TeaCup", ofType: "obj")
        let url = URL(fileURLWithPath: path!)
        
        do {
            let scene = try SCNScene(url: url)
            return scene
        }
        catch {
            print("scene")
        }
        
        return SCNScene()
    }
    
    public class func getZipFileFromUrl(_ objectType: String) {
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        if (arobjects[objectType]?.zipName != nil) {
            let destinationFileUrl = documentsUrl.appendingPathComponent((arobjects[objectType]?.zipName)!)
            
            print("getZipFileFromUrl")
            print("destinationFileUrl")
            print(destinationFileUrl)
            let remoteUrl = arobjects[objectType]?.url
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            if remoteUrl != nil, let url = URL(string: remoteUrl!) {
                print("remoteUrl != nil")
                let request = URLRequest(url: url)
                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Successfully downloaded. Status code: \(statusCode)")
                        }
                        
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                        } catch (let writeError) {
                            print("Error creating a file \(destinationFileUrl) : \(writeError)")
                        }
                        
                    } else {
                        print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
                    }
                }
                task.resume()
                if arobjects[objectType]?.zipName != nil {
                    unzipObject(endpoint: (arobjects[objectType]?.zipName)!)
                }
            }
        }
    }
    
    public class func unzipObject(endpoint: String) {
        do {
            //let filePath = Bundle.main.url(forResource: "downloadedFile", withExtension: "zip")
            let filePath:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
            let docFilePath = filePath.appendingPathComponent("TeaCup.zip")
            //let documentFilePath = filePath.appendingPathComponent(endpoint)
            print("filePath")
            print(docFilePath)
            let unzipDirectory = try Zip.quickUnzipFile(docFilePath) // Unzip
        print(unzipDirectory)
            
        } catch {
            print("error unzipping object")
        }
        //createModelFromDocumentStorage(endpoint: endpoint)
    }
    
    class func createModelFromDocumentStorage(endpoint: String){
        let filePath:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let docFilePath = filePath.appendingPathComponent("TeaCup/3D Models/TeaCup.obj")
        if #available(iOS 9.0, *) {
            let model = MDLAsset(url: docFilePath)
            print("3D Model")
            print(model)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 9.0, *)
    public class func getObject() -> MDLAsset {
        let filePath:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let docFilePath = filePath.appendingPathComponent("TeaCup/3D Models/TeaCup.obj")
        let model = MDLAsset(url: docFilePath)
        print("3D Model")
        print(model)
        return model
    }
    
    public class func postToDatabase(_ inputData: Data) {
        var request = URLRequest(url: URL(string: "http://jsonplaceholder.typicode.com/posts")!)
        request.httpMethod = "POST"
       // let postString = "id=13&name=Jack"
        request.httpBody = inputData//postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    
    
}
