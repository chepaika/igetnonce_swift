//
//  File.swift
//  
//
//  Created by chepaika on 20.02.2022.
//

import Foundation
import os
import Clibplist
import Clibimobiledevice
import ArgumentParser

enum NormalModeError: Swift.Error, CustomStringConvertible {
    case getDeviceList(errorCode: idevice_error_t)
    case connectedDeviceNotFound
    case connectToDevice(_ uuid: String, _ errorCode: idevice_error_t)
    case cantConnectToAny
    
    public var description: String {
        switch self {
        case .getDeviceList(let errorCode):
            return "Can't get device list with error code \(errorCode.description)"
        case .connectedDeviceNotFound:
            return "No idevice connected to host"
        case .connectToDevice(let uuid, let errorCode):
            return "Can't connect to device with UUID:\(uuid), with error code \(errorCode.description)"
        case .cantConnectToAny:
            return "Can't connect to any attached idevice. See warning log for more information"
        }
    }
}

extension lockdownd_error_t: CustomStringConvertible, Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
    
    public var description: String {
        let descriptionsForErrors = [
            LOCKDOWN_E_SUCCESS:             "LOCKDOWN_E_SUCCESS",
            LOCKDOWN_E_INVALID_ARG:         "LOCKDOWN_E_INVALID_ARG",
            LOCKDOWN_E_INVALID_CONF:        "LOCKDOWN_E_INVALID_CONF",
            LOCKDOWN_E_PLIST_ERROR:         "LOCKDOWN_E_PLIST_ERROR",
            LOCKDOWN_E_PAIRING_FAILED:      "LOCKDOWN_E_PAIRING_FAILED",
            LOCKDOWN_E_SSL_ERROR:           "LOCKDOWN_E_SSL_ERROR",
            LOCKDOWN_E_DICT_ERROR:          "LOCKDOWN_E_DICT_ERROR",
            LOCKDOWN_E_RECEIVE_TIMEOUT:     "LOCKDOWN_E_RECEIVE_TIMEOUT",
            LOCKDOWN_E_MUX_ERROR:           "LOCKDOWN_E_MUX_ERROR",
            LOCKDOWN_E_NO_RUNNING_SESSION:  "LOCKDOWN_E_NO_RUNNING_SESSION",
            LOCKDOWN_E_INVALID_RESPONSE:    "LOCKDOWN_E_INVALID_RESPONSE",
            LOCKDOWN_E_MISSING_KEY:         "LOCKDOWN_E_MISSING_KEY",
            LOCKDOWN_E_MISSING_VALUE:       "LOCKDOWN_E_MISSING_VALUE",
            LOCKDOWN_E_GET_PROHIBITED:      "LOCKDOWN_E_GET_PROHIBITED",
            LOCKDOWN_E_SET_PROHIBITED:      "LOCKDOWN_E_SET_PROHIBITED",
            LOCKDOWN_E_REMOVE_PROHIBITED:   "LOCKDOWN_E_REMOVE_PROHIBITED",
            LOCKDOWN_E_IMMUTABLE_VALUE:     "LOCKDOWN_E_IMMUTABLE_VALUE",
            LOCKDOWN_E_PASSWORD_PROTECTED:  "LOCKDOWN_E_PASSWORD_PROTECTED",
            LOCKDOWN_E_USER_DENIED_PAIRING: "LOCKDOWN_E_USER_DENIED_PAIRING",
            LOCKDOWN_E_PAIRING_DIALOG_RESPONSE_PENDING: "LOCKDOWN_E_PAIRING_DIALOG_RESPONSE_PENDING",
            LOCKDOWN_E_MISSING_HOST_ID:     "LOCKDOWN_E_MISSING_HOST_ID",
            LOCKDOWN_E_INVALID_HOST_ID:     "LOCKDOWN_E_INVALID_HOST_ID",
            LOCKDOWN_E_SESSION_ACTIVE:      "LOCKDOWN_E_SESSION_ACTIVE",
            LOCKDOWN_E_SESSION_INACTIVE:    "LOCKDOWN_E_SESSION_INACTIVE",
            LOCKDOWN_E_MISSING_SESSION_ID:  "LOCKDOWN_E_MISSING_SESSION_ID",
            LOCKDOWN_E_INVALID_SESSION_ID:  "LOCKDOWN_E_INVALID_SESSION_ID",
            LOCKDOWN_E_MISSING_SERVICE:     "LOCKDOWN_E_MISSING_SERVICE",
            LOCKDOWN_E_INVALID_SERVICE:     "LOCKDOWN_E_INVALID_SERVICE",
            LOCKDOWN_E_SERVICE_LIMIT:       "LOCKDOWN_E_SERVICE_LIMIT",
            LOCKDOWN_E_MISSING_PAIR_RECORD: "LOCKDOWN_E_MISSING_PAIR_RECORD",
            LOCKDOWN_E_SAVE_PAIR_RECORD_FAILED: "LOCKDOWN_E_SAVE_PAIR_RECORD_FAILED",
            LOCKDOWN_E_INVALID_PAIR_RECORD: "LOCKDOWN_E_INVALID_PAIR_RECORD",
            LOCKDOWN_E_INVALID_ACTIVATION_RECORD: "LOCKDOWN_E_INVALID_ACTIVATION_RECORD",
            LOCKDOWN_E_MISSING_ACTIVATION_RECORD: "LOCKDOWN_E_MISSING_ACTIVATION_RECORD",
            LOCKDOWN_E_SERVICE_PROHIBITED:  "LOCKDOWN_E_SERVICE_PROHIBITED",
            LOCKDOWN_E_ESCROW_LOCKED:       "LOCKDOWN_E_ESCROW_LOCKED",
            LOCKDOWN_E_PAIRING_PROHIBITED_OVER_THIS_CONNECTION: "LOCKDOWN_E_PAIRING_PROHIBITED_OVER_THIS_CONNECTION",
            LOCKDOWN_E_FMIP_PROTECTED:      "LOCKDOWN_E_FMIP_PROTECTED",
            LOCKDOWN_E_MC_PROTECTED:        "LOCKDOWN_E_MC_PROTECTED",
            LOCKDOWN_E_MC_CHALLENGE_REQUIRED:   "LOCKDOWN_E_MC_CHALLENGE_REQUIRED",
            LOCKDOWN_E_UNKNOWN_ERROR:       "LOCKDOWN_E_UNKNOWN_ERROR"
        ]
        return descriptionsForErrors[self, default: "UNKNOW ERROR CODE \(self.rawValue)"]
    }
}

