//
//  SavedFilesTableViewController.swift
//  Activ5-IMU_Example
//
//  Created by Konstantin Kostadinov on 5.12.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class SavedFilesTableViewController: UITableViewController {
    let cellId = "reuseIdentifier"
    var csvNames = [String]()
    var csvFiles = [URL]()
    var countedFiles:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK: - CSV fucntions
    func checkCsvFiles(){
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(directoryContents)
            let csvFiles = directoryContents.filter{ $0.pathExtension == "csv" }
            countedFiles = csvFiles.count
            self.csvFiles = csvFiles
            let csvFileNames = csvFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print(fileManager.currentDirectoryPath)
            csvNames = csvFileNames
        } catch {
            print(error)
        }
    }
    func deleteCSV(at indexPath: Int,csv: URL ){
        let fileManager = FileManager.default
        //let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            try fileManager.removeItem(at: csv)
        
        } catch {
            print(error)
        }
    }
    func renameCSV(oldName: String,newName: String){
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains( .documentDirectory, .userDomainMask, true)[0] as String
        let path = paths.appending("/")
        do {
            let old = "\(oldName).csv"
            let new = "\(newName).csv"
            print(fileManager.currentDirectoryPath)
            try fileManager.moveItem(atPath: "\(path)\(old)", toPath: "\(path)\(new)")
            self.tableView.reloadData()
        } catch {
        }
    }
    //MARK: - Swiping actions
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        let renameFile = renameAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete,renameFile])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let csv = self.csvFiles[indexPath.row]
            self.deleteCSV(at: indexPath.row, csv: csv)
            self.csvFiles.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
            completion(true)
        }
        action.title = "Delete"
        action.backgroundColor = .red
        return action
    }
    func renameAction(at indexPath: IndexPath) -> UIContextualAction{
        let action = UIContextualAction(style: .normal, title: "Rename") { (action, view, completion) in
            let oldCSVName = self.csvNames[indexPath.row]
            self.allertController(oldCSV: oldCSVName)
            completion(true)
        }
        action.title = "Rename"
        return action
    }
    //MARK: - Alert action
    func allertController(oldCSV: String){
        let alert = UIAlertController(title: "Rename your CSV file", message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addTextField { (oldCSVTF) in
            oldCSVTF.text = oldCSV
            oldCSVTF.isUserInteractionEnabled = false
        }
        alert.addTextField { (newSCVTF) in
            newSCVTF.placeholder = "Enter new csv name"
        }
        let action = UIAlertAction(title: "Rename", style: .default) { (_) in
            guard let oldCSV = alert.textFields?.first?.text, let newCSV = alert.textFields?[1].text else { return }
            
            let oldCSVName = oldCSV == "" ? nil : oldCSV
            let newCSVName = newCSV == "" ? nil : newCSV
            guard let csvOldName = oldCSVName else {return}
            guard let csvNewName = newCSVName else {return}
            self.renameCSV(oldName: csvOldName, newName: csvNewName)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        checkCsvFiles()
        guard let count = countedFiles else {return 0}
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let csv = csvNames[indexPath.row]
        cell.textLabel?.text = "\(csv)"
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let csv = csvFiles[indexPath.row]
        csv.share()
    }
}

extension UIApplication {
    class var topViewController: UIViewController? { return getTopViewController() }
    private class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController { return getTopViewController(base: nav.visibleViewController) }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController { return getTopViewController(base: selected) }
        }
        if let presented = base?.presentedViewController { return getTopViewController(base: presented) }
        return base
    }
}

extension Hashable {
    func share() {
        let activity = UIActivityViewController(activityItems: [self], applicationActivities: nil)
        UIApplication.topViewController?.present(activity, animated: true, completion: nil)
    }
}
