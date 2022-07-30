//
//  RSMapVM.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 25.10.21.
//

import Foundation
import MapKit

protocol RSMapViewModelType: AnyObject, DatabaseServiceProtocol {
    var coordinatorDelegate: RSMapViewModelCoordinatorDelegate? { get set }
    var viewDelegate: RSMapViewModelViewDelegate? { get set }
    var activeDumps: [DumpModel] { get set }
    
    func getAllDumps()
    func dumpDidSelect(dump: DumpModel)
    func deselectAnnotaionView()
    func startObservingData()
    func finishObservingData()
}

protocol RSMapViewModelCoordinatorDelegate: AnyObject {
    func dumpDidSelect(dump: DumpModel)
}

protocol RSMapViewModelViewDelegate: AnyObject {
    func updateScreen()
    func deselectAnnotaionView()
    func removeDump(dump: DumpModel?)
}

class RSMapVM: NSObject, RSMapViewModelType {
    
    weak var coordinatorDelegate: RSMapViewModelCoordinatorDelegate?
    weak var viewDelegate: RSMapViewModelViewDelegate?
    unowned var databaseService: DatabaseServiceType
    
    private var dumps: [DumpModel] = [] {
        didSet {
            activeDumps = dumps.filter{ $0.clear == false }
            viewDelegate?.updateScreen()
        }
    }
    var activeDumps: [DumpModel] = []
    
    init(databaseService: DatabaseServiceType) {
        self.databaseService = databaseService
    }
    
    func startObservingData() {
        
        databaseService.setupObserver { [weak self] result in
            switch result {
            case .failure(_):
                print("Failed to load a data from DatabaseService")
            case .success(let dumps):
                DispatchQueue.main.async {
                    self?.dumps = dumps
                }
            }
        }
        
        databaseService.setupDumpChangesObserver { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(_):
                print("Failed to load a data from DatabaseService")
            case .success(let dump):
                DispatchQueue.main.async {
                    self.dumps = self.dumps.map({ dumpModel in
                        let newDump = dumpModel
                        if dumpModel.id == dump.id {
                            newDump.clear = dump.clear
                            self.viewDelegate?.removeDump(dump: newDump)
                        }
                        return newDump
                    })
                }
            }
        }
    }
    
    func finishObservingData() {
        databaseService.removeObservers()
    }
    
    func getAllDumps() {
        databaseService.getAllDumps() { [weak self] result in
            switch result {
            case .failure(_):
                print("Failed to load a data from DatabaseService")
            case .success(let dumps):
                DispatchQueue.main.async {
                    self?.dumps = dumps
                }
            }
        }
    }
    
    func dumpDidSelect(dump: DumpModel) {
        coordinatorDelegate?.dumpDidSelect(dump: dump)
    }
    
    func deselectAnnotaionView() {
        viewDelegate?.deselectAnnotaionView()
    }
    
}