extension plist_type: CustomStringConvertible, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
    
    public var description: String {
        let descriptionsForTypes = [
            PLIST_BOOLEAN: "PLIST_BOOLEAN",
            PLIST_UINT: "PLIST_UINT",
            PLIST_REAL: "PLIST_REAL",
            PLIST_STRING: "PLIST_STRING",
            PLIST_ARRAY: "PLIST_ARRAY",
            PLIST_DICT: "PLIST_DICT",
            PLIST_DATE: "PLIST_DATE",
            PLIST_DATA: "PLIST_DATA",
            PLIST_KEY: "PLIST_KEY",
            PLIST_UID: "PLIST_UID",
            PLIST_NONE: "PLIST_NONE"
        ]
        return descriptionsForTypes[self, default: "UNKNOWN PLIST TYPE \(self.rawValue)"]
    }
}

extension idevice_error_t:CustomStringConvertible, Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue)
    }
    
    public var description: String {
        let descriptionsForErrors = [
            IDEVICE_E_SUCCESS:          "IDEVICE_E_SUCCESS",
            IDEVICE_E_INVALID_ARG:      "IDEVICE_E_INVALID_ARG",
            IDEVICE_E_UNKNOWN_ERROR:    "IDEVICE_E_UNKNOWN_ERROR",
            IDEVICE_E_NO_DEVICE:        "IDEVICE_E_NO_DEVICE",
            IDEVICE_E_NOT_ENOUGH_DATA:  "IDEVICE_E_NOT_ENOUGH_DATA",
            IDEVICE_E_SSL_ERROR:        "IDEVICE_E_SSL_ERROR",
            IDEVICE_E_TIMEOUT:          "IDEVICE_E_TIMEOUT"
        ]
        return descriptionsForErrors[self, default: "UNKNOWN IDEVICE ERROR \(self.rawValue)"]
    }
}



enum LockdownError: Swift.Error, CustomStringConvertible {
    case connect(errorCode: lockdownd_error_t)
    case getType(errorCode: lockdownd_error_t)
    case unexpectedType(lockdown_type: String)
    case getValue(key: String, errorCode: lockdownd_error_t)
    case plistUnexpectedValueType(expectedType: plist_type, resultType: plist_type)
    case emptyHarwareModel
    
    public var description: String {
        switch self {
        case .connect(let errorCode):
            return "Can't connect to lockdownd on device with error code: \(errorCode.description)"
        case .getType(let errorCode):
            return "Can't get lockdown type for device with error code: \(errorCode.description)"
        case .unexpectedType(let lockdown_type):
            return "Unexpected lockdown type: \(lockdown_type)"
        case .getValue(let key, let errorCode):
            return "Can't get value for key: \(key) with error code \(errorCode.description)"
        case .plistUnexpectedValueType(let expectedType, let resultType):
            return "The plist expected type: \(expectedType.description) but result is \(resultType.description) "
        case .emptyHarwareModel:
            return "Device hardware model is empty"
        }
    }
}
