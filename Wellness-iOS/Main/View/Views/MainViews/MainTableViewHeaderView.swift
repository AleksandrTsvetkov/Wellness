//
//  MainTableViewHeaderView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/6/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
//import SwiftCharts
import Charts
import Alamofire
import Localize_Swift

class MainTableViewHeaderView: UIView, ChartViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet weak var userAvatarButton: UIButton!
    @IBOutlet private weak var activityView: UIView!
    @IBOutlet weak var targetCalLabel: UILabel!
    @IBOutlet weak var todayCalLabel: UILabel!
    @IBOutlet private weak var targetBarView: UIView!
    @IBOutlet weak var dotsStackView: UIStackView!
    @IBOutlet var periodButtons: [UIButton]!
    @IBOutlet weak var todayLbl: UILabel!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var sunBuuton: UIButton!
    @IBOutlet weak var targetLbl: UILabel!
    @IBOutlet weak var targetCalLbl: UILabel!
    @IBOutlet weak var todayBottomLbl: UILabel!
    @IBOutlet weak var todayBottomCalLbl: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var activityTitleLbl: UILabel!
    
    static let headerNibName = UINib(nibName: "MainTableViewHeaderView", bundle: nil)
    static let headerIdentifier = "MainTableViewHeaderView"
    var userAvatarButtonClosure = { }
    var calories = [CaloriesModel]()
    
    // MARK: - UITableViewHeaderFooterView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        configureUI()
        setupCharts()
        addTapGesture()
    }
    
    // MARK: - Methods
    private func configureUI() {
        todayLbl.text = "Today".localized()
        activityTitleLbl.text = "Activity".localized()
        weekButton.setTitle("weekly".localized(), for: .normal)
        wedButton.setTitle("wed".localized(), for: .normal)
        friButton.setTitle("fri".localized(), for: .normal)
        sunBuuton.setTitle("sun".localized(), for: .normal)
        targetLbl.text = "TARGET".localized()
        targetCalLbl.text = "0 \("cal".localized())"
        targetCalLbl.adjustsFontSizeToFitWidth = true
        todayBottomLbl.text = "TODAY".localized()
        todayBottomCalLbl.text = "0 \("cal".localized())"
        todayCalLabel.adjustsFontSizeToFitWidth = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        activityView.layer.cornerRadius = 10
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        if Localize.currentLanguage() == "ru" {
            dateFormatter.locale = Locale(identifier: "ru_ru")
        }
        dateLabel.text = dateFormatter.string(from: date).uppercased()
    }
    
    func configCharts(calories:[CaloriesModel]) {
        self.calories = calories
        print("Last Day", self.calories.first?.date)
        
        let shortCal = calories.dropLast(3)
        
        todayBottomCalLbl.text = "\(calories.first?.cal ?? 0) \("cal".localized())"
        
        var arrayPoints = [ChartDataEntry]()
        for point in shortCal {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let pointDate = dateFormatter.date(from: point.date ?? "2020-01-01")!
            let calendar = Calendar.current
            let newDate = calendar.date(byAdding: .day, value: 1, to: pointDate)
            let dateInt = newDate?.timeIntervalSince1970 ?? 0
            arrayPoints.append(ChartDataEntry(x: Double(dateInt), y: Double(point.cal ?? 0)))
        }
        //arrayPoints = arrayPoints.sorted(by: { $0.x < $1.x })
        arrayPoints = arrayPoints.reversed()
        print(arrayPoints)
        let dataSet = LineChartDataSet(entries: arrayPoints, label: "")
        dataSet.colors = [UIColor.white]
        dataSet.lineWidth = 2
        dataSet.drawCirclesEnabled = false
        dataSet.mode = .horizontalBezier
        
        let data = LineChartData(dataSets: [dataSet])
        data.setDrawValues(false)
        if arrayPoints.count > 0 {
            self.lineChartView.data = data
            self.lineChartView.notifyDataSetChanged()
        }
        
        //drawChartOn(chartView, with: chartPoints, andColor: .white)
    }
    
    func setupCharts() {
        lineChartView.isUserInteractionEnabled = false
        lineChartView.delegate = self
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = false
        //firstChart.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = false
        lineChartView.highlightPerDragEnabled = false
        lineChartView.backgroundColor = .clear
        lineChartView.legend.enabled = false
        
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont(name: "SFProDisplay-Semibold", size: 11)!
        xAxis.labelTextColor = UIColor.white
        //xAxis.avoidFirstLastClippingEnabled = true
        //xAxis.labelWidth = 10
        xAxis.drawAxisLineEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = UIColor(red: 235/255, green: 235/255, blue: 245/255, alpha: 0.6)
        // xAxis.centerAxisLabelsEnabled = true
        // xAxis.granularity = 3600
        xAxis.valueFormatter = DateValueFormatter()
        
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
        leftAxis.enabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.labelAlignment = .center
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelTextColor = UIColor(red: 235/255, green: 235/255, blue: 245/255, alpha: 0.6)
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.form = .line
        
        lineChartView.animate(xAxisDuration: 0.5)
        
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.activityView.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        if let infoView = ActivityView.viewNibName.instantiate(withOwner: nil, options: nil)[0] as? ActivityView {
            
            infoView.frame = UIScreen.main.bounds
            infoView.calories = self.calories
            DispatchQueue.main.async {
                infoView.show()
            }
            infoView.configCharts(calories: self.calories)
        }
    }
    
    func setProfileImage(_ userProfile: UIImage) {
        profileImageView.image = userProfile
    }
    
    // MARK: - Actions
    @IBAction func userAvatarButtonAction(_ sender: UIButton) {
        userAvatarButtonClosure()
    }
    
    @IBAction func periodButtonsAction(_ sender: UIButton) {
        periodButtons.forEach { (button) in
            if sender == button {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
}

