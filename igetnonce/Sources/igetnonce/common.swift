//
//  common.swift
//  igetnonce
//
//  Created by chepaika on 27.12.2021.
//

import Foundation
import Clibirecovery

protocol GetDeviceInfo {
    var deviceInfo: DeviceInfo? { get }
    var apNonce: String? { get }
    var sepNonce: String? { get }
    var ECID: UInt64? { get }
}

struct DeviceInfo {
    let productType: String
    let hardwareModel: String
    let boardId: UInt32
    let chipId: UInt32
    let displayName: String
    
    init(irecvDevice:irecv_device_t) {
        self.productType = String(cString: irecvDevice.pointee.product_type)
        self.hardwareModel = String(cString: irecvDevice.pointee.hardware_model)
        self.boardId = irecvDevice.pointee.board_id
        self.chipId = irecvDevice.pointee.chip_id
        self.displayName = String(cString: irecvDevice.pointee.display_name)
    }
}

struct RecoveryDeviceInfo {
    let cpid: UInt32
    let cprv: UInt32
    let cpfm: UInt32
    let scep: UInt32
    let bdid: UInt32
    let ecid: UInt64
    let ibfl: UInt32
    let srnm: String
    let imei: String
    let srtg: String
    let serialString: String
    let apNonce: String
    let sepNonce: String
    
    init(rawRecoveryDeviceInfo: irecv_device_info) {
        self.cpid = rawRecoveryDeviceInfo.cpid
        self.cprv = rawRecoveryDeviceInfo.cprv
        self.cpfm = rawRecoveryDeviceInfo.cpfm
        self.scep = rawRecoveryDeviceInfo.scep
        self.bdid = rawRecoveryDeviceInfo.bdid
        self.ecid = rawRecoveryDeviceInfo.ecid
        self.ibfl = rawRecoveryDeviceInfo.ibfl
        self.srnm = String(cString: rawRecoveryDeviceInfo.srnm)
        self.imei = rawRecoveryDeviceInfo.imei != nil ?  String(cString: rawRecoveryDeviceInfo.imei) : ""
        self.srtg = rawRecoveryDeviceInfo.srtg != nil ? String(cString: rawRecoveryDeviceInfo.srtg) : ""
        self.serialString = String(cString: rawRecoveryDeviceInfo.serial_string)
        
        self.apNonce = {
            var result = ""
            for i in 0..<Int(rawRecoveryDeviceInfo.ap_nonce_size) {
                result += String(format: "%02hhx", rawRecoveryDeviceInfo.ap_nonce[i])
            }
            return result
        }()
        
        self.sepNonce = {
            var result = ""
            for i in 0..<Int(rawRecoveryDeviceInfo.sep_nonce_size) {
                result += String(format: "%02hhx", rawRecoveryDeviceInfo.sep_nonce[i])
            }
            return result
        }()
    }
}
