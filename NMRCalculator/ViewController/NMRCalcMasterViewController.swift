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
    
    var nmrCalc = NMRCalc()
    
    enum Menu: Int {
        case nucleus, signal, pulse, solution, info
    }
    
    let viewControllers: [Menu: String] = [.nucleus: "nucleus",
                                           .signal: "signalView",
                                           .pulse: "pulseView",
                                           .solution: "solutionView",
                                           .info: "infoView"]
    let menuItems: [Menu: String] = [.nucleus: "Nucleus",
                                     .signal: "Signal",
                                     .pulse: "RF Pulse",
                                     .solution: "Solution",
                                     .info: "Info"]

    override func viewDidLoad() {
        super.viewDidLoad()

        nucleusVC = UIStoryboard(name: "iPadStoryboard", bundle: nil).instantiateViewController(withIdentifier: viewControllers[.nucleus]!)
        
        signalVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewControllers[.signal]!)
        
        pulseVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewControllers[.pulse]!)
        
        solutionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewControllers[.solution]!)
        
        infoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewControllers[.info]!)
        
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

        cell.menuItems.text = menuItems[Menu(rawValue: indexPath.row)!]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Menu(rawValue: indexPath.row)! {
        case .nucleus:
            self.showDetailViewController(nucleusVC!, sender: self)
        case .signal:
            self.showDetailViewController(signalVC!, sender: self)
        case .pulse:
            self.showDetailViewController(pulseVC!, sender: self)
        case .solution:
            self.showDetailViewController(solutionVC!, sender: self)
        case .info:
            self.showDetailViewController(infoVC!, sender: self)
        }
    }

}
