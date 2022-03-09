//
//  normal.swift
//  
//
//  Created by chepaika on 21.01.2022.
//


import Foundation
import os 
import Clibimobiledevice
import Clibplist
import Clibirecovery


@available(macOS 11.0, *)
class IdeviceNormalMode: GetDeviceInfo {
    
    public lazy var deviceInfo: DeviceInfo?  = try! IdeviceNormalMode.errorHandler(originalFunc: getRecoveryDeviceInfo)
    public lazy var apNonce: String? = try! IdeviceNormalMode.errorHandler(originalFunc: getApNonce)
    public lazy var sepNonce: String? = try! IdeviceNormalMode.errorHandler(originalFunc: getSpNonce)
    public lazy var ECID: UInt64? = try! IdeviceNormalMode.errorHandler(originalFunc: getECID)
    
    private let logger = Logger()
    private var device: idevice_t;
    private let uuid: String
    
    public init() throws {
        var rawDevices : UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?
        var count: Int32 = 0
        var ideviceResult = idevice_get_device_list(&rawDevices, &count)
        guard ideviceResult == IDEVICE_E_SUCCESS else {
            throw NormalModeError.getDeviceList(errorCode: ideviceResult)
        }
        
        defer {
            for i in 0..<Int(count) {
                rawDevices![i]!.deallocate()
            }
            rawDevices!.deallocate()
        }
        
        guard count > 0 else {
            throw NormalModeError.connectedDeviceNotFound
        }
        
        // Prevent EXC_BAD_ACCESS
        sleep(1)
        
        let uuidOfConnectedDevices = Array<String>(unsafeUninitializedCapacity: Int(count), initializingWith: { buffer, initializedCount in
            for i in 0..<Int(count) {
                buffer[i] = String(cString: rawDevices![i]!)
            }
            initializedCount = Int(count)
        })
            
        for device_uuid in uuidOfConnectedDevices {
            var idevice: idevice_t?
            ideviceResult = device_uuid.withCString { idevice_new(&idevice, $0)}
            guard ideviceResult == IDEVICE_E_SUCCESS else {
                logger.warning("\(String(describing: NormalModeError.connectToDevice(device_uuid, ideviceResult)))")
                continue
            }
            
            

            do {
                self.device = idevice!
                try IdeviceNormalMode.checkLockdown(device: self.device)
                self.uuid = device_uuid
                return
            }
            catch let err as LockdownError {
                logger.warning("\(err.description)")
                idevice_free(idevice!)
                continue
            }
        }
        
        throw NormalModeError.cantConnectToAny
    }
    
    deinit{
        idevice_free(self.device)
    }
    
    private func getRecoveryDeviceInfo() throws -> DeviceInfo {
        let lockdownClient = try IdeviceNormalMode.getLockdownClient(device: self.device)
        defer {
            idevice_free(lockdownClient)
        }
        
        var hardwareModelPlist: plist_t?
        let hardvareModelKey = "HardwareModel"
        let lockdownError = lockdownd_get_value(lockdownClient, nil, hardvareModelKey, &hardwareModelPlist);
        guard lockdownError == LOCKDOWN_E_SUCCESS, let _ = hardwareModelPlist else {
            throw LockdownError.getValue(key: hardvareModelKey, errorCode: lockdownError)
        }
        defer {
            plist_free(hardwareModelPlist)
        }
        
        let nodeType = plist_get_node_type(hardwareModelPlist)
        guard nodeType == PLIST_STRING else {
            throw LockdownError.plistUnexpectedValueType(expectedType: PLIST_STRING, resultType: nodeType)
        }
        
        var rawModel: UnsafeMutablePointer<CChar>?
        plist_get_string_val(hardwareModelPlist, &rawModel)
        guard let _ = rawModel else {
            throw LockdownError.emptyHarwareModel
        }
        defer {
            rawModel!.deallocate()
        }
        
        var irecvDevice: irecv_device_t?
        let irecError = irecv_devices_get_device_by_hardware_model(rawModel!, &irecvDevice)
        guard irecError == IRECV_E_SUCCESS, let _ = irecvDevice else {
            throw RecoveryModeErrors.deviceDBQueryError(errorCode: irecError)
        }
        
        
        return DeviceInfo(irecvDevice: irecvDevice!)
    }
        
