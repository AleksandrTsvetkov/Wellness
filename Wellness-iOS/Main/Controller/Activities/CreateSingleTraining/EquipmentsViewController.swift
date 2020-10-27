//
//  EquipmentViewController.swift
//  Wellness-iOS
//
//  Created by FTL soft on 11/5/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

protocol EquipmentsViewControllerDelegate: class {
    func equipmentsDidSelected(_ viewController: EquipmentsViewController, selectedEquipments: [EqueipmentModel])
}

class EquipmentsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var baseBottomView: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var addSelectedButton: CustomCommonButton!
    
    // MARK: - Properties
    weak var delegate: EquipmentsViewControllerDelegate?
    private var equipments = [EqueipmentModel]() {
        didSet {
            searchedEquipments = equipments
            for equipment in searchedEquipments {
                for selectedEquipment in selectedEquipments {
                    if equipment.id == selectedEquipment.id {
                        equipment.isSelected = true
                    }
                }
            }
            tableView.reloadData()
        }
    }
    private var searchedEquipments = [EqueipmentModel]()
    var selectedEquipments = [EqueipmentModel]()
       
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        getListEquipments()
        configureUI()
        setLang()
        configureTableView()
        configureTextField()
        addTapToHideKeyboard()
    }
    
    // MARK: - Methods
    private func configureNavigationBar() {
        addNavigationBarLeftButtonWith(button: "button_dismiss", action: #selector(dismissButtonAction), imageView: nil)
    }
    
    @objc private func dismissButtonAction() {
        navigationController?.dismiss(animated: true)
    }
    
    func setLang() {
        titleLbl.text = "Equipment".localized()
        addSelectedButton.setTitle("Add selected equipment".localized(), for: .normal)
        searchTextField.placeholder = "Search".localized()
    }
    
    private func configureUI() {
        searchView.layer.cornerRadius = 5
        searchImageView.image = renderImage("icon_search")
        searchImageView.tintColor = UIColor.black.withAlphaComponent(0.25)
    }
    
    private func configureTextField() {
        searchTextField.delegate = self
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        tableView.register(EquipmentTableViewCell.cellNibName, forCellReuseIdentifier: EquipmentTableViewCell.cellIdentifier)
    }
    
    private func getListEquipments() {
        showActivityProgress()
        ServerManager.shared.listOfEquipments(successBlock: { (response) in
            self.hideActivityProgress()
            self.equipments = response
        }) { (error) in
            self.hideActivityProgress()
            self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
        }
    }
    
    private func searchEquipments(withText text: String) {
        if text.count >= 1 {
            searchedEquipments = equipments.filter { $0.name?.lowercased().range(of: text) != nil }
        } else {
            searchedEquipments = equipments
        }
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func addSelectedEquipmentsButtonAction(_ sender: Any) {
        delegate?.equipmentsDidSelected(self, selectedEquipments: selectedEquipments)
        navigationController?.dismiss(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension EquipmentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchedEquipments.enumerated().forEach { (index, equipment) in
            if index == indexPath.row {
                equipment.isSelected = !equipment.isSelected
                if equipment.isSelected {
                    selectedEquipments.append(equipment)
                } else {
                    selectedEquipments.enumerated().forEach { (index, deselectingEqipment) in
                        if equipment.id == deselectingEqipment.id {
                            selectedEquipments.remove(at: index)
                            equipment.isSelected = false
                            return
                        }
                    }
                }
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: equipment.isSelected ? 150 : 25, right: 0)
            }
        }
        baseBottomView.isHidden = selectedEquipments.isEmpty
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedEquipments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EquipmentTableViewCell.cellIdentifier, for: indexPath) as? EquipmentTableViewCell else { return UITableViewCell() }
        cell.setData(equipment: searchedEquipments[indexPath.row])
        return cell
    }
}

// MARK: - UITextFieldDelegate
extension EquipmentsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let new = textField.text! as NSString
        let newText = new.replacingCharacters(in: range, with: string)
        textField.text = newText
        searchEquipments(withText: newText)
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

