//
//  ViewController.swift
//  DriveMe
//
//  Created by Isaac Dunnett on 2020-06-02.
//  Copyright © 2020 Isaac Dunnett. All rights reserved.
//

import UIKit
import MediaPlayer
import MediaAccessibility
import MapKit
import CoreImage

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var musicArtwork: UIImageView!
    var defaultImg: UIImage!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var straight: UIImageView!
    @IBOutlet weak var right: UIImageView!
    @IBOutlet weak var directionView: UIView!
    @IBOutlet weak var openCompassCircle: UIImageView!
    
    var locationManager: CLLocationManager!
    var timer: Timer?
    var currentStep: Int = 0
    var wait: Bool = false
    var moveToNextStep: Bool = true
    var count: Int = 0
    var countTurn: Int = 0
    var turn: Bool = false
    var directionAtStep: String? = ""
    var d0: String? = ""
    var d1: String? = ""
    var d2: String? = ""
    var d3: String? = ""
    var d4: String? = ""
    var d5: String? = ""
    var startingCountDownTimer: Int = 15
    var stopStartingCountDownTimer: Bool = false
    
    let termsOfUse = """
    DriveMe does not recommend use of the app on ANY highways or roads which may be dangerous to drive on. DriveMe is NOT an app to distract drivers from their driving and would ask that all users of DriveMe take SAFETY AS THEIR NUMBER ONE PRIORITY. DriveMe is not responsible for any legal errors made on behalf of the users’ driving. Any directions given by DriveMe should only be listened to IF, AND ONLY IF THE ACTION IS SAFE TO EXECUTE AND THE SPECIFIC SCENARIO IS SAFE. ALL USERS MUST USE DRIVEME AT THEIR OWN RISK.

    By selecting "Accept” the user agrees to the terms of use written above.
    """
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func displayLicenAgreement(message:String){
         //create alert
         let alert = UIAlertController(title: "Terms of Use", message: message, preferredStyle: .alert)
    //create Decline button
         let declineAction = UIAlertAction(title: "Decline" , style: .destructive){ (action) -> Void in
    }
    //create Accept button
         let acceptAction = UIAlertAction(title: "Accept", style: .default) { (action) -> Void in
    }
    //add task to tableview buttons
         alert.addAction(declineAction)
         alert.addAction(acceptAction)
    self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultImg = musicArtwork.image
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        
        straight.isHidden = true
        right.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
         if(!appDelegate.hasAlreadyLaunched){
         
              //set hasAlreadyLaunched to false
              appDelegate.sethasAlreadyLaunched()
    //display user agreement license
              displayLicenAgreement(message: self.termsOfUse)
        }
    }
    
    @objc func runTimedCode() {
        //Grab the controller
        let sysMP : MPMusicPlayerController & MPSystemMusicPlayerController = MPMusicPlayerController.systemMusicPlayer;
        //Grab current playing
        let currItem : MPMediaItem? = sysMP.nowPlayingItem;
        let currSongTitle : String? = sysMP.nowPlayingItem?.title
        let currSongArtist : String? = sysMP.nowPlayingItem?.artist
        //Grab currItem's artwork
        let image : UIImage? = currItem?.artwork?.image(at: CGSize(width: 300, height: 300));
        musicArtwork.image = image
        blurEffect(img: musicArtwork)
        mainView.backgroundColor = musicArtwork.image?.averageColor
        songTitle.text = currSongTitle
        artist.text = currSongArtist
        
        let rCalc: Double = (mainView.backgroundColor!.r()! * 299)
        let gCalc: Double = (mainView.backgroundColor!.g()! * 587)
        let bCalc: Double = (mainView.backgroundColor!.b()! * 114)
        let rgbAddition: Double = rCalc + gCalc + bCalc
        
        let rgbCalc: Double = rgbAddition / 1000
        
        if rgbCalc < 125 {
            right.tintColor = .white
            straight.tintColor = .white
            label.textColor = .white
            songTitle.textColor = .white
            artist.textColor = .white
        }
        else {
            right.tintColor = .black
            straight.tintColor = .black
            label.textColor = .black
            songTitle.textColor = .black
            artist.textColor = .black
        }
        
        if count == 15 {
            wait = false
            count = 0
        }
        
        if turn == true {
            if countTurn == 1 {
                d1 = label.text
            }
            else if countTurn == 2 {
                d2 = label.text
            }
            else if countTurn == 3 {
                d3 = label.text
            }
            else if countTurn == 4 {
                d4 = label.text
            }
            else if countTurn == 5 {
                d5 = label.text
                countTurn = 0
            }
            
            
            if d5 == d4 && d4 == d3 && d3 == d2 && d2 == d1 {
                directionAtStep = d5
                openCompassCircle.tintColor = .systemRed
            }
            else {
                openCompassCircle.tintColor = .white
            }
        }
        else {
            openCompassCircle.tintColor = .systemRed
        }
        
        if wait == false && moveToNextStep == true{
            currentStep = Int.random(in: 0 ... 8)
            print(currentStep)
            if currentStep == 0 || currentStep == 3 || currentStep == 4 || currentStep == 5 || currentStep == 6 || currentStep == 7 || currentStep == 8 {
                straight.isHidden = false
                right.isHidden = true
                animateStraight(img: straight)
                wait = true
                turn = false
            }
            else if currentStep == 1 {
                straight.isHidden = true
                right.isHidden = false
                right.transform = CGAffineTransform(scaleX: 1, y: 1);
                animateRight(img: right)
                directionAtStep = label.text
                moveToNextStep = false
                turn = true
                countTurn = 0
            }
            else if currentStep == 2 {
                straight.isHidden = true
                right.isHidden = false
                right.transform = CGAffineTransform(scaleX: -1, y: 1);
                animateLeft(img: right)
                directionAtStep = label.text
                moveToNextStep = false
                turn = true
                countTurn = 0
            }
        }
        else {
            if wait == true {
                count += 1
            }
            else{
                countTurn += 1
                print(countTurn)
                if currentStep == 1 {
                    switch directionAtStep {
                    case "N":
                        if label.text == "E" {
                            moveToNextStep = true
                        }
                    case "NE":
                        if label.text == "SE" {
                            moveToNextStep = true
                        }
                    case "E":
                        if label.text == "S" {
                            moveToNextStep = true
                        }
                    case "SE":
                        if label.text == "SW" {
                            moveToNextStep = true
                        }
                    case "S":
                        if label.text == "W" {
                            moveToNextStep = true
                        }
                    case "SW":
                        if label.text == "NW" {
                            moveToNextStep = true
                        }
                    case "W":
                        if label.text == "N" {
                            moveToNextStep = true
                        }
                    case "NW":
                        if label.text == "NE" {
                            moveToNextStep = true
                        }
                    default:
                        moveToNextStep = false
                    }
                }
                else if currentStep == 2 {
                    switch directionAtStep {
                    case "N":
                        if label.text == "W" {
                            moveToNextStep = true
                        }
                    case "NE":
                        if label.text == "NW" {
                            moveToNextStep = true
                        }
                    case "E":
                        if label.text == "N" {
                            moveToNextStep = true
                        }
                    case "SE":
                        if label.text == "NE" {
                            moveToNextStep = true
                        }
                    case "S":
                        if label.text == "E" {
                            moveToNextStep = true
                        }
                    case "SW":
                        if label.text == "SE" {
                            moveToNextStep = true
                        }
                    case "W":
                        if label.text == "S" {
                            moveToNextStep = true
                        }
                    case "NW":
                        if label.text == "SW" {
                            moveToNextStep = true
                        }
                    default:
                        moveToNextStep = false
                    }
                }
            }
        }
        
        if stopStartingCountDownTimer == false {
            startingCountDownTimer -= 1
            if startingCountDownTimer == 0 {
                stopStartingCountDownTimer = true
            }
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        label.text = cardinalValue(from: newHeading.trueHeading)
        //print(getFacingDegree(from: newHeading.trueHeading))
    }
    
    func getFacingDegree(from heading: CLLocationDirection) -> Double {
        return heading
    }
    

    func cardinalValue(from heading: CLLocationDirection) -> String {
        switch heading {
        case 0 ..< 22.5:
            return "N"
        case 22.5 ..< 67.5:
            return "NE"
        case 67.5 ..< 112.5:
            return "E"
        case 112.5 ..< 157.5:
            return "SE"
        case 157.5 ..< 202.5:
            return "S"
        case 202.5 ..< 247.5:
            return "SW"
        case 247.5 ..< 292.5:
            return "W"
        case 292.5 ..< 337.5:
            return "NW"
        case 337.5 ... 360.0:
            return "N"
        default:
            return ""
        }
        
    }
    
    func blurEffect(img: UIImageView) {
        
        let context = CIContext(options: nil)
        
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: img.image ?? defaultImg)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(25, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        img.image = processedImage
    }
    
    func animateLeft(img: UIImageView) {
        directionView.backgroundColor = .red
        let frm: CGRect = directionView.frame
        directionView.frame = CGRect(x: frm.origin.x + 350, y: frm.origin.y, width: 0.0, height: 350.0)
        
        UIView.animate(withDuration: 0.5) {
            self.directionView.frame = CGRect(x: frm.origin.x, y: frm.origin.y, width: 350, height: 350)
        }
        
        UIView.animate(withDuration: 1.5) {
            self.directionView.backgroundColor = .clear
        }
    }
    
    func animateRight(img: UIImageView) {
        directionView.backgroundColor = .red
        let frm: CGRect = directionView.frame
        directionView.frame = CGRect(x: frm.origin.x, y: frm.origin.y, width: 0.0, height: 350)
        
        UIView.animate(withDuration: 0.5) {
            self.directionView.frame = CGRect(x: frm.origin.x, y: frm.origin.y, width: 350, height: 350)
        }
        
        UIView.animate(withDuration: 1.5) {
            self.directionView.backgroundColor = .clear
        }
    }
    
    func animateStraight(img: UIImageView) {
        directionView.backgroundColor = .red
        let frm: CGRect = directionView.frame
        directionView.frame = CGRect(x: frm.origin.x, y: frm.origin.y + 350, width: 350.0, height: 0.0)
        
        UIView.animate(withDuration: 0.5) {
            self.directionView.frame = CGRect(x: frm.origin.x, y: frm.origin.y, width: 350.0, height: 350.0)
        }
        
        UIView.animate(withDuration: 1.5) {
            self.directionView.backgroundColor = .clear
        }
    }


}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

extension UIColor {

    func r() -> (Double)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Double(fRed * 255.0)

            return iRed
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
    func g() -> (Double)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iGreen = Double(fGreen * 255.0)

            return iGreen
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
    func b() -> (Double)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iBlue = Double(fBlue * 255.0)

            return iBlue
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
    
    func rgb() -> (Double)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iAlpha = Double(fAlpha * 255.0)

            return iAlpha
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}
