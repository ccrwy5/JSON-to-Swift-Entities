//
//  ViewController.swift
//  JSON Codable Protocol
//
//  Created by Chris Rehagen on 2/3/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    struct Response: Codable{
        struct Photo: Codable {
            var image: String
            var title: String
            var description: String
            var latitude: Double
            var longitude: Double
            var date: String
            
            enum CodingKeys: String, CodingKey {
                case image = "image"
                case title = "title"
                case description = "description"
                case latitude = "latitude"
                case longitude = "longitude"
                case date = "date"
                
            }
        }
        var photos: [Photo]
    }
    
    var index: Int = 0
    let dateFromJSON = DateFormatter()
    let dateOutput = DateFormatter()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFromJSON.dateFormat = "yyyy-MM-dd HH:mm"
        dateOutput.dateStyle = .long

        index = 0
        
        getJSON(index: index)
    }

    @IBAction func handlePreviousClick(_ sender: Any) {
        if(index != 0){
            index = index - 1
        }else{
            index = 39
        }
        getJSON(index: index)
    }
    
    @IBAction func handleNextClick(_ sender: Any) {
        index+=1
        if(index <= 39){
            getJSON(index: index)
        }else{
            index = 0
            getJSON(index: index)
        }
    }
    
    
    
    func getJSON(index: Int){
        guard let url = URL(string: "https://dalemusser.com/code/examples/data/nocaltrip/photos.json") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let dataResponse = data, error == nil else {
                  print(error?.localizedDescription ??  "Error")
                  return }
            do {
                //here dataResponse received from a network request
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: dataResponse) //Decode JSON Response Data
                
                //print(response.photos[index].title)
                
                //for photo in photos.photos {
                //print(photo.title)
                DispatchQueue.main.async {
                    self.imageView.image = response.photos[index].image.toImage()
                    self.titleLabel.text = response.photos[index].title
                    self.descriptionLabel.text = "Description:\n" + response.photos[index].description
                    self.latitudeLabel.text = "Latitude : " + String(format: "%.4f", response.photos[index].latitude)
                    self.longitudeLabel.text = "Longitude: " + String(format: "%.4f", response.photos[index].longitude)
                    //self.dateLabel.text = formatter.string(from: response.photos[index])
                    self.dateLabel.text = self.dateOutput.string(from: self.dateFromJSON.date(from: response.photos[index].date)!)

                }
                //}
                
            } catch {
                print("Error")
            }
        }
        task.resume()
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
