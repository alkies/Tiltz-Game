//
//  CustomAlertViewDelegate.swift
//  Titlz
//
//  Created by Kobus Swart on 2018/06/10.
//  Copyright © 2018 Kobus Swart. All rights reserved.
//

protocol CustomAlertViewDelegate: class {
    func okButtonTapped(selectedOption: String, textFieldValue: String)
    func cancelButtonTapped()
}
