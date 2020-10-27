//
//  ActivityView.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 6/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit
//import SwiftCharts
import Localize_Swift
import Charts

class ActivityView: UIView, ChartViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet var periodButtons: [UIButton]!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var calLbl: UILabel!
    @IBOutlet weak var calCountLbl: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
    static let viewNibName = UINib(nibName: "ActivityView", bundle: nil)
    static let viewIdentifier = "ActivityView"
    private let infoViewHeightProportion: CGFloat = 812.0 / 416.0
    var calories = [CaloriesModel]()
    
    // MARK: - UIView Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        //let chartPoints = [(0, 0), (4, 4), (8, 11), (9, 2), (11, 10), (12, 3), (15, 18), (18, 10), (20, 15)]
        configureUI()
        DispatchQueue.main.async {
            self.setupCharts()
        }
        //configCharts()
        //drawChartOn(chartView, with: chartPoints, andColor: UIColor(red: 81/255, green: 58/255, blue: 80/255, alpha: 1))
        //chartView.bringSubviewToFront(chartDrawingView)//
    }
    
    // MARK: - Methods
    private func configureUI() {
        calLbl.text = "cal".localized()
        cancelButton.setTitle("cancel".localized(), for: .normal)
        dayButton.setTitle("day".localized(), for: .normal)
        weekButton.setTitle("week".localized(), for: .normal)
        monthButton.setTitle("month".localized(), for: .normal)
        backgroundView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * infoViewHeightProportion)
        backgroundView.roundCorners(corners: [.topLeft, .topRight], radius: 30.30)
    }
    
    func configCharts(calories: [CaloriesModel]) {
        
        calCountLbl.text = String(calories.first?.cal ?? 0)
        
        var arrayPoints = [ChartDataEntry]()
        for point in calories {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let pointDate = dateFormatter.date(from: point.date ?? "2020-01-01")!
            let calendar = Calendar.current
            let newDate = calendar.date(byAdding: .day, value: 1, to: pointDate)
            let dateInt = newDate?.timeIntervalSince1970 ?? 0
            arrayPoints.append(ChartDataEntry(x: Double(dateInt), y: Double(point.cal ?? 0)))
        }
        arrayPoints = arrayPoints.sorted(by: { $0.x < $1.x })
        print(arrayPoints)
        let dataSet = LineChartDataSet(entries: arrayPoints, label: "")
        dataSet.colors = [UIColor(red: 195/255, green: 66/255, blue: 63/255, alpha: 1)]
        dataSet.lineWidth = 2
        dataSet.drawCirclesEnabled = false
        dataSet.mode = .horizontalBezier
        
        let data = LineChartData(dataSets: [dataSet])
        data.setDrawValues(false)
        if arrayPoints.count > 0 {
            self.lineChartView.data = data
            DispatchQueue.main.async {
                self.lineChartView.notifyDataSetChanged()
            }
        }
        
        //drawChartOn(chartView, with: chartPoints, andColor: .white)
    }
    
    func setupCharts() {
        lineChartView.delegate = self
        lineChartView.chartDescription?.enabled = false
        lineChartView.dragEnabled = false
        lineChartView.isUserInteractionEnabled = false
        //firstChart.setScaleEnabled(true)
        lineChartView.pinchZoomEnabled = false
        lineChartView.highlightPerDragEnabled = false
        lineChartView.backgroundColor = .clear
        lineChartView.legend.enabled = false
        
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont(name: "SFProDisplay-Semibold", size: 11)!
        xAxis.labelTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawGridLinesEnabled = false
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
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelTextColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        lineChartView.rightAxis.enabled = false
        lineChartView.legend.form = .line
        
        lineChartView.animate(xAxisDuration: 0.7)
        
    }
    
    func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.backgroundView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.backgroundView.frame.height, width: UIScreen.main.bounds.width, height: self.backgroundView.frame.height)
            self.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        })
    }
    
    private func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.backgroundView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: self.backgroundView.frame.height)
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    // MARK: - Actions
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        //self.hide()
        self.endEditing(true)
    }
    
    @IBAction private func cancelButtonAction(_ sender: UIButton) {
        self.hide()
    }
    
    @IBAction func swipeDownGestureRecognizer(_ sender: UISwipeGestureRecognizer) {
        self.hide()
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
