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
        let wifiSentInMB = dataUsageInfo.wifiSent
        let wifiReceivedInMB = dataUsageInfo.wifiReceived
        let totalWiFiDataInMB = wifiSentInMB + wifiReceivedInMB
        let cellularSentInMB = dataUsageInfo.wwanDataSent
        let cellularReceivedInMB = dataUsageInfo.wwanDataReceived
        let totalCellularDataInMB = cellularSentInMB + cellularReceivedInMB
        DispatchQueue.main.async {
            self.wifiSentLabel.text = wifiSentInMB.toMegabytesString
            self.wifiReceivedLabel.text = wifiReceivedInMB.toMegabytesString
            self.wifiTotalLabel.text = totalWiFiDataInMB.toMegabytesString

            self.cellularSentLabel.text = cellularSentInMB.toMegabytesString
            self.cellularReceivedLabel.text = cellularReceivedInMB.toMegabytesString
            self.cellularTotalLabel.text = totalCellularDataInMB.toMegabytesString
        }
    }

    // MARK:- Action Methods
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        updateLabels()
    }

}

private extension UInt32 {
    var toMegabytesString: String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useMB, .useGB]
        byteCountFormatter.countStyle = .binary
        let megabytesString = byteCountFormatter.string(fromByteCount: Int64(self))
        return megabytesString
    }
}
