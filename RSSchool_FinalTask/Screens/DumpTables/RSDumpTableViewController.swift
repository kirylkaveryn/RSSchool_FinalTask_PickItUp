//
//  RSDumpTableViewController.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 12.11.21.
//

import UIKit

class RSDumpTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: RSDumpTableViewModelType! {
        didSet {
            viewModel.viewDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)

        configureTableView()
        viewModel.getAllUserDumps()
        title = viewModel.title
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)

        if self.isMovingFromParent {
            viewModel.dismissScreen()
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.sectionHeaderHeight = 40
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .rsLineSeparatorColor
        
        tableView.register(UINib(nibName: "RSDumpTableViewCell", bundle: nil), forCellReuseIdentifier: RSDumpTableViewCell.reuseID)
    }

}

// MARK: Actions for buttons
extension RSDumpTableViewController {

}

// MARK: ViewModel Delegate
extension RSDumpTableViewController: RSDumpTableViewModelViewDelegate {
    func updateScreen() {
        tableView.reloadData()
    }
    
    func showAlert(_ message: String) {
        guard let navigationController = self.navigationController else { return }
        AlertPresenter.postErrorMessageAlert(message: message, navigationController: navigationController)
    }
    
    func updateCellImage(forIndex index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }
    
}


// MARK: UITableViewDelegate, UITableViewDataSource
extension RSDumpTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel.tableViewModel[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RSDumpTableViewCell.reuseID, for: indexPath) as! RSDumpTableViewCell
        cell.prepareCell(withModel: cellModel)
        if cell.imageIsDefault() {
            viewModel.downloadFirstImage(forIndex: indexPath.row) { image in
                cell.setImage(image: image)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
