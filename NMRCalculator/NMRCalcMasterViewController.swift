//
//  NMRCalcMasterViewController.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 8/7/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

class NMRCalcMasterViewController: UITableViewController {

    var nucleusVC: UIViewController?
    var signalVC: UIViewController?
    var pulseVC: UIViewController?
    var solutionVC: UIViewController?
    var infoVC: UIViewController?
    
    let viewControllers = ["nucleus", "signalView", "pulseView", "solutionView", "infoView"]
    let menuItems = ["Nucleus", "Signal", "RF Pulse", "Solution", "Info"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        nucleusVC = UIStoryboard(name: "iPadStoryboard", bundle: nil).instantiateViewController(withIdentifier: "nucleus")
        
        signalVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signalView")
        
        pulseVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pulseView")
        
        solutionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "solutionView")
        
        infoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "infoView")
        
        
        // self.menuItems = menuItems
        
        // let firstIndexPath = IndexPath(row: 0, section: 0)
        // self.tableView.selectRow(at: firstIndexPath, animated: true, scrollPosition: .top)
        // self.tableView(self.tableView, didSelectRowAt: firstIndexPath)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.menuItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MasterViewTableCell", for: indexPath) as! NMRCalcMasterItems

        cell.menuItems.text = menuItems[(indexPath as NSIndexPath).row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case 0:
            self.showDetailViewController(nucleusVC!, sender: self)
        case 1:
            self.showDetailViewController(signalVC!, sender: self)
        case 2:
            self.showDetailViewController(pulseVC!, sender: self)
        case 3:
            self.showDetailViewController(solutionVC!, sender: self)
        case 4:
            self.showDetailViewController(infoVC!, sender: self)
        default:
            self.showDetailViewController(infoVC!, sender: self)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! NMRCalcDetailViewController
            }
        }
    }*/
 

}
