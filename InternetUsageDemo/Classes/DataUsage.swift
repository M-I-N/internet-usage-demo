//
//  DataUsage.swift
//  InternetUsageDemo
//
//  Created by Nayem BJIT on 1/29/18.
//  Copyright © 2018 BJIT Ltd. All rights reserved.
//

import UIKit

class DataUsage: NSObject {

    // MARK:- Private Properties (Stored)
    private static let wwanInterfacePrefix = "pdp_ip"
    private static let wifiInterfacePrefix = "en"
    private static let lastDataUsageInfoKey = "LastDataUsageInfo"
    private static let currentDataUsageInfoKey = "CurrentDataUsageInfo"

    // MARK:- Private Functions
    private static func dataUsageInfo(from pointer: UnsafeMutablePointer<ifaddrs>) -> DataUsageInfo? {
        let address = pointer.pointee.ifa_addr.pointee
        guard address.sa_family == UInt8(AF_LINK) else {
            return nil
        }
        let name = String(cString: pointer.pointee.ifa_name)
        let dataUsageInfo = DataUsage.dataUsageInfo(from: pointer, name: name)
        return dataUsageInfo
    }

    private static func dataUsageInfo(from pointer: UnsafeMutablePointer<ifaddrs>, name: String) -> DataUsageInfo? {
        var dataUsageInfo = DataUsageInfo()
        if name.hasPrefix(wifiInterfacePrefix) {
            let networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wifiSent += networkData.pointee.ifi_obytes
            dataUsageInfo.wifiReceived += networkData.pointee.ifi_ibytes
        } else if name.hasPrefix(wwanInterfacePrefix) {
            let networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wwanDataSent += networkData.pointee.ifi_obytes
            dataUsageInfo.wwanDataReceived += networkData.pointee.ifi_ibytes
        }

        return dataUsageInfo
    }

    private static func getTotalDataUsageInfoFromDatabase() -> DataUsageInfo {
        guard let dataUsageInfoData = UserDefaults.standard.value(forKey: lastDataUsageInfoKey) as? Data,
            let dataUsageInfo = try? PropertyListDecoder().decode(DataUsageInfo.self, from: dataUsageInfoData) else {
                return DataUsageInfo()
        }
        return dataUsageInfo
    }

    private static func getCurrentSessionDataUsageInfoFromDatabase() -> DataUsageInfo {
        return lastSessionDataUsageInfoFromDatabase
    }

    // MARK: Public Properties (Computed)
    class var currentSessionDataUsageInfo: DataUsageInfo {
        var dataUsageInfo = DataUsageInfo()
        var interfaceAddress: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaceAddress) == 0 else {
            return dataUsageInfo
        }

        while let pointer = interfaceAddress {
            // get the datausage info
            guard let info = DataUsage.dataUsageInfo(from: pointer) else {
                interfaceAddress = pointer.pointee.ifa_next
                continue
            }
            // new data usage found, append it with the previous data usage
            dataUsageInfo += info
            interfaceAddress = pointer.pointee.ifa_next
        }
        freeifaddrs(interfaceAddress)
        return dataUsageInfo
    }

    class var lastSessionDataUsageInfoFromDatabase: DataUsageInfo {
        guard let dataUsageInfoData = UserDefaults.standard.value(forKey: currentDataUsageInfoKey) as? Data,
            let dataUsageInfo = try? PropertyListDecoder().decode(DataUsageInfo.self, from: dataUsageInfoData) else {
                return DataUsageInfo()
        }
        return dataUsageInfo
    }

    class var allSessionsDataUsageInfo: DataUsageInfo {
        var dataUsageInfo = getTotalDataUsageInfoFromDatabase()
        dataUsageInfo += getCurrentSessionDataUsageInfoFromDatabase()
        return dataUsageInfo
    }

    // MARK: Public Functions
    static func saveTotal(dataUsageInfo: DataUsageInfo) {
        var lastTotal = getTotalDataUsageInfoFromDatabase()
        lastTotal += dataUsageInfo
        let encodedInfo = try? PropertyListEncoder().encode(lastTotal)
        UserDefaults.standard.set(encodedInfo, forKey: lastDataUsageInfoKey)
    }
    
    static func saveCurrent(dataUsageInfo: DataUsageInfo) {
        let encodedInfo = try? PropertyListEncoder().encode(dataUsageInfo)
        UserDefaults.standard.set(encodedInfo, forKey: currentDataUsageInfoKey)
    }

}

struct DataUsageInfo: Codable {

    // MARK:- Public Properties
    var wifiSent: UInt32 = 0
    var wifiReceived: UInt32 = 0
    var wwanDataSent: UInt32 = 0
    var wwanDataReceived: UInt32 = 0

    // MARK:- Private Functions
    private mutating func updateInfoByAdding(info: DataUsageInfo) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        
        wwanDataSent += info.wwanDataSent
        wwanDataReceived += info.wwanDataReceived
    }

    // MARK:- Overloaded Functions
    static func +=( lhs: inout DataUsageInfo, rhs: DataUsageInfo) {
        lhs.updateInfoByAdding(info: rhs)
    }
}

enum AppLaunchManager {

    // MARK: - Private Properties
    private static let launchesCountKey = "AppLaunchesCount"

    // MARK: Public Functions & Properties

    static func registerLaunch() {
        UserDefaults.standard.set(launchesCount + 1, forKey: launchesCountKey)
    }

    static var launchesCount: Int {
        let launchCount = UserDefaults.standard.integer(forKey: launchesCountKey)
        return launchCount
    }

    static var isFirstLaunch: Bool {
        return launchesCount <= 1
    }
}

enum DeviceManager {

    // MARK:- Private Properties
    private static let deviceBootTimeKey = "DeviceBootTime"

    private static var deviceCurrentBootTime: Date {
        let systemUpTime = ProcessInfo.processInfo.systemUptime
        let nowTime = Date()
        let deviceBootTime = nowTime - systemUpTime
        return deviceBootTime
    }

    private static var storedLastBootTime: Date {
        get {
            guard let lastBootTime = UserDefaults.standard.value(forKey: deviceBootTimeKey) as? Date else {
                let oldestDate = Date(timeIntervalSince1970: 0)
                return oldestDate
            }
            return lastBootTime
        }
        set {
            UserDefaults.standard.set(newValue, forKey: deviceBootTimeKey)
        }
    }

    // MARK:- Public Properties
    static var rebootOccuredFromLastTime: Bool {
        let deviceCurrentBootTime = DeviceManager.deviceCurrentBootTime
        let storedLastBootTime = DeviceManager.storedLastBootTime
        let timeInterval = deviceCurrentBootTime.timeIntervalSince(storedLastBootTime)
        if timeInterval > 1 {
            DeviceManager.storedLastBootTime = deviceCurrentBootTime
            return true
        }
        return false
    }
}
// Links:
// https://stackoverflow.com/questions/1443601/how-can-i-detect-whether-the-iphone-has-been-rebooted-since-last-time-app-starte
// https://stackoverflow.com/questions/46415095/in-ios-using-swift-how-do-you-get-the-time-of-iphone-boot