    private func getECID() throws -> UInt64 {
        let lockdownClient = try IdeviceNormalMode.getLockdownClient(device: self.device)
        defer {
            idevice_free(lockdownClient)
        }
        
        var chipIdPlist: plist_t?
        let chip_id_key = "UniqueChipID"
        let lockdownError = lockdownd_get_value(lockdownClient, nil, chip_id_key, &chipIdPlist)
        guard lockdownError == LOCKDOWN_E_SUCCESS, let _ = chipIdPlist else {
            throw LockdownError.getValue(key: chip_id_key, errorCode: lockdownError)
        }
        
        defer {
            plist_free(chipIdPlist)
        }
        
        let nodeType = plist_get_node_type(chipIdPlist)
        guard nodeType == PLIST_UINT else {
            throw LockdownError.plistUnexpectedValueType(expectedType: PLIST_UINT, resultType: nodeType)
        }
        
        var currentEcid: UInt64  = 0
        
        plist_get_uint_val(chipIdPlist, &currentEcid);
        return currentEcid
    }
    
    private func getApNonce() throws -> String {
        return try getNonceByKey(key: "ApNonce")
    }
    
    private func getSpNonce() throws -> String {
        return try getNonceByKey(key: "SEPNonce")
    }
    
    private func getNonceByKey(key: String) throws -> String {
        let lockdownClient = try IdeviceNormalMode.getLockdownClient(device: self.device)
        defer {
            idevice_free(lockdownClient)
        }
        var noncePlist: plist_t?
        let lockdownError = lockdownd_get_value(lockdownClient, nil, key, &noncePlist)
        guard lockdownError == LOCKDOWN_E_SUCCESS, let _ = noncePlist else {
            throw LockdownError.getValue(key: key, errorCode: lockdownError)
        }
        
        defer {
            plist_free(noncePlist)
        }
        
        let nodeType = plist_get_node_type(noncePlist)
        guard nodeType == PLIST_DATA else {
            throw LockdownError.plistUnexpectedValueType(expectedType: PLIST_DATA, resultType: nodeType)
        }
        
        var data: UnsafeMutablePointer<CChar>?
        var size: UInt64 = 0
        
        plist_get_data_val(noncePlist, &data, &size)
        defer {
            data?.deallocate()
        }
        
        let result = data?.withMemoryRebound(to: UInt8.self, capacity: Int(size)) { ptr -> String in
            var result = ""
            for i in 0..<Int(size) {
                result += String(format: "%02hhx", ptr[i])
            }
            return result
        }
        
        return result!
    }
    
    private class func getLockdownClient(device: idevice_t) throws -> lockdownd_client_t {
        var lockdown_client: lockdownd_client_t?
        var lockdown_error = lockdownd_client_new_with_handshake(device, &lockdown_client, "idevicerestore");
        if lockdown_error != LOCKDOWN_E_SUCCESS {
            lockdown_error = lockdownd_client_new(device, &lockdown_client, "idevicerestore");
            if lockdown_error != LOCKDOWN_E_SUCCESS {
                throw LockdownError.connect(errorCode: lockdown_error)
            }
        }
        
        return lockdown_client!
    }
    
    private class func checkLockdown(device: idevice_t) throws {
        let lockdown_client = try IdeviceNormalMode.getLockdownClient(device: device)
        
        defer {
            lockdownd_client_free(lockdown_client)
        }
        
        var lockdown_type_raw : UnsafeMutablePointer<CChar>! = nil
        
        let lockdown_res = lockdownd_query_type(lockdown_client, &lockdown_type_raw)
        guard lockdown_res == LOCKDOWN_E_SUCCESS else {
            throw LockdownError.getType(errorCode: lockdown_res)
        }
        
        defer {
            lockdown_type_raw.deallocate()
        }
        
        let lockdown_type = String(cString: lockdown_type_raw)
        
        if lockdown_type !=  "com.apple.mobile.lockdown" {
            throw LockdownError.unexpectedType(lockdown_type: lockdown_type)
        }
    }
    
    private class func errorHandler<Result>(originalFunc: () throws->Result) throws -> Result? {
        let logger = Logger()
        do {
            return try originalFunc()
        }
        catch let error as LockdownError {
            logger.error("\(error.description)")
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
