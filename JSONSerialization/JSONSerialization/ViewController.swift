//
//  ViewController.swift
//  JSONSerialization
//
//  Created by Chris Rehagen on 2/1/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    
    
    
    struct Photo {
        var image: String
        var title: String
        var description: String
        var latitude: Double
        var longitude: Double
        var date: String
        
        
//    init(_ dictionary: [String: Any]) {
//        self.image = dictionary["image"] as? String ?? ""
//        self.title = dictionary["title"] as? String ?? ""
//        self.description = dictionary["description"] as? String ?? ""
//        self.latitude = dictionary["latitude"] as? Double ?? 0.0
//        self.longitude = dictionary["longitude"] as? Double ?? 0.0
//        self.date = dictionary["date"] as? String ?? ""
//        }
    }
    
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        index = 0
        getJSON(index: index)
    }
    
    // next button
    @IBAction func handleClick(_ sender: Any) {
        
        index+=1
        if(index <= 39){
            getJSON(index: index)
        }else{
            index = 0
            getJSON(index: index)
        }
    }
    
    // back button
    @IBAction func handlePreviousClick(_ sender: Any) {
        
        if(index != 0){
            index = index - 1
        }else{
            index = 39
        }
        getJSON(index: index)
    }
    
    func getJSON(index: Int){
        
        var photosArray = [Photo]()
        
        guard let url = URL(string: "https://dalemusser.com/code/examples/data/nocaltrip/photos.json") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do {
                guard let jsonResponse = try? JSONSerialization.jsonObject(with: dataResponse, options: []),
                    let responseArray = jsonResponse as? [String: Any] else {
                        throw CustomError.customThrowMessage("Error")
                }
                                
                if let photosData = responseArray["photos"] as? [[String: Any]] {
                    for singlePhoto in photosData {
                        if let image = singlePhoto["image"] as? String,
                            let title = singlePhoto["title"] as? String,
                            let latitude = singlePhoto["latitude"] as? Double,
                            let longitude = singlePhoto["longitude"] as? Double,
                            let description = singlePhoto["description"] as? String,
                            let date = singlePhoto["date"] as? String {
                            
                            photosArray.append(Photo(image: image, title: title, description: description, latitude: latitude, longitude: longitude, date: date))
                        }
                    }
                    DispatchQueue.main.async {
                        self.imageView.image = photosArray[index].image.toImage()
                        self.titleLabel.text = photosArray[index].title
                        self.descriptionLabel.text = "Description: \n" + photosArray[index].description
                        self.latLabel.text = "Latitude: " + String(format:"%.4f", photosArray[index].latitude)
                        self.longLabel.text = "Longitude: " + String(format:"%.4f", photosArray[index].longitude)
                    }
                }
            } catch let parsingError {
                print("Error", parsingError)
           }
        } // end getJSON()
        task.resume()
    }
    enum CustomError: Error {
        case customThrowMessage(String)
    }
}


extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
