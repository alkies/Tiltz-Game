//
//  EnterNicknameCAVCDelegate.swift
//  Titlz
//
//  Created by Kobus Swart on 2018/06/13.
//  Copyright © 2018 Kobus Swart. All rights reserved.
//

protocol EnterNicknameCAVCDelegate: class {
    func okButtonTapped(selectedOption: String, textFieldValue: String)
    func cancelButtonTapped()
}
