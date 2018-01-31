//
//  DataUsage.swift
//  InternetUsageDemo
//
//  Created by Nayem BJIT on 1/29/18.
//  Copyright © 2018 BJIT Ltd. All rights reserved.
//

import UIKit

class DataUsage: NSObject {
    private static let wwanInterfacePrefix = "pdp_ip"
    private static let wifiInterfacePrefix = "en"
    
    class func currentSessionDataUsageInfo() -> DataUsageInfo {
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

    static func saveTotal(dataUsageInfo: DataUsageInfo) {
        var lastTotal = getTotalDataUsageInfoFromDatabase()
        lastTotal += dataUsageInfo
        let encodedInfo = try? PropertyListEncoder().encode(lastTotal)
        UserDefaults.standard.set(encodedInfo, forKey: "LastDataUsage")
    }
    
    static func getTotalDataUsageInfoFromDatabase() -> DataUsageInfo {
        guard let dataUsageInfoData = UserDefaults.standard.value(forKey: "LastDataUsage") as? Data,
            let dataUsageInfo = try? PropertyListDecoder().decode(DataUsageInfo.self, from: dataUsageInfoData) else {
                return DataUsageInfo()
        }
        return dataUsageInfo
    }
    
//    private static func append(info: DataUsageInfo) {
//            var dataUsageInfo = getDataUsageInfoFromDatabase()
//            dataUsageInfo += info
//            DataUsage.saveTotal(dataUsageInfo: dataUsageInfo)
//    }
    
    static func saveCurrent(dataUsageInfo: DataUsageInfo) {
        let encodedInfo = try? PropertyListEncoder().encode(dataUsageInfo)
        UserDefaults.standard.set(encodedInfo, forKey: "CurrentDataUsageInfo")
    }
    static func getLastSessionDataUsageInfoFromDatabase() -> DataUsageInfo {
        guard let dataUsageInfoData = UserDefaults.standard.value(forKey: "CurrentDataUsageInfo") as? Data,
            let dataUsageInfo = try? PropertyListDecoder().decode(DataUsageInfo.self, from: dataUsageInfoData) else {
                return DataUsageInfo()
        }
        return dataUsageInfo
    }
    static func getCurrentSessionDataUsageInfoFromDatabase() -> DataUsageInfo {
        return getLastSessionDataUsageInfoFromDatabase()
    }

    class func allSessionsDataUsageInfo() -> DataUsageInfo {
        var dataUsageInfo = DataUsageInfo()
        if DeviceManager.rebootOccuredFromLastTime {
            // get usage info from data base and append it with current session
            dataUsageInfo += DataUsage.getTotalDataUsageInfoFromDatabase()
            dataUsageInfo += DataUsage.currentSessionDataUsageInfo()
        } else {
            dataUsageInfo += DataUsage.currentSessionDataUsageInfo()
        }
        return dataUsageInfo
    }
    
    class func allsessionDataUsageInfo() {
        /*var info = DataUsageInfo()
        
        if DeviceManager.rebootOccuredFromLastTime {
            info += DataUsage.getDataUsageInfoFromDatabase()
        }
        info += DataUsage.currentSessionDataUsageInfo()*/
        
        if DeviceManager.rebootOccuredFromLastTime {
            var info = DataUsage.getTotalDataUsageInfoFromDatabase()
            info += DataUsage.currentSessionDataUsageInfo()
        }
        
    }
}

struct DataUsageInfo: Codable {
    var wifiSent: UInt32 = 0
    var wifiReceived: UInt32 = 0
    var wwanDataSent: UInt32 = 0
    var wwanDataReceived: UInt32 = 0

    private mutating func updateInfoByAdding(info: DataUsageInfo) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        
        wwanDataSent += info.wwanDataSent
        wwanDataReceived += info.wwanDataReceived
    }

    static func +=( lhs: inout DataUsageInfo, rhs: DataUsageInfo) {
        lhs.updateInfoByAdding(info: rhs)
    }
}

enum AppLaunchManager {

    // MARK: - Private Attributes
    private static let launchesCountKey = "AppLaunchesCount"


    // MARK: Public Enum Methods & Variables

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
    private static let deviceBootTimeKey = "DeviceBootTime"
    // FIXME:- maybe app delegate should call this
    static func registerForDeviceBootTime() {
        let deviceBootTime = DeviceManager.deviceCurrentBootTime
        DeviceManager.storedLastBootTime = deviceBootTime
    }
    static var deviceCurrentBootTime: Date {
        let systemUpTime = ProcessInfo.processInfo.systemUptime
        let nowTime = Date()
        let deviceBootTime = nowTime - systemUpTime
        return deviceBootTime
    }
    static var storedLastBootTime: Date {
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

    static var rebootOccuredFromLastTime: Bool {
        let deviceCurrentBootTime = DeviceManager.deviceCurrentBootTime
        let storedLastBootTime = DeviceManager.storedLastBootTime
        let timeInterval = deviceCurrentBootTime.timeIntervalSince(storedLastBootTime)
        if timeInterval > 1 {
            // FIXME:- may need to re-think
            // registerForDeviceBootTime maybe needed here
//            DeviceManager.registerForDeviceBootTime()
            DeviceManager.storedLastBootTime = deviceCurrentBootTime
            return true
        }
        return false
    }
}
// Links:
// https://stackoverflow.com/questions/1443601/how-can-i-detect-whether-the-iphone-has-been-rebooted-since-last-time-app-starte
// https://stackoverflow.com/questions/46415095/in-ios-using-swift-how-do-you-get-the-time-of-iphone-boot

