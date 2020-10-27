//
//  StartCardioViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 12.02.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import CoreLocation
import Mapbox
import HealthKit

class StartCardioViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet private weak var mapView: MGLMapView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var distanceUnitLabel: UILabel!
    @IBOutlet private weak var distanceBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var durationMinutesLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var durationSecondsLabel: UILabel!
    @IBOutlet private weak var durationUnitLabel: UILabel!
    @IBOutlet private weak var durationUnitBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playbackBackgroundView: UIView!
    @IBOutlet private weak var playbackView: UIView!
    @IBOutlet private weak var playbackWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var paceLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var heartLabel: UILabel!
    @IBOutlet private weak var caloriesLabel: UILabel!
    @IBOutlet private weak var informationBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var playPauseButton: UIButton!
    
    // MARK: Properties
    private var healthKitStore: HKHealthStore!
    private var locationManager = CLLocationManager()
    private var locationList: [CLLocationCoordinate2D] = []
    private var mapStyle: MGLStyle?
    private var polylineSource: MGLShapeSource?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var currentIndex = 1
    var isQuickStart = false
    private var isPlaying = false
    private var isMap = false
    var durationInMinutes = 60
    private var durationInSeconds = 0
    private var delta: CGFloat = 0
    private var timer: Timer?
    
    
    // MARK: UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        resetInformation()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.activityType = .fitness
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        }
        configureMap()
        configureGradientView()
        showActivityProgress()
        requestAppleHealthPeremissions { (success, error) in }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: Methods
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func configureUI() {
        if isQuickStart {
            informationBottomConstraint.constant = 140
            hideDurationInformation()
        } else {
            playbackWidthConstraint.constant = 0
            informationBottomConstraint.constant = 95.5
            playbackBackgroundView.layer.cornerRadius = 2.5
            playbackView.layer.cornerRadius = 2.5
            hideDistanceInformation()
        }
    }
    
    private func configureMap() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.compassView.isHidden = true
        mapView.logoView.isHidden = true
        mapView.attributionButton.alpha = 0
        mapView.isPitchEnabled = false
        mapView.styleURL = MGLStyle.lightStyleURL
        mapView.setCenter(locationManager.location?.coordinate ?? ConfigDataProvider.initialCoordinates, zoomLevel: ConfigDataProvider.initialZoom, animated: false)
        mapView.showsUserHeadingIndicator = true
        mapView.tintColor = UIColor(red: 250/255, green: 114/255, blue: 104/255, alpha: 1)
    }
    
    private func configureGradientView() {
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        let whiteColor = UIColor.white
        gradient.colors = [whiteColor.withAlphaComponent(0.0).cgColor, whiteColor.withAlphaComponent(0.5).cgColor, whiteColor.withAlphaComponent(1.0).cgColor]
        gradient.locations = [NSNumber(value: 0.0),NSNumber(value: 0.2),NSNumber(value: 1.0)]
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3.3416)
        gradientView.layer.mask = gradient
    }
    
    private func requestAppleHealthPeremissions(compliton: @escaping((_ success: Bool, _ error: Error? ) -> Void)) {
        healthKitStore = HKHealthStore()
        let healthKitTypesToRead : Set<HKObjectType> = [
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        ]
        if !HKHealthStore.isHealthDataAvailable() {
            print("error")
            compliton(false, nil)
            return
        }
        healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            compliton(success, error)
        }
    }
    
    func getAppleHealthData() {
        let heartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let heartRateQuery = HKSampleQuery(sampleType: heartRate, predicate: .none, limit: 0, sortDescriptors: nil) { query, results, error in
            if results!.count > 0 {
                var string:String = ""
                for result in results as! [HKQuantitySample] {
                    let HeartRate = result.quantity
                    string = "\(HeartRate)"
                    print(string)
                }
            }
        }
        self.healthKitStore.execute(heartRateQuery)
        
        let activeEnergy = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
        let activeEnergyQuery = HKSampleQuery(sampleType: activeEnergy, predicate: .none, limit: 0, sortDescriptors: nil) { (query, results, error) in
            if results!.count > 0 {
                var string:String = ""
                for result in results as! [HKQuantitySample] {
                    let HeartRate = result.quantity
                    string = "\(HeartRate)"
                    print(string)
                }
            }
        }
        self.healthKitStore.execute(activeEnergyQuery)
    }
    
    private func convertDurationToSeconds(from duration: Int) -> Int {
        let seconds = duration * 60
        return seconds
    }
    
    private func convertSecondsToDuration(from seconds: Int) -> String {
        let durationInMinutes = seconds / 60
        let durationInSeconds = seconds - durationInMinutes * 60
        let duration = "\(durationInMinutes < 10 ? "0\(durationInMinutes)" : "\(durationInMinutes)"):\(durationInSeconds < 10 ? "0\(durationInSeconds)" : "\(durationInSeconds)")"
        return duration
    }
    
    @objc private func refreshInformation() {
        if durationInSeconds == 1 {
            resetInformation()
        }
        hideActivityProgress()
        durationInSeconds -= 1
        setDurationInformation()
        playbackWidthConstraint.constant += delta
        if !locationList.isEmpty && locationList.count == currentIndex {
            let coordinates = Array(locationList[0..<currentIndex])
            updatePolylineWithCoordinates(coordinates: coordinates)
            currentIndex += 1
        }
        if isQuickStart {
            distanceLabel.text = "\(Double(Int(distance.value)) / 1000)"
        }
        getAppleHealthData()
        view.layoutIfNeeded()
    }
    
    private func resetInformation() {
        configureUI()
        durationInSeconds = convertDurationToSeconds(from: durationInMinutes)
        delta = playbackBackgroundView.bounds.width / CGFloat(durationInSeconds)
        setDurationInformation()
        playPauseButton.setImage(UIImage(named: "icon_play"), for: .normal)
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    private func setDurationInformation() {
        let durationComponents = convertSecondsToDuration(from: durationInSeconds).components(separatedBy: ":")
        durationMinutesLabel.text = "\(durationComponents.first ?? "00")"
        durationSecondsLabel.text = "\(durationComponents.last ?? "00")"
    }
    
    private func animateDistanceInformation() {
        self.isMap = !self.isMap
        UIView.animate(withDuration: 0.5) {
            if self.isMap {
                self.distanceBottomConstraint.constant = 60
                self.distanceLabel.transform = CGAffineTransform(translationX: 0, y: 95).scaledBy(x: 0.35, y: 0.35)
                self.distanceUnitLabel.transform = CGAffineTransform(translationX: 0, y: 15).scaledBy(x: 0.5, y: 0.5)
                self.mapView.alpha = 1
            } else {
                self.distanceBottomConstraint.constant = 75
                self.distanceLabel.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
                self.distanceUnitLabel.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
                self.mapView.alpha = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func animateDurationInformation() {
        self.isMap = !self.isMap
        if self.isMap {
            UIView.animate(withDuration: 0.3) {
                self.playbackBackgroundView.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut, animations: {
                self.playbackBackgroundView.alpha = 1
            })
        }
        UIView.animate(withDuration: 0.5) {
            if self.isMap {
                self.durationUnitBottomConstraint.constant = 50
                self.durationMinutesLabel.transform = CGAffineTransform(translationX: 25, y: 45).scaledBy(x: 0.65, y: 0.65)
                self.durationLabel.transform = CGAffineTransform(translationX: 0, y: 45).scaledBy(x: 0.65, y: 0.65)
                self.durationSecondsLabel.transform = CGAffineTransform(translationX: -25, y: 45).scaledBy(x: 0.65, y: 0.65)
                self.durationUnitLabel.transform = CGAffineTransform(translationX: 0, y: 10).scaledBy(x: 0.5, y: 0.5)
                self.mapView.alpha = 1
            } else {
                self.durationUnitBottomConstraint.constant = 160
                self.durationMinutesLabel.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
                self.durationLabel.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
                self.durationSecondsLabel.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
                self.durationUnitLabel.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
                self.mapView.alpha = 0
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideDistanceInformation() {
        distanceLabel.isHidden = true
        distanceUnitLabel.isHidden = true
    }
    
    private func hideDurationInformation() {
        durationMinutesLabel.isHidden = true
        durationLabel.isHidden = true
        durationSecondsLabel.isHidden = true
        durationUnitLabel.isHidden = true
        playbackBackgroundView.isHidden = true
    }
    
    func addPolyline(to style: MGLStyle) {
        let identifier = UUID().uuidString
        let source = MGLShapeSource(identifier: identifier, shape: nil, options: nil)
        style.addSource(source)
        polylineSource = source
        let layer = MGLLineStyleLayer(identifier: identifier, source: source)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineColor = NSExpression(forConstantValue: UIColor(red: 250/255, green: 114/255, blue: 104/255, alpha: 1))
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [15: 4, 18: 20])
        style.addLayer(layer)
    }
    
    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
        polylineSource?.shape = polyline
    }
    
    // MARK: Actions
    @IBAction private func settingsButtonAction(_ sender: UIButton) {
    }
    
    @IBAction private func mapButtonAction(_ sender: UIButton) {
        if isQuickStart {
            animateDistanceInformation()
        } else {
            animateDurationInformation()
        }
    }
    
    @IBAction private func playPauseButtonAction(_ sender: UIButton) {
        isPlaying = !isPlaying
        playPauseButton.setImage(UIImage(named: isPlaying ? "icon_pause" : "icon_play"), for: .normal)
        distance = Measurement(value: 0, unit: UnitLength.meters)
        if isPlaying {
            showActivityProgress()
            let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshInformation), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            self.timer = timer
        } else {
            timer?.invalidate()
        }
    }
    
    @IBAction private func stopButtonAction(_ sender: UIButton) {
        resetInformation()
        let viewController = ControllersFactory.cardioCompletionPopupViewController()
        present(controllerWithClearNavigationBar(viewController), animated: true)
    }
}

// MARK: - MGLMapViewDelegate
extension StartCardioViewController: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        hideActivityProgress()
        mapStyle = mapView.style
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        mapView.setCenter(locationManager.location?.coordinate ?? ConfigDataProvider.initialCoordinates, zoomLevel: ConfigDataProvider.initialZoom, animated: false)
        if isPlaying {
            if let lastLocation = locationList.last, let delta = userLocation?.location?.distance(from: CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)) {
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
            }
            if let coordinate = userLocation?.coordinate {
                locationList.append(coordinate)
            }
            if let mapStyle = mapStyle {
                addPolyline(to: mapStyle)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension StartCardioViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.setCenter(locationManager.location?.coordinate ?? ConfigDataProvider.initialCoordinates, zoomLevel: ConfigDataProvider.initialZoom, animated: false)
    }
}
