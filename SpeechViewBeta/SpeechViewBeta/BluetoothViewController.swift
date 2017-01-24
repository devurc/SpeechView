//
//  BluetoothViewController.swift
//  SpeechViewBeta
//
//  Created by Eric Horng on 11/28/16.
//  Copyright © 2016 Eric Horng. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var manager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    //let DEVICE_NAME = "BlueView"
    let DEVICE_NAME = "Adafruit Bluefruit LE"
    
    let UART_SVC_UUID = CBUUID(string:"6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let TX_CHAR_UUID = CBUUID(string:"6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let RX_CHAR_UUID = CBUUID(string:"6E400003-B5A3-F393-E0A9-E50E24DCCA9E")

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startScanning(_ sender: Any) {
        // Start scanning?
        // This method might not be necessary
    }
    
    /** @brief Call back for CBCentralManager initializer
     *
     *  @function Scan for devices
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOn:
            // Testing general scan capabilities
            central.scanForPeripherals(withServices: nil, options: nil)
            
            // This should allow filtering by devices advertising UART_SVC_UUID
            //central.scanForPeripherals(withServices: [UART_SVC_UUID], options: nil)
        case .poweredOff:
            print("Bluetooth is currently powered off.")
        case .unauthorized:
            print("The app is unauthorized to use Bluetooth Low Energy.")
        case .unsupported:
            print("This platform does not support Bluetooth Low Energy")
        case .resetting:
            print("The connection with the system service was momentarily lost")
        case .unknown:
            print("The current state of the Bluetooth Manager is unknown.")
        }
    }
    
    /** @brief Connect to a device
     *
     */
    private func centralManager(
            central: CBCentralManager,
            didDiscoverPeripheral peripheral: CBPeripheral,
            advertisementData: [String : AnyObject],
            RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        // Connect based on device name for now.
        if device?.contains(DEVICE_NAME) == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
        }
    }
    /** @brief Discover the services on the device
     *
     */
    func centralManager(
            central: CBCentralManager,
            didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    /** @brief Discover the charcteristics for the UART Service
     *
     */
    private func peripheral(
            peripheral: CBPeripheral,
            didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid == UART_SVC_UUID {
                peripheral.discoverCharacteristics(
                    nil,
                    for: thisService
                )
            }
        }
    }
    
    /** @brief Enable Notifications for the Transfer Characteristic
     *
     */
    private func peripheral(
            peripheral: CBPeripheral,
            didDiscoverCharacteristicsForService service: CBService,
            error: NSError?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == TX_CHAR_UUID {
                self.peripheral.setNotifyValue(
                    true,
                    for: thisCharacteristic
                )
            }
        }
    }
    
    /** @brief Callback for when notifications of changes occur
     *
     */
    private func peripheral(
            peripheral: CBPeripheral,
            didUpdateValueForCharacteristic characteristic: CBCharacteristic,
            error: NSError?) {
            var count:UInt32 = 0;
        
        
        if characteristic.uuid == TX_CHAR_UUID {
            //characteristic.value!.copyBytes(to: &count, count: MemoryLayout<UInt32>.size)
            
            // Needs a UIText field for this output
            //labelCount.text =
            //    NSString(format: "%llu", count) as String
        }
    }
    
    /** @brief Disconnect and rescan
     *
     */
    private func centralManager(
            central: CBCentralManager,
            didDisconnectPeripheral peripheral: CBPeripheral,
            error: NSError?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
