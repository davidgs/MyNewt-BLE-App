//
//  ViewController.swift
//  SwiftSensorTag
//
//  Created by Anas Imtiaz on 13/11/2015.
//  Copyright © 2015 Anas Imtiaz. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // Title labels
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressAnim: UIActivityIndicatorView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var RSSIlevel: UIImageView!
    
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var sensorView: UIView!
    // BLE
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    @IBOutlet weak var sensorViewItem: UIBarButtonItem!
    @IBOutlet weak var configViewItem: UIBarButtonItem!
    // Table View
    var sensorTagTableView : UITableView!
    
    // Sensor Values
    var myNewtSensors : [MyNewtSensor] = []

    var objectTemperature : Double!
    
    var  isScanning : Bool = false
    var isConnected  : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sensorViewItem.setValue(false, forKey: "Enabled")
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Set up table view
        setupSensorTagTableView()
        self.progressAnim.startAnimating()
        
    }
    @IBAction func showConfigurationView(sender: AnyObject) {
    }
    @IBAction func showSensorView(sender: AnyObject) {
    }
    
    @IBAction func connectButtonAction(sender: AnyObject) {
        if(sensorTagPeripheral.state == CBPeripheralState.Connected){
            centralManager.cancelPeripheralConnection(sensorTagPeripheral)
            self.RSSIlevel.image = UIImage(named: "NoSignal-sm")
            self.connectButton.setTitle("Scan For MyNewt", forState: UIControlState.Normal)
            self.isConnected = false
            self.isScanning = false
            self.deviceNameLabel.text = "None"
            self.myNewtSensors = []
            self.tearDownSensorTagTableView()
        } else if(self.isScanning){
            centralManager.stopScan()
            self.progressAnim.stopAnimating()
            self.RSSIlevel.image = UIImage(named: "NoSignal-sm")
            self.connectButton.setTitle("Scan For MyNewt", forState: UIControlState.Normal)
            self.isConnected = false
            self.isScanning = false
        }else {
            // start scanning
            self.setupSensorTagTableView()
            self.progressAnim.startAnimating()
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            self.connectButton.setTitle("Stop Scan", forState: UIControlState.Normal)
            self.isScanning = true

        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /******* CBCentralManagerDelegate *******/
     
     // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            self.statusLabel.text = "Scanning ..."
        }
        else {
            // Can have different conditions for all states if needed - show generic alert for now
            self.showAlertWithText("Error", message: "Bluetooth switched off or not initialized")
        }
    }
    
    
    // Check out the discovered peripherals to find a MyNewt Device
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if SensorTag.sensorTagFound(advertisementData) == true {
            // Update Status Label
            self.statusLabel.text = "Mynewt Device Found"
            self.progressAnim.stopAnimating()
            // Stop scanning, set as the peripheral to use and establish connection
            self.centralManager.stopScan()
            self.isScanning = false
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            //self.statusLabel.text = "Mynewt Device NOT Found"
            //showAlertWithText(header: "Warning", message: "SensorTag Not Found")
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.statusLabel.text = "Discovering services"
        peripheral.discoverServices(nil)
    }
    
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.statusLabel.text = "Disconnected"
        self.isConnected = false
        
    }
    
    /******* CBCentralPeripheralDelegate *******/
     
     // Check if the service discovered is valid
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            if SensorTag.validService(thisService) {
                // Discover characteristics of all valid services
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        self.statusLabel.text = "Enabling sensors"
        
        for charateristic in service.characteristics! {
            let thisCharacteristic = charateristic as CBCharacteristic
            if SensorTag.validDataCharacteristic(thisCharacteristic) {
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            if SensorTag.validConfigCharacteristic(thisCharacteristic) {
                peripheral.readValueForCharacteristic(thisCharacteristic)
            }
        }
        self.progressAnim.stopAnimating()
        self.isConnected = true
        isScanning = false
        self.connectButton.setTitle("Disconnect MyNewt", forState: UIControlState.Normal)
        
    }
    
    
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        self.statusLabel.text = "Connected"
        self.deviceNameLabel.text = SensorTag.getDeviceName()
        
        peripheral.readRSSI()
        let charType = characteristic.UUID.UUIDString.substringToIndex(characteristic.UUID.UUIDString.startIndex.advancedBy(2))
        
        let charVal = characteristic.UUID.UUIDString.substringFromIndex(characteristic.UUID.UUIDString.startIndex.advancedBy(2))
        let uuid = characteristic.UUID.UUIDString
        var seen : Bool = false
        // self.readRSSI()
        for i in 0..<myNewtSensors.count {
            if(myNewtSensors[i].containsValue(uuid)) {
                seen = true
                myNewtSensors[i].updateValue(uuid, value: characteristic.value!)
                myNewtSensors[i].setValue(SensorTag.getAmbientTemperature(characteristic.value! as NSData), forKey: "sensorValue")
            }
        }
        if(!seen){
            // never seen this before
            switch charType {
            case "DE":
                let newSensor = MyNewtSensor(sensorName: String(data: characteristic.value!, encoding: NSUTF8StringEncoding)!, nUUID : characteristic.UUID.UUIDString, dUUID : "BE" + charVal, sensorValue : 0.00)
                myNewtSensors.append(newSensor)
                print(myNewtSensors[myNewtSensors.count-1])
            default:
                break
            }
            
        }

        self.sensorTagTableView?.reloadData()
    }
    
    func peripheralDidUpdateRSSI(peripheral: CBPeripheral, error: NSError?) {
        let rssi = abs((peripheral.RSSI?.intValue)! )
        print("RSSI: \(peripheral.RSSI?.intValue)")
        if(rssi < 70){
            self.RSSIlevel.image = UIImage(named: "FourBars-sm")!
        } else if (rssi < 80) {
            self.RSSIlevel.image = UIImage(named: "ThreeBars-sm")!
        } else if (rssi < 90) {
            self.RSSIlevel.image = UIImage(named: "TwoBars-sm")!
        } else if(rssi < 100) {
            self.RSSIlevel.image = UIImage(named: "OneBar-sm")!
        } else {
            self.RSSIlevel.image = UIImage(named: "NoSignal-sm")!
        }

    }
    
    
    
    
    
    
    
    /******* Helper *******/
     
     // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alert.view.tintColor = UIColor.redColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // Set up Table View
    func setupSensorTagTableView () {
        
        self.sensorTagTableView = UITableView()
        self.sensorTagTableView.delegate = self
        self.sensorTagTableView.dataSource = self
        
        
        self.sensorTagTableView.frame = CGRect(x: self.sensorView.bounds.origin.x, y: self.sensorView.bounds.origin.y, width: self.sensorView.bounds.width , height: self.sensorView.bounds.height)
        self.sensorTagTableView.registerClass(SensorTagTableViewCell.self, forCellReuseIdentifier: "sensorTagCell")
        
        self.sensorTagTableView.tableFooterView = UIView() // to hide empty lines after cells
        self.sensorView.addSubview(self.sensorTagTableView)
    }
    
    // Tear down tableView
    func tearDownSensorTagTableView(){
        self.sensorTagTableView.removeFromSuperview()
        self.sensorTagTableView = nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myNewtSensors.count
    }
    
    
    /******* UITableViewDelegate *******/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let thisCell = tableView.dequeueReusableCellWithIdentifier("sensorTagCell", forIndexPath: indexPath) as! SensorTagTableViewCell
        print("Setting Label for row: \(indexPath.row) to: \(myNewtSensors[indexPath.row].sensorLabel)")
        thisCell.sensorNameLabel.text  = myNewtSensors[indexPath.row].sensorLabel
        thisCell.sensorValueLabel.text = String(format: "%.2f", myNewtSensors[indexPath.row].sensorValue)
        
        return thisCell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

}



