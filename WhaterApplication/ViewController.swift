//
//  ViewController.swift
//  WhaterApp
//
//  Created by user on 11/5/20.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var welcomLabel: UILabel!
    @IBOutlet weak var whaterImage: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var welcomeLabelInSearchName: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var searchTemperature: UILabel!
    @IBOutlet weak var descriptionImageName: UIImageView!
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
            languageStackView.isHidden=false
        }else{
            languageStackView.isHidden=true
        }
        
    }
    
    ///Manual search Click on the search image  😁
    @IBAction func searchButton(_ sender: Any) {
        searchButtonIsTapped=true
        let searchCityName=searchBar.text
        if searchButtonIsTapped{
            let url1 = "https://api.openweathermap.org/data/2.5/weather?q=\(searchCityName!)&appid=33aaadc8c64a8798fe3e5994410e3f47"
            let urlStr = URL(string: url1)
            let request1 = URLRequest(url: urlStr!)
            var jsonParse: [String : AnyObject]
            
            
            URLSession.shared.dataTask(with:request1, completionHandler: { (data, response, error) in
                
                guard let data = data, let _ = response, error == nil else {
                    print(error?.localizedDescription as Any)
                    
                    return
                }
                do{
                let json=try? JSONSerialization.jsonObject(with: data , options: .mutableContainers)
                    as? [String:AnyObject]
                    
                print("json\(json!)")
                
                DispatchQueue.main.async {
                    
//                    if json?["message"] as! String == "city not found"{
//                        self.welcomeLabelInSearchName.text = "This city non,"
//                    }else{
                    self.welcomeLabelInSearchName.text="You search the weather in \((json?["name"])!)"
                    self.nameLabel.text=json!["name"] as? String
                    
                    if let main=json!["main"]{
                        ///   273.15 calvin = 0˚C
                        let celvin=273.15
                        let temp=main["temp"] as! Double
                        let temp1=temp-celvin
                        
                        self.searchTemperature.text="\(String(temp1))˚C"
                    }
                    
                    if let weather=json{
                        for i in weather["weather"] as! [AnyObject]{
                            let main:String=i["main"] as! String
                            self.descriptionImageName?.image=UIImage(named:main.lowercased() )
                        }
                    }
                }
//                }
                
                }catch{
                    debugPrint(error)
                }
                
            }).resume()
            
        }
    }
    
    let locationManager=CLLocationManager()
    var currentLocation: CLLocation?
    var searchButtonIsTapped=false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        langImageButton?.setImage(UIImage(named: "ru"), for: .normal)
        armenianButton?.setImage(UIImage(named: "hy"), for: .normal)
        russianButton?.setImage(UIImage(named: "ru"), for: .normal)
        englandButton?.setImage(UIImage(named: "en"), for: .normal)
        setupToHideKeyboardOnTapOnView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
        
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
                
                var resName:String?=""
                let resTemp:Double?=result!.main.temp
                
                //for Print cityName and temperature
                DispatchQueue.main.async {
                    
                    if self.langImageButton?.currentImage==UIImage(named: "hy"){
                        UserDefaults.standard.setValue("hy", forKey: languageKey)
                        self.welcomLabel?.text="textWelcomeLabel".localizedLanguage()!+"\((result?.name)!)-ում"
                    }else if self.langImageButton?.currentImage==UIImage(named: "ru"){
                        UserDefaults.standard.setValue("ru", forKey: languageKey)
                        self.welcomLabel?.text="textWelcomeLabel".localizedLanguage()!+"\((result?.name)!)-е"
                    }else if self.langImageButton?.currentImage==UIImage(named: "en"){
                        UserDefaults.standard.setValue("en", forKey: languageKey)
                        self.welcomLabel?.text="textWelcomeLabel".localizedLanguage()!+"\((result?.name)!)"
                    }

                    
                    if result?.name != nil{
                        resName = result?.name
                    self.cityLabel?.text=resName
                    }else{
                        self.cityLabel.text=resName
                    }
                    
                    if resTemp != nil {
                    self.tempLabel?.text="\(resTemp!)˚C"
                    }
                    
                    //self.welcomLabel?.text="This is the weather in \((result?.name)!)"
                    
                    ///self.welcomLabel?.text="textWelcomeLabel".localizedLanguage()!+"Shuzenji".localizedLanguage()!
                    
                    if let wather = result {
                        print("wather \(wather)")
                        for i in wather.weather {
                            self.whaterImage?.image=UIImage(named: i.main.lowercased())
                            break
                            }
                        
                        }
                    
                    }
                
                } catch {
                debugPrint(error)
                }
            
            result = try? decoder.decode(Weather.self, from: data)
            
            print("\(lat)|||\(long)")
                
        })
        task.resume()
        
    }
    
    /// Վերջ
}
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let weather = try? newJSONDecoder().decode(Weather.self, from: jsonData)


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
        var defaultLanguage="WeatherLanguageEnglish"
        if let selectedLanguage = UserDefaults.standard.string(forKey: languageKey){
            defaultLanguage=selectedLanguage
        }
        return NSLocalizedString(self, tableName: defaultLanguage, comment: "")
    }
}
