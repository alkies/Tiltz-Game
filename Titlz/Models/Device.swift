//
//  Device.swift
//  Titlz
//
//  Created by Kobus Swart on 2018/06/08.
//  Copyright © 2018 Kobus Swart. All rights reserved.
//

import CoreBluetooth

struct Device {
    
    var peripheral : CBPeripheral
    var name : String
    var messages = Array<String>()
    
    init(peripheral: CBPeripheral, name:String) {
        self.peripheral = peripheral
        self.name = name
    }
}
