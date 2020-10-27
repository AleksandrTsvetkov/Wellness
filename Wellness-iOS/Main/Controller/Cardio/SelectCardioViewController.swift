//
//  SelectCardioViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 10.02.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class SelectCardioViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet private weak var mapView: MGLMapView!
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var addGoalButton: UIButton!
    @IBOutlet private weak var durationStackView: UIStackView!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var doItOnceButton: UIButton!
    @IBOutlet private weak var selectPlanButton: UIButton!
    
    // MARK: Properties
    private var locationManager = CLLocationManager()
    
    // MARK: UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        configureMap()
        configureGradientView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        addNavigationBarBackButtonWith(UIColor.black.withAlphaComponent(0.2))
        addNavigationBarRightButtonWith(button: "button_add", action: #selector(addButtonAction), imageView: nil)
    }
    
    private func configureUI() {
        addGoalButton.layer.cornerRadius = 3
    }
    
    private func configureMap() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.compassView.isHidden = true
        mapView.logoView.isHidden = true
        mapView.attributionButton.alpha = 0
        mapView.alpha = 0.7
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
        gradient.frame = gradientView.bounds
        gradientView.layer.mask = gradient
    }
    
    @objc private func addButtonAction() {
        let viewController = ControllersFactory.addRunningViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Actions
    @IBAction func doItOnceButtonAction(_ sender: UIButton) {
        doItOnceButton.isSelected = true
        selectPlanButton.isSelected = false
    }
    
    @IBAction private func selectPlanButtoonAction(_ sender: UIButton) {
        selectPlanButton.isSelected = true
        doItOnceButton.isSelected = false
        let viewController = ControllersFactory.selectPlanViewContoller()
        viewController.view.clipsToBounds = true
        viewController.titelLabel.text = "Select Plan"
        viewController.isForCardio = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func addGoalButtonAction(_ sender: UIButton) {
        let viewController = ControllersFactory.addCardioGoalViewController()
        viewController.cardioGoalAndDurationDidSelectedClosure = { [weak self] (goal, duration) in
            guard let self = self else { return }
            self.durationStackView.isHidden = false
            self.addGoalButton.setTitle(goal, for: .normal)
            self.durationLabel.text = duration
        }
        present(controllerWithClearNavigationBar(viewController), animated: true)
    }
    
    @IBAction private func startButtonAction(_ sender: CustomCommonButton) {
        let durationComponents = (durationLabel.text ?? "00:00").components(separatedBy: ":")
        let hours = Int(durationComponents.first ?? "0") ?? 0
        let minutes = Int(durationComponents.last ?? "0") ?? 0
        let viewController = ControllersFactory.startCardioViewController()
        viewController.durationInMinutes = hours * 60 + minutes
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - MGLMapViewDelegate
extension SelectCardioViewController: MGLMapViewDelegate { }

// MARK: - CLLocationManagerDelegate
extension SelectCardioViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.setCenter(locationManager.location?.coordinate ?? ConfigDataProvider.initialCoordinates, zoomLevel: ConfigDataProvider.initialZoom, animated: false)
        locationManager.stopUpdatingLocation()
    }
}
