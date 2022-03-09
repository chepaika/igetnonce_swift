//
//  recovery.swift
//  igetnonce_swift
//
//  Created by chepaika on 27.12.2021.
//

import Foundation
import Clibirecovery
import os

extension irecv_error_t: CustomStringConvertible {
    public var description: String {
        switch self {
        case IRECV_E_SUCCESS:
            return "IRECV_E_SUCCESS"
        case IRECV_E_NO_DEVICE:
            return "IRECV_E_NO_DEVICE"
        case IRECV_E_OUT_OF_MEMORY:
            return "IRECV_E_OUT_OF_MEMORY"
        case IRECV_E_UNABLE_TO_CONNECT:
            return "IRECV_E_UNABLE_TO_CONNECT"
        case IRECV_E_INVALID_INPUT:
            return "IRECV_E_INVALID_INPUT"
        case IRECV_E_FILE_NOT_FOUND:
            return "IRECV_E_FILE_NOT_FOUND"
        case IRECV_E_USB_UPLOAD:
            return "IRECV_E_USB_UPLOAD"
        case IRECV_E_USB_STATUS:
            return "IRECV_E_USB_STATUS"
        case IRECV_E_USB_INTERFACE:
            return "IRECV_E_USB_INTERFACE"
        case IRECV_E_USB_CONFIGURATION:
            return "IRECV_E_USB_CONFIGURATION"
        case IRECV_E_PIPE:
            return "IRECV_E_PIPE"
        case IRECV_E_TIMEOUT:
            return "IRECV_E_TIMEOUT"
        case IRECV_E_UNSUPPORTED:
            return "IRECV_E_UNSUPPORTED"
        case IRECV_E_UNKNOWN_ERROR:
            return "IRECV_E_UNKNOWN_ERROR"
        default:
            return "UNKNOWN ERROR"
        }
    }
}




enum RecoveryModeErrors: Swift.Error, CustomStringConvertible
{
    case openDevice(ecid: UInt64, errorCode: irecv_error_t)
    case getMode(errorCode: irecv_error_t)
    case getDeviceInfo(errorCode: irecv_error_t)
    case deviceDBQueryError(errorCode: irecv_error_t)
    case getRecoveryDevInfo
    
    public var description: String {
        switch self {
        case .openDevice(let ecid, let errorCode):
            return "Failed open device with ECID: \(ecid), with error code: \(errorCode.description)"
        case .getMode(let errorCode):
            return "Failed get device recovery mode info with error code: \(errorCode.description)"
        case .getDeviceInfo(let errorCode):
            return "Failed get device info with error code: \(errorCode.description)"
        case .deviceDBQueryError(let errorCode):
            return "Failed get info from device database with error code: \(errorCode.description)"
        case .getRecoveryDevInfo:
            return "Can't get recovery device info"
        }
    }
}

@available(macOS 11.0, *)
class RecoveryMode: GetDeviceInfo {
    
    public lazy var deviceInfo: DeviceInfo?  = try! RecoveryMode.errorHandler(){
        var rawDeviceInfo: irecv_device_t?
        let recError = irecv_devices_get_device_by_client(_client, &rawDeviceInfo)
        guard recError == IRECV_E_SUCCESS else {
            throw RecoveryModeErrors.getDeviceInfo(errorCode: recError)
        }
        return DeviceInfo(irecvDevice: rawDeviceInfo!)
    }
    public lazy var apNonce: String? = self._recoveryDeviceInfo?.apNonce
    public lazy var sepNonce: String? = self._recoveryDeviceInfo?.sepNonce
    public var ECID: UInt64? {
        get { self._ecid }
    }
    public lazy var isRecovery: Bool? = try! RecoveryMode.errorHandler(){
        var mode: Int32 = 0
        let recError = irecv_get_mode(self._client, &mode)
        guard recError == IRECV_E_SUCCESS else {
            throw RecoveryModeErrors.getMode(errorCode: recError)
        }
        
        if mode == IRECV_K_DFU_MODE.rawValue || mode == IRECV_K_WTF_MODE.rawValue {
            return false
        }
        return true
    }
    
    public lazy var isDFU: Bool? = try! RecoveryMode.errorHandler(){
        var mode: Int32 = 0
        let recError = irecv_get_mode(self._client, &mode)
        guard recError == IRECV_E_SUCCESS else {
            throw RecoveryModeErrors.getMode(errorCode: recError)
        }
        
        return mode == IRECV_K_DFU_MODE.rawValue
    }
    
    
    private var _ecid: UInt64
    private var _client:irecv_client_t
    private lazy var _recoveryDeviceInfo: RecoveryDeviceInfo? = try! RecoveryMode.errorHandler(originalFunc: getRecoveriDeviceInfo)
    
    public init(ecid: UInt64) throws {
        self._ecid = ecid
        var recoveryClient: irecv_client_t?
        let recError = irecv_open_with_ecid(&recoveryClient, self._ecid)
        guard  recError == IRECV_E_SUCCESS else {
            throw RecoveryModeErrors.openDevice(ecid: self._ecid, errorCode: recError)
        }
        
        self._client = recoveryClient!
    }
    
    deinit {
        irecv_close(self._client)
    }
    
    
    private func getRecoveriDeviceInfo() throws -> RecoveryDeviceInfo {
        let rawRecDevInfo = irecv_get_device_info(self._client)
        
        guard let _ = rawRecDevInfo else {
            throw RecoveryModeErrors.getRecoveryDevInfo
        }
        
        return RecoveryDeviceInfo(rawRecoveryDeviceInfo: rawRecDevInfo!.pointee)
    }
    
    private class func errorHandler<Result>(originalFunc: () throws->Result) throws -> Result? {
        let logger = Logger()
        do {
            return try originalFunc()
        }
        catch let error as RecoveryModeErrors {
            logger.error("\(error.description)")
        }
        catch {
            logger.critical("Unexpected exception: \(error.localizedDescription)")
            throw error
        }
        return nil
    }
    
}
