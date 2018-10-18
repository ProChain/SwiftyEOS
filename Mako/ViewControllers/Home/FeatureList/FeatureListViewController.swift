//
//  FeatureListViewController.swift
//  Mako
//
//  Created by croath on 2018/9/25.
//  Copyright © 2018 ProChain. All rights reserved.
//

import Cocoa

//fileprivate enum CellIdentifiers {
//    static let MenuCell = "MenuCellID"
//}

class FeatureListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: tableview datasource & delegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = "test"
            return cell
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            // we create an [Int] array from the index set
            let selected = myTable.selectedRowIndexes.map { Int($0) }
            print(selected)
        }
    }
}
