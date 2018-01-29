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
        var pointer = interfaceAddress
        while pointer != nil {
            // get the datausage info
            guard let info = DataUsage.dataUsageInfo(from: pointer!) else {
                pointer = pointer?.pointee.ifa_next
                continue
            }
            dataUsageInfo.updateInfoByAdding(info: info)
            pointer = pointer?.pointee.ifa_next
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

}

struct DataUsageInfo {
    var wifiSent: UInt32 = 0
    var wifiReceived: UInt32 = 0
    var wwanDataSent: UInt32 = 0
    var wwanDataReceived: UInt32 = 0

    mutating func updateInfoByAdding(info: DataUsageInfo) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        
        wwanDataSent += info.wwanDataSent
        wwanDataReceived += info.wwanDataReceived
    }
}
