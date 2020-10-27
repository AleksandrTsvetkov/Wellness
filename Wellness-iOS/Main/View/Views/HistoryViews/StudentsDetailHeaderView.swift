//
//  StudentsDetailHeaderView.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 09.07.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import UIKit
import Charts
import SDWebImage

class StudentsDetailHeaderView: UIView, ChartViewDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var activityBgView: UIView!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var createTrainingButton: UIButton!
    @IBOutlet weak var createPlanButton: UIButton!
    @IBOutlet weak var activityTitleLbl: UILabel!
    @IBOutlet weak var targetTitleLbl: UILabel!
    @IBOutlet weak var targetValueLbl: UILabel!
    @IBOutlet weak var todayTitleLbl: UILabel!
    @IBOutlet weak var todayValueLbl: UILabel!
    @IBOutlet weak var buttonsBgView: UIView!
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var secondNameLbl: UILabel!
    
    static let headerNibName = UINib(nibName: "StudentsDetailHeaderView", bundle: nil)
    static let headerIdentifier = "StudentsDetailHeaderView"
    
    var calories = [CaloriesModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 15
        activityBgView.layer.cornerRadius = 10
        buttonsBgView.layer.cornerRadius = 10
        createTrainingButton.setTitle("Create Single Training".localized(), for: .normal)
        createPlanButton.setTitle("Create Training Plan".localized(), for: .normal)
        targetTitleLbl.text = "TARGET".localized()
        todayTitleLbl.text = "TODAY".localized()
        DispatchQueue.main.async {
            self.setupCharts()
        }
        
    }
    
    func configUI(student:UserModel) {
        //print("STUDENT", student.avatar, student.firstName)
        avatarImageView.sd_setImage(with: URL(string: student.avatar ?? ""), placeholderImage: UIImage(named: "image_defoultNoshadow"), options: .highPriority, context: nil)
        if avatarImageView.image?.isDark ?? false {
            firstNameLbl.textColor = UIColor.white
            secondNameLbl.textColor = UIColor.white
        } else {
            firstNameLbl.textColor = UIColor.black
            secondNameLbl.textColor = UIColor.black
        }
        firstNameLbl.text = student.firstName
        secondNameLbl.text = student.lastName
        
        /*if avatarImageView?.image != nil {
            let isDark = avatarImageView!.image!.isDark
            if isDark == true {
                firstNameLbl.textColor = UIColor.white
                secondNameLbl.textColor = UIColor.white
            } else {
                firstNameLbl.textColor = UIColor.black
                secondNameLbl.textColor = UIColor.black
            }
        } else {
            firstNameLbl.textColor = UIColor.black
            secondNameLbl.textColor = UIColor.black
        }*/
        
    }
    
    func configCharts(calories:[CaloriesModel]) {
        self.calories = calories
        
        let shortCal = calories.dropLast(3)
        
        todayValueLbl.text = "\(calories.first?.cal ?? 0) \("cal".localized())"
        
        var arrayPoints = [ChartDataEntry]()
        for point in shortCal {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateInt = dateFormatter.date(from: point.date ?? "2020-01-01")?.timeIntervalSince1970 ?? 0
            arrayPoints.append(ChartDataEntry(x: Double(dateInt), y: Double(point.cal ?? 0)))
        }
        arrayPoints = arrayPoints.sorted(by: { $0.x < $1.x })
        print(arrayPoints)
        let dataSet = LineChartDataSet(entries: arrayPoints, label: "")
        dataSet.colors = [UIColor.white]
        dataSet.lineWidth = 2
        dataSet.drawCirclesEnabled = false
        dataSet.mode = .horizontalBezier
        
        let data = LineChartData(dataSets: [dataSet])
        data.setDrawValues(false)
        if arrayPoints.count > 0 {
            self.lineChart.data = data
            self.lineChart.notifyDataSetChanged()
        }
        
        activityBgView.addTapGestureRecognizer {
            DispatchQueue.main.async {
                if let infoView = ActivityView.viewNibName.instantiate(withOwner: nil, options: nil)[0] as? ActivityView {
                    
                    infoView.frame = UIScreen.main.bounds
                    infoView.calories = self.calories
                    DispatchQueue.main.async {
                        infoView.show()
                    }
                    infoView.configCharts(calories: self.calories)
                }
            }
        }
        
        //drawChartOn(chartView, with: chartPoints, andColor: .white)
    }
    
    func setupCharts() {
        lineChart.isUserInteractionEnabled = false
        lineChart.delegate = self
        lineChart.chartDescription?.enabled = false
        lineChart.dragEnabled = false
        //firstChart.setScaleEnabled(true)
        lineChart.pinchZoomEnabled = false
        lineChart.highlightPerDragEnabled = false
        lineChart.backgroundColor = .clear
        lineChart.legend.enabled = false
        
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont(name: "SFProDisplay-Semibold", size: 11)!
        xAxis.labelTextColor = UIColor.white
        xAxis.drawAxisLineEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = UIColor(red: 235/255, green: 235/255, blue: 245/255, alpha: 0.6)
        // xAxis.centerAxisLabelsEnabled = true
        // xAxis.granularity = 3600
        xAxis.valueFormatter = DateValueFormatter()
        
        
        let leftAxis = lineChart.leftAxis
        leftAxis.labelPosition = .outsideChart
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
        leftAxis.enabled = false
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawLimitLinesBehindDataEnabled = false
        leftAxis.drawZeroLineEnabled = false
        leftAxis.labelAlignment = .center
        leftAxis.drawAxisLineEnabled = false
        leftAxis.labelTextColor = UIColor(red: 235/255, green: 235/255, blue: 245/255, alpha: 0.6)
        lineChart.rightAxis.enabled = false
        lineChart.legend.form = .line
        
        lineChart.animate(xAxisDuration: 0.5)
    }
    
    @IBAction func createTainingButtonActio(_ sender: Any) {
        NotificationCenter.default.post(name: .needCreateTrainingForStudent, object: nil)
    }
    
    @IBAction func createPlanButtonAction(_ sender: Any) {
        NotificationCenter.default.post(name: .needCreatePlanForStudent, object: nil)
    }
    
}
