//
//  main.swift
//
//  Created by chepaika on 23.12.2021.
//

import Foundation
import ArgumentParser
import os

// TODO deinit coplex types

@main
@available(macOS 11.0, *)
struct IGetNonce: ParsableCommand
{
    static let configuration = CommandConfiguration(abstract: """
Get ApNonce and SEPNonce from ios devices.
For geting nonce in recovery mod - specify ECID
For normal mode just plug and unlock iDevice and run :)
""")
    
    @Option(help: "ECID in hex or dec string format")
    var ECID: String = ""    
        
    func run() throws {
        let logger = Logger()
        
        var deviceInfo: GetDeviceInfo? = nil
        
        let ecid = self.getECID()
        
        if ecid != nil {
            do {
                let msg = "Trying to connect to device with ECID:\(ecid!.description) in recovery or DFU mode"
                print(msg)
                logger.info("\(msg)")
                deviceInfo = try RecoveryMode(ecid: ecid!)
            }
            catch let error as RecoveryModeErrors {
                let msg = "Can't connect to recovery mod with error: \(error.description)"
                print("ERROR: \(msg)")
                logger.error("\(msg)")
                return
            }
        } else {
            do {
                var msg = "Trying to connect to any device in normal mode"
                print(msg)
                logger.info("\(msg)")
                deviceInfo = try IdeviceNormalMode()
                msg = "Connected to device with ECID: \(deviceInfo!.ECID!) in normal mode"
                print(msg)
                logger.info("\(msg)")
                msg = "Getting a ApNonce in normal mode will overwrite the generator in NVRAM!"
                print("WARNING: \(msg)")
                logger.warning("\(msg)")
                if !IGetNonce.isContineuDialog() {
                    return
                }
            }
            catch let error as NormalModeError {
                let msg = "Can't connect to device in normal mode with error: \(error.description)"
                print("ERROR: \(msg)")
                logger.error("\(msg)")
            }
        }
        
        guard let _ = deviceInfo else {
            let msg = "Can't connect to device in any modes"
            print("ERROR: \(msg)")
            logger.error("\(msg)")
            return
        }
        
        let apNonce = deviceInfo!.apNonce
        let sepNonce = deviceInfo!.sepNonce
        
        guard apNonce != nil, sepNonce != nil else {
            let msg = "Can't get nonce for device((. See log for more information"
            print("ERROR: \(msg)")
            logger.error("\(msg)")
            return
        }
        
        print("ApNonce:   \(apNonce!)")
        logger.info("ApNonce:   \(apNonce!)")
        print("SEPNonce:  \(sepNonce!)")
        logger.info("SEPNonce:  \(sepNonce!)")
    }
    
    private func getECID() -> UInt64? {
        let logger = Logger()
        guard !self.ECID.isEmpty else {
            return nil
        }
        
        let ecid = UInt64(self.ECID) ?? UInt64(self.ECID, radix: 16)
        
        guard ecid != nil else {
            let msg = "Invalid ECID format \(self.ECID)"
            print("WARNING: \(msg)")
            logger.warning("\(msg)")
            return nil
        }
        return ecid
    }
    
    private static func isContineuDialog() -> Bool {
        
        print("Continue anyway? [y/n] : ")
        while true {
            let userInput = readLine()
            guard userInput != nil else {
                return false
            }
            
            switch userInput!.lowercased() {
            case "y":
                return true
            case "n":
                return false
            default:
                print("Please write [y/n]")
                continue
            }
        }
    }
}
