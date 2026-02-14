//
//  SideMenuViewController.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/18/24.
//

import UIKit
import RxSwift
import SwiftyUserDefaults

protocol SideMenuDelegate: AnyObject {
    func sideMenuDidSelected(indexPath: IndexPath)
}

class SideMenuViewController: BaseViewController {
    
    // MARK: - Properties
    private weak var delegate: SideMenuDelegate?
    private var disposeBag = DisposeBag()
    private var viewModel: HomeViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Initialization
    init(delegate: SideMenuDelegate!, viewModel: HomeViewModel) {
        self.delegate = delegate
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Setup
    private func setupTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
        tableView.register(SideMenuTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        
        // Auto row height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadTableData),
            name: NSNotification.Name("ProcessingEngineChanged"),
            object: nil
        )
    }
    
    @objc private func reloadTableData() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & Delegate
//extension SideMenuViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.sideMenuData.count
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.reusedId, for: indexPath) as! SideMenuTableViewCell
//        let item = viewModel.sideMenuData[indexPath.row]
//        cell.viewConfig(sideMenuData: item)
//        
//        // Configure accessory view based on item type
//        if item.type == .processingEngine {
//            let engineSwitch = UISwitch()
//            engineSwitch.isOn = viewModel.currentEngine == .vision
//            engineSwitch.onTintColor = .systemBlue
//            engineSwitch.addTarget(self, action: #selector(toggleProcessingEngine(_:)), for: .valueChanged)
//            cell.accessoryView = engineSwitch
//            cell.selectionStyle = .none
//        } else {
//            cell.accessoryView = nil
//            cell.selectionStyle = .default
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = viewModel.sideMenuData[indexPath.row]
//        
//        // Don't trigger selection for switch items
//        if item.type == .processingEngine {
//            tableView.deselectRow(at: indexPath, animated: false)
//            return
//        }
//        
//        delegate?.sideMenuDidSelected(indexPath: indexPath)
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
//    
//    // MARK: - Actions
//    @objc private func toggleProcessingEngine(_ sender: UISwitch) {
//        viewModel.toggleProcessingEngine()
//    }
//}
