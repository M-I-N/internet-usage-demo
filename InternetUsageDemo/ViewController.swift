//
//  ViewController.swift
//  InternetUsageDemo
//
//  Created by Nayem BJIT on 1/29/18.
//  Copyright © 2018 BJIT Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // MARK:- IBOutlets
    @IBOutlet weak var wifiSentLabel: UILabel!
    @IBOutlet weak var wifiReceivedLabel: UILabel!
    @IBOutlet weak var wifiTotalLabel: UILabel!
    
    @IBOutlet weak var cellularSentLabel: UILabel!
    @IBOutlet weak var cellularReceivedLabel: UILabel!
    @IBOutlet weak var cellularTotalLabel: UILabel!

    // MARK:- Private Properties
    private var timer: DispatchSourceTimer?

    // MARK:- ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if DeviceManager.rebootOccuredFromLastTime {
            // New reboot detected
            // Store data usage of last session with data usage of all session
            let lastSessionDataUsage = DataUsage.lastSessionDataUsageInfoFromDatabase
            DataUsage.saveTotal(dataUsageInfo: lastSessionDataUsage)
        }
        startTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        self.stopTimer()
    }

    // MARK:- Private Functions
    private func startTimer() {
        let queue = DispatchQueue(label: "com.domain.app.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.schedule(deadline: .now(), repeating: .seconds(30))
        timer!.setEventHandler { [weak self] in
            // do whatever you want here
            self?.periodicUpdateDatabase()
        }
        timer!.resume()
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    private func periodicUpdateDatabase() {
        let currentDataUsageInfo = DataUsage.currentSessionDataUsageInfo
        DataUsage.saveCurrent(dataUsageInfo: currentDataUsageInfo)
        updateLabels()
    }

    private func updateLabels() {
        let dataUsageInfo = DataUsage.allSessionsDataUsageInfo
        updateLabels(with: dataUsageInfo)
    }

    private func updateLabels(with dataUsageInfo: DataUsageInfo) {
        let wifiSentInMB = Float32(dataUsageInfo.wifiSent)/1000000.0
        let wifiReceivedInMB = Float32(dataUsageInfo.wifiReceived)/1000000.0
        let totalWiFiDataInMB = wifiSentInMB + wifiReceivedInMB
        let cellularSentInMB = Float32(dataUsageInfo.wwanDataSent)/1000000.0
        let cellularReceivedInMB = Float32(dataUsageInfo.wwanDataReceived)/1000000.0
        let totalCellularDataInMB = cellularSentInMB + cellularReceivedInMB
        DispatchQueue.main.async {
            self.wifiSentLabel.text = String(format: "%.2f", wifiSentInMB)
            self.wifiReceivedLabel.text = String(format: "%.2f", wifiReceivedInMB)
            self.wifiTotalLabel.text = String(format: "%.2f", totalWiFiDataInMB)

            self.cellularSentLabel.text = String(format: "%.2f", cellularSentInMB)
            self.cellularReceivedLabel.text = String(format: "%.2f", cellularReceivedInMB)
            self.cellularTotalLabel.text = String(format: "%.2f", totalCellularDataInMB)
        }
    }

    // MARK:- Action Methods
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        updateLabels()
    }

}

