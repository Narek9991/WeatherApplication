//
//  ViewController.swift
//  WeatherApp
//
//  Created by Narek Katvalyan on 2/25/22.

import UIKit
import CoreLocation
import ImageIO

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //view controller in automatic response location
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var blurView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    var blurAnimator: UIViewPropertyAnimator!
    
    //Search view controller
    @IBOutlet var backgroundImageViewManualSearch: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var welcomeLabelInSearchName: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var searchTemperature: UILabel!
    @IBOutlet weak var descriptionImageName: UIImageView!
    
    //use language 
    @IBOutlet weak var languageStackView: UIStackView!
    @IBOutlet weak var armenianButton: UIButton!
    @IBOutlet weak var russianButton: UIButton!
    @IBOutlet weak var englandButton: UIButton!
    @IBOutlet weak var langImageButton: UIButton!
    @IBAction func setEngImageButton(_ sender: Any) {
        langImageButton?.setImage(UIImage(named: "en"), for: .normal)
    }
    @IBAction func setRusImageButton(_ sender: Any) {
        langImageButton?.setImage(UIImage(named: "ru"), for: .normal)
    }
    @IBAction func setArmImageButton(_ sender: Any) {
       langImageButton?.setImage(UIImage(named: "hy"), for: .normal)
    }
    
    @IBAction func imageButton(_ sender: Any) {
        if languageStackView.isHidden {
            languageStackView.isHidden = false
        }else{
            languageStackView.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    ///Manual search Click on the search image  
    @IBAction func searchButton(_ sender: Any) {
        searchButtonIsTapped = true
        
        let searchCityName = searchBar.text
        
        if searchButtonIsTapped{
            
            let url1 = "https://api.openweathermap.org/data/2.5/weather?q=\(searchCityName!)&appid=33aaadc8c64a8798fe3e5994410e3f47"
            
            let urlStr = URL(string: url1)
            
            let request1 = URLRequest(url: urlStr!)
            
            URLSession.shared.dataTask(with:request1, completionHandler: { (data, response, error) in
                
                guard let data = data, let _ = response, error == nil else {
                    print(error?.localizedDescription as Any)
                    
                    return
                }
                do{
                let json = try? JSONSerialization.jsonObject(with: data , options: .mutableContainers)
                    as? [String:AnyObject]
                    
                print("json\(json!)")
                
                DispatchQueue.main.async {
                    
                    if json?["message"] != nil {
                        
                        self.welcomeLabelInSearchName.text = "City not available"
                        self.backgroundImageViewManualSearch.image = nil
                        self.nameLabel.text = ""
                        self.searchTemperature.text = ""
                        self.descriptionImageName?.image = nil
                        
                    } else {
                        
                        self.welcomeLabelInSearchName.text="you_Search_The_Weather_In".localizedLanguage()!+"\((json?["name"])!)"
                        
                    self.nameLabel.text=json!["name"] as? String
                    
                    if let main=json!["main"]{
                        ///   273.15 calvin = 0˚C
                        let celvin = 273.15
                        let temp = main["temp"] as! Double
                        let temp1 = temp-celvin
                        
                        self.searchTemperature.text = "\(String(temp1).components(separatedBy: ".")[0])˚C"
                    }
                    
                    if let weather=json{
                        for i in weather["weather"] as! [AnyObject] {
                            
                            self.backgroundImageViewManualSearch?.image = nil
                            
                            let main:String = i["main"] as! String
                            
                            self.descriptionImageName?.image = UIImage(named:main.lowercased() )
                            
                            if main.lowercased() == "clouds" {
                                
                             self.backgroundImageViewManualSearch?.loadGif(name: "cloudyGif")
                                
                             } else if main.lowercased() == "clear" {
                                 
                                 self.backgroundImageViewManualSearch?.loadGif(name: "sunGif")
                                 
                             } else if main.lowercased() == "rain" {
                                 
                                 self.backgroundImageViewManualSearch?.loadGif(name: "rainGif")
                                
                             } else if main.lowercased() == "snow" {
                                 
                                 self.backgroundImageViewManualSearch?.loadGif(name: "snowGif")
                                 
                                }
                            }
                        }
                    }
                }
                
                } catch {
                    debugPrint(error)
                }
                
            }).resume()
            
        }
    }
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var searchButtonIsTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.tabBarController?.selectedIndex == 1 {
            
            searchBar.searchTextField.backgroundColor = .white
            searchBar.searchTextField.textColor = .black
        }
        
        
        blurView?.backgroundColor = .clear
        
        langImageButton?.setImage(UIImage(named: "hy"), for: .normal)
        armenianButton?.setImage(UIImage(named: "hy"), for: .normal)
        russianButton?.setImage(UIImage(named: "ru"), for: .normal)
        englandButton?.setImage(UIImage(named: "en"), for: .normal)
        setupToHideKeyboardOnTapOnView()
        if tabBarController?.selectedIndex == 1 {
            removeItems()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    
    //Func for Blur effect
    func blurEffect(view: UIView, fractionComplete: Double){
        let blurEffectView = UIVisualEffectView()
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        
        blurAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [blurEffectView] in
            blurEffectView.effect = UIBlurEffect(style: .dark)
        }

        blurAnimator.fractionComplete = fractionComplete
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil  {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            print("location none")
            return
        }
        
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        let url = "https://fcc-weather-api.glitch.me/api/current?lat=\(lat)&lon=\(long)"
        let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let request = URLRequest(url: URL(string: urlString!)!)
       
        var result: Weather?
        
        if self.tabBarController?.selectedIndex == 0{
        
        let task = URLSession.shared.dataTask(with:request, completionHandler: { (data, response, error) in
            
            guard let data = data, let _ = response, error == nil else {
                print(error?.localizedDescription as Any)
                    
                return
            }
            print("data ->>", data)
            print("aaa")
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            //Decoder
            let decoder = JSONDecoder()

            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                 result = try decoder.decode(Weather.self, from: data)
                
                var resName:String? = ""
                let resTemp:Double? = result!.main.temp
                
                //for Print cityName and temperature
                DispatchQueue.main.async {
                    
                    if self.langImageButton?.currentImage == UIImage(named: "hy"){
                        UserDefaults.standard.setValue("en", forKey: languageKey)
                        
                    }

                    if result!.name != nil{
                        resName = result?.name
                        self.cityLabel?.textColor = .white
                        self.cityLabel?.text = resName
                    }
                    
                    var tempResult = 0.0
                    if resTemp != nil {
                        self.tempLabel?.textColor = .white
                        if(String(resTemp!).components(separatedBy: ".")[0]) == "-0"{
                            tempResult = 0.0
                        }else{
                           tempResult = resTemp!
                        }
                        self.tempLabel?.text = "\(String(tempResult).components(separatedBy: ".")[0])˚C"
                    }
                    
                    //Show gif image
                    if let wather = result {
                        print("wather \(wather)")
                        for i in wather.weather {
                           if i.main.lowercased() == "clouds"{
                            self.backgroundImageView?.loadGif(name: "cloudyGif")
                            }else if i.main.lowercased() == "sunny"{
                                self.backgroundImageView?.loadGif(name: "sunGif")
                            }else if i.main.lowercased() == "rain"{
                                self.backgroundImageView?.loadGif(name: "rainGif")
                            }else if i.main.lowercased() == "snow"{
                                self.backgroundImageView?.loadGif(name: "snowGif")
                            }else if i.main.lowercased() == "smoke"{
                                self.backgroundImageView?.loadGif(name: "sunGif")
                            }
                            break
                            }
                        }
                    
                    // Blur effect
                    
                    self.blurEffect(view: self.blurView, fractionComplete: 0.3)
                    
                }
                } catch {
                debugPrint(error)
                }

            print("\(lat)|||\(long)")
            
        }).resume()
    }
        
    }
    
    func removeItems() {
        self.blurView?.removeFromSuperview()
    }
    /// Վերջ
}
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let weather = try? newJSONDecoder().decode(Weather.self, from: jsonData)

// MARK: Extension

extension UIViewController
{
    func setupToHideKeyboardOnTapOnView(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

let languageKey="languageKey"

extension String{
    func localizedLanguage() -> String? {
        var defaultLanguage = "WeatherLanguageEnglish"
        if let selectedLanguage = UserDefaults.standard.string(forKey: languageKey){
            defaultLanguage = selectedLanguage
        }
        return NSLocalizedString(self, tableName: defaultLanguage, comment: "")
    }
}


