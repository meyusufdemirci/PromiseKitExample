//
//  ViewController.swift
//  PromiseKitExample
//
//  Created by Yusuf Demirci on 29.04.2020.
//  Copyright © 2020 Yusuf Demirci. All rights reserved.
//

import UIKit
import AVKit
import CoreLocation
import PromiseKit
import RxSwift
import RxCoreLocation

class HomeController: UIViewController {
    
    // MARK: - Properties
    private let infoLabel: UILabel = {
        let label: UILabel = UILabel()
        label.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: 200))
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private var isUserDidLogin: Bool = true
    private let locationManager: CLLocationManager = CLLocationManager()
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        view.addSubview(infoLabel)
        
        logState("Initializing view")
        
        // Shows loading indicator here
        
        firstly {
            self.checkIfUserDidLogin()
        }.then {
            self.checkCameraPermission()
        }.then {
            self.checkLocationPermission()
        }.then {
            when(fulfilled: [self.sendFirstRequest(), self.sendSecondRequest()])
        }.done {
            self.initView()
        }.catch { error in
            AlertManager.showError(message: (error as! ErrorModel).message, controller: self)
        }.finally {
            // Hides loading indicator here
        }
    }
}

// MARK: - Private Functions
private extension HomeController {
    
    func checkIfUserDidLogin() -> Promise<Void> {
        logState("Checking if user did login")
        
        let (promise, seal) = Promise<Void>.pending()
        
        if isUserDidLogin {
            seal.fulfill(())
        } else {
            seal.reject(ErrorModel(message: "User did not login"))
        }
        
        return promise
    }
    
    func checkCameraPermission() -> Promise<Void> {
        logState("Checking camera permission")
        
        let (promise, seal) = Promise<Void>.pending()
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case AVAuthorizationStatus.authorized:
            seal.fulfill(())
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                if granted {
                    seal.fulfill(())
                } else {
                    seal.reject(ErrorModel(message: "Camera permission denied"))
                }
            }
            
        case AVAuthorizationStatus.denied:
            seal.reject(ErrorModel(message: "Camera permission has been already denied"))
        default:
            seal.reject(ErrorModel(message: "Occured unknown error"))
        }
        
        return promise
    }
    
    func checkLocationPermission() -> Promise<Void> {
        logState("Checking location permission")
        
        let (promise, seal) = Promise<Void>.pending()
        
        switch CLLocationManager.authorizationStatus() {
        case CLAuthorizationStatus.authorizedAlways, CLAuthorizationStatus.authorizedWhenInUse:
            seal.fulfill(())
        case CLAuthorizationStatus.notDetermined:
            locationManager.requestAlwaysAuthorization()
            
            locationManager.rx
            .didChangeAuthorization
            .subscribe(onNext: { _, status in
                switch status {
                case CLAuthorizationStatus.authorizedAlways, CLAuthorizationStatus.authorizedWhenInUse:
                    seal.fulfill(())
                case CLAuthorizationStatus.denied:
                    seal.reject(ErrorModel(message: "Location permission has been already denied"))
                default:
                    seal.reject(ErrorModel(message: "Occured unknown error"))
                }
            }).disposed(by: disposeBag)
        case CLAuthorizationStatus.denied:
            seal.reject(ErrorModel(message: "Location permission has been already denied"))
        default:
            seal.reject(ErrorModel(message: "Occured unknown error"))
        }
        
        return promise
    }
    
    func sendFirstRequest() -> Promise<Void> {
        logState("Sending first request")
        
        let (promise, seal) = Promise<Void>.pending()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.logState("Got first request")
            seal.fulfill(())
        }
        
        return promise
    }
    
    func sendSecondRequest() -> Promise<Void> {
        logState("Sending second request")
        
        let (promise, seal) = Promise<Void>.pending()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
            self.logState("Got second request")
            seal.fulfill(())
        }
        
        return promise
    }
    
    func initView() {
        logState("Initialized view successfully")
    }
    
    func logState(_ state: String) {
        infoLabel.text = state
        NSLog(state)
    }
}
