//
//  ViewController.swift
//  Titlz
//
//  Created by Kobus Swart on 2018/06/08.
//  Copyright © 2018 Kobus Swart. All rights reserved.
//
import CoreBluetooth
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    
    @IBOutlet var myActivity: UIActivityIndicatorView!
    @IBOutlet var lb_Opponent: UILabel!
    @IBOutlet var lb_Nickname: UILabel!
    
    var deviceUUID : UUID?
    var deviceAttributes : String = ""
    var yourName : String = ""
    var customAlert: EnterNicknameCAVC!
    var timer = Timer()
    var visibleDevices = Array<Device>()
    var cachedDevices = Array<Device>()
    var cachedPeripheralNames = Dictionary<String, String>()
    var peripheralManager = CBPeripheralManager()
    var centralManager: CBCentralManager?
    var selectedPeripheral : CBPeripheral?
    var selected=0
    var listx = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userData = UserData()
        
        if (userData.name.isEmpty) {
            self.scheduledTimerWithTimeInterval()
        }
        else {
            lb_Nickname.text=userData.name
            yourName=userData.name
            centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        updateAdvertisingData()
    }
    
    @IBAction func exit_Tap(_ sender: Any) {
        exit(0)
    }
    
    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.EnterNicknameDisplayTimer), userInfo: nil, repeats: true)
    }
    
    @objc func EnterNicknameDisplayTimer(){
        timer.invalidate()
        self.displayAlertview(str :"Enter Nickname")
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return(listx.count)
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text=listx[indexPath.row]
        return(cell)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ControlVC") as! ControlVC
        vc.deviceUUID = visibleDevices[indexPath.row].peripheral.identifier
        vc.deviceAttributes = visibleDevices[indexPath.row].name
        vc.yourName = yourName
        self.present(vc, animated: true, completion: nil)
    }
    
    func displayAlertview(str :String)
    {
        customAlert = self.storyboard?.instantiateViewController(withIdentifier: "EnterNicknameCAVCID") as! EnterNicknameCAVC
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        //customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.titletext = str
        //customAlert.trysome()
        customAlert.delegate = self
        self.present(customAlert, animated: true, completion: nil)
    }
    
    func setDeviceValues() {
        
        let deviceData = deviceAttributes.components(separatedBy: "|")
        
        if (deviceData.count > 2) {
            
            self.navigationItem.title = deviceData[0]
            tableView.backgroundColor = Constants.colors[Int(deviceData[2])!]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func clearPeripherals(){
        visibleDevices = cachedDevices
        cachedDevices.removeAll()
    }
    
    @IBOutlet var tableView: UITableView!
    func updateAdvertisingData() {
        
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let userData = UserData()
        let advertisementData = String(format: "%@", userData.name)
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[Constants.SERVICE_UUID], CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
    func addOrUpdatePeripheralList(device: Device, list: inout Array<Device>) {
        
        myActivity.isHidden=true
        lb_Opponent.text = "Choose An Opponent"
        if !listx.contains(device.name)
        {
            list.append(device)
            listx.append(device.name)
            tableView?.reloadData()
        }
        else if list.contains(where: { $0.peripheral.identifier == device.peripheral.identifier
            && $0.name == "unknown"}) && device.name != "unknown" {
            
            for index in 0..<list.count {
                
                if (list[index].peripheral.identifier == device.peripheral.identifier) {
                    
                    list[index].name = device.name
                    listx[index] = device.name

                    tableView?.reloadData()
                    break
                }
            }
            
        }
    }
    
    func initService() {
        
        let serialService = CBMutableService(type: Constants.SERVICE_UUID, primary: true)
        let rx = CBMutableCharacteristic(type: Constants.RX_UUID, properties: [CBCharacteristicProperties.notify, CBCharacteristicProperties.read , CBCharacteristicProperties.write], value: nil, permissions: Constants.RX_PERMISSIONS)
        serialService.characteristics = [rx]
        
        peripheralManager.add(serialService)
    }

}

extension ViewController : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn){
            updateAdvertisingData()
        }
        
    }
}

extension ViewController : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            
            self.centralManager?.scanForPeripherals(withServices: [Constants.SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        var peripheralName = cachedPeripheralNames[peripheral.identifier.description] ?? "unknown"
        
        if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            peripheralName = advertisementName
            cachedPeripheralNames[peripheral.identifier.description] = peripheralName
        }
        
        let device = Device(peripheral: peripheral, name: peripheralName)
        
        self.addOrUpdatePeripheralList(device: device, list: &visibleDevices)
        self.addOrUpdatePeripheralList(device: device, list: &cachedDevices)

    }
}



extension ViewController: EnterNicknameCAVCDelegate{
    func cancelButtonTapped() {
        
    }
    
    func okButtonTapped(selectedOption: String, textFieldValue: String) {
        print("okButtonTapped with \(selectedOption) option selected")
        print("TextField has value: \(textFieldValue)")
        var userData = UserData()
        let name : String = textFieldValue   //tb_nickname.text ?? ""
        lb_Nickname.text=name
        userData.name = name
        userData.save()
        
        if (userData.name.isEmpty) {
            
        }
        else {
            centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
            
        }
        customAlert.removeView()
    }
    
}


