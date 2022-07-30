//
//  RSStatisticsTableVC.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 13.11.21.
//

import UIKit

class RSStatisticsTableVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortButton: UIButton!
    
    let refreshControl = UIRefreshControl()
    var viewModel: RSStatisticsViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }

    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewDidLoad()
        title = viewModel.title
        
        refreshControl.addTarget(self, action: #selector(reloadScreen), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        configureSortButton()
        configureTableView()
        viewModel.getAllUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.sectionHeaderHeight = 40
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .rsLineSeparatorColor
        
        tableView.register(UINib(nibName: "RSUserTableViewCell", bundle: nil), forCellReuseIdentifier: RSUserTableViewCell.reuseID)
    }
    
    private func configureSortButton() {
        let items = SortType.allCases.map { type in UIAction(title: type.rawValue) { [weak self] _ in
            self?.viewModel.changeSortingType(type)
        } }
        sortButton.menu = UIMenu(title: "", children: items)
        sortButton.showsMenuAsPrimaryAction = true
    }

}

// MARK: Actions for buttons
extension RSStatisticsTableVC {
    
    @IBAction func sortButtonDidPress(_ sender: Any) {
        
        
    }

}

// MARK: ViewModel Delegate
extension RSStatisticsTableVC: RSStatisticsViewModelViewDelegate {
    
    @objc func updateScreen() {
        tableView.reloadData()
    }
    
    @objc func reloadScreen() {
        viewModel.getAllUsers()
        refreshControl.endRefreshing()
    }

    func showAlert(_ message: String) {
        guard let navigationController = self.navigationController else { return }
        AlertPresenter.postErrorMessageAlert(message: message, navigationController: navigationController)
    }
    
    func updateCell(forIndex index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
}


// MARK: UITableViewDelegate, UITableViewDataSource
extension RSStatisticsTableVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sortedTableViewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel.sortedTableViewModel[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RSUserTableViewCell.reuseID, for: indexPath) as! RSUserTableViewCell
        cell.prepareCell(withModel: cellModel)
        if cell.imageIsDefault() {
            viewModel.downloadImage(forIndex: indexPath.row) { image in
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
