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
    
    var timer: DispatchSourceTimer?
    var totalDataUsage = DataUsageInfo()

    override func viewDidLoad() {
        super.viewDidLoad()

//        let dataUsageInfo = DataUsage.currentSessionDataUsageInfo()
//        updateLabels(with: dataUsageInfo)
        if DeviceManager.rebootOccuredFromLastTime {
            // add child database with mother database
            let lastSessionDataUsage = DataUsage.getLastSessionDataUsageInfoFromDatabase()
            DataUsage.saveTotal(dataUsageInfo: lastSessionDataUsage)
        }
        startTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func periodicUpdateDatabase() {
        let currentDataUsageInfo = DataUsage.currentSessionDataUsageInfo()
        DataUsage.saveCurrent(dataUsageInfo: currentDataUsageInfo)
        updateLabels()
    }
    
    func startTimer() {
        let queue = DispatchQueue(label: "com.domain.app.timer")  // you can also use `DispatchQueue.main`, if you want
        timer = DispatchSource.makeTimerSource(queue: queue)
//        timer!.scheduleRepeating(deadline: .now(), interval: .seconds(60))
        timer!.schedule(deadline: .now(), repeating: .seconds(30))
        timer!.setEventHandler { [weak self] in
            // do whatever you want here
            self?.periodicUpdateDatabase()
        }
        timer!.resume()
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    deinit {
        self.stopTimer()
    }


    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
//        let dataUsageInfo = DataUsage.currentSessionDataUsageInfo()
//        updateLabels(with: dataUsageInfo)
//        let dataUsageInfo = DataUsage.getTotalDataUsageInfoFromDatabase()
//        updateLabels(with: dataUsageInfo)
        updateLabels()
    }
    
    func updateLabels() {
        var dataUsageInfo = DataUsage.getTotalDataUsageInfoFromDatabase()
        dataUsageInfo += DataUsage.getCurrentSessionDataUsageInfoFromDatabase()
        let wifiSentInMB = Float32(dataUsageInfo.wifiSent)/1000000.0
        let wifiReceivedInMB = Float32(dataUsageInfo.wifiReceived)/1000000.0
        let totalWiFiDataInMB = wifiSentInMB + wifiReceivedInMB
        let cellularSentInMB = Float32(dataUsageInfo.wwanDataSent)/1000000.0
        let cellularReceivedInMB = Float32(dataUsageInfo.wwanDataReceived)/1000000.0
        let totalCellularDataInMB = cellularSentInMB + cellularReceivedInMB
        DispatchQueue.main.async {
            
            self.wifiSentLabel.text = /*String(describing: wifiSentInMB)*/ String(format: "%.2f", wifiSentInMB)
            self.wifiReceivedLabel.text = /*String(describing: wifiReceivedInMB)*/ String(format: "%.2f", wifiReceivedInMB)
            self.wifiTotalLabel.text = /*String(describing: totalWiFiDataInMB)*/ String(format: "%.2f", totalWiFiDataInMB)
            
            self.cellularSentLabel.text = /*String(describing: cellularSentInMB)*/ String(format: "%.2f", cellularSentInMB)
            self.cellularReceivedLabel.text = /*String(describing: cellularReceivedInMB)*/ String(format: "%.2f", cellularReceivedInMB)
            self.cellularTotalLabel.text = /*String(describing: totalCellularDataInMB)*/ String(format: "%.2f", totalCellularDataInMB)
        }
    }

    func updateLabels(with dataUsageInfo: DataUsageInfo) {
        let wifiSentInMB = Float32(dataUsageInfo.wifiSent)/1000000.0
        let wifiReceivedInMB = Float32(dataUsageInfo.wifiReceived)/1000000.0
        let totalWiFiDataInMB = wifiSentInMB + wifiReceivedInMB
        let cellularSentInMB = Float32(dataUsageInfo.wwanDataSent)/1000000.0
        let cellularReceivedInMB = Float32(dataUsageInfo.wwanDataReceived)/1000000.0
        let totalCellularDataInMB = cellularSentInMB + cellularReceivedInMB
        DispatchQueue.main.async {
            
            self.wifiSentLabel.text = /*String(describing: wifiSentInMB)*/ String(format: "%.2f", wifiSentInMB)
            self.wifiReceivedLabel.text = /*String(describing: wifiReceivedInMB)*/ String(format: "%.2f", wifiReceivedInMB)
            self.wifiTotalLabel.text = /*String(describing: totalWiFiDataInMB)*/ String(format: "%.2f", totalWiFiDataInMB)
            
            self.cellularSentLabel.text = /*String(describing: cellularSentInMB)*/ String(format: "%.2f", cellularSentInMB)
            self.cellularReceivedLabel.text = /*String(describing: cellularReceivedInMB)*/ String(format: "%.2f", cellularReceivedInMB)
            self.cellularTotalLabel.text = /*String(describing: totalCellularDataInMB)*/ String(format: "%.2f", totalCellularDataInMB)
        }
    }

}

