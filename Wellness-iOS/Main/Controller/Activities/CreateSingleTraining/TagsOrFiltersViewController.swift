//
//  TagsOrFiltersViewController.swift
//  Wellness-iOS
//
//  Created by Karen Galoyan on 11/10/19.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

protocol TagsOrFiltersViewControllerDelegate: class {
    func tagsOrFiltersDidFinishedEditing(_ viewController: TagsOrFiltersViewController, selectedTags: [TagModel])
}

enum TagsOrFiltersType: Int {
    case tags, filters
    
    var title: String {
        switch self {
        case .tags: return "Tags".localized()
        case .filters: return "Filters".localized()
        }
    }
}

class TagsOrFiltersViewController: UIViewController {
    @IBOutlet private weak var titleLbl: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var applyButton: CustomCommonButton!
    
    // MARK: - Properties
    weak var delegate: TagsOrFiltersViewControllerDelegate?
    var type: TagsOrFiltersType!
    var selectedTags = [TagModel]()
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        getTagsOrFiltersRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        //applyButton.setTitle("Apply".localized(), for: .normal)
    }
    
    // MARK: - Methods
    private func configureUI() {
        titleLbl.text = self.type.title
        applyButton.setTitle("Apply".localized(), for: .normal)
    }
    
    private func configureNavigationBar() {
        addNavigationBarLeftButtonWith(button: "button_dismiss", action: #selector(dismissButtonAction), imageView: nil)
    }
    
    @objc private func dismissButtonAction() {
        navigationController?.dismiss(animated: true)
        
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: -25, right: 0)
        tableView.register(FilterTableViewCell.cellNibName, forCellReuseIdentifier: FilterTableViewCell.cellIdentifier)
    }
    
    private func getTagsOrFiltersRequest() {
        if AppSession.shared.tags == nil {
            ServerManager.shared.listOfTags(successBlock: { [weak self] (response) in
                guard let self = self else { return }
                AppSession.shared.tags = response
                self.tableView.reloadData()
            }) { (error) in
                self.showRequestErrorAlert(withErrorMessage: error.messageDictionary.first?.value as? String)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction private func applybuttonAction(_ sender: CustomCommonButton) {
        navigationController?.dismiss(animated: true)
        delegate?.tagsOrFiltersDidFinishedEditing(self, selectedTags: selectedTags)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TagsOrFiltersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppSession.shared.tags?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.cellIdentifier, for: indexPath) as? FilterTableViewCell, let tagsDataSource = AppSession.shared.tags else { return UITableViewCell() }
        cell.setData(from: tagsDataSource[indexPath.row], andSelectedTags: selectedTags)
        cell.tagDidSelected = { [weak self] (selectedTag) in
            guard let self = self else { return }
            var isContain = false
            self.selectedTags.forEach { (tag) in
                if selectedTag.id == tag.id {
                    isContain = true
                }
            }
            if !isContain {
                self.selectedTags.append(selectedTag)
            } else {
                self.selectedTags = self.selectedTags.filter { $0.id != selectedTag.id }
            }
        }
        return cell
    }
}
