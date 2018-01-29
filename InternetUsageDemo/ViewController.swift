//
//  ViewController.swift
//  InternetUsageDemo
//
//  Created by Nayem BJIT on 1/29/18.
//  Copyright © 2018 BJIT Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var wifiSentLabel: UILabel!
    @IBOutlet weak var wifiReceivedLabel: UILabel!
    @IBOutlet weak var wifiTotalLabel: UILabel!
    
    @IBOutlet weak var cellularSentLabel: UILabel!
    @IBOutlet weak var cellularReceivedLabel: UILabel!
    @IBOutlet weak var cellularTotalLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let dataUsageInfo = DataUsage.currentSessionDataUsageInfo()
        updateLabels(with: dataUsageInfo)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        let dataUsageInfo = DataUsage.currentSessionDataUsageInfo()
        updateLabels(with: dataUsageInfo)
    }

    func updateLabels(with dataUsageInfo: DataUsageInfo) {
        let wifiSentInMB = Float32(dataUsageInfo.wifiSent)/1000000.0
        let wifiReceivedInMB = Float32(dataUsageInfo.wifiReceived)/1000000.0
        let totalWiFiDataInMB = wifiSentInMB + wifiReceivedInMB
        wifiSentLabel.text = /*String(describing: wifiSentInMB)*/ String(format: "%.2f", wifiSentInMB)
        wifiReceivedLabel.text = /*String(describing: wifiReceivedInMB)*/ String(format: "%.2f", wifiReceivedInMB)
        wifiTotalLabel.text = /*String(describing: totalWiFiDataInMB)*/ String(format: "%.2f", totalWiFiDataInMB)

        let cellularSentInMB = Float32(dataUsageInfo.wwanDataSent)/1000000.0
        let cellularReceivedInMB = Float32(dataUsageInfo.wwanDataReceived)/1000000.0
        let totalCellularDataInMB = cellularSentInMB + cellularReceivedInMB
        cellularSentLabel.text = /*String(describing: cellularSentInMB)*/ String(format: "%.2f", cellularSentInMB)
        cellularReceivedLabel.text = /*String(describing: cellularReceivedInMB)*/ String(format: "%.2f", cellularReceivedInMB)
        cellularTotalLabel.text = /*String(describing: totalCellularDataInMB)*/ String(format: "%.2f", totalCellularDataInMB)
    }

}

