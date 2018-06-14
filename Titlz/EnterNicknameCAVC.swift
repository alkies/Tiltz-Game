//
//  EnterNicknameCAVC.swift
//  Titlz
//
//  Created by Kobus Swart on 2018/06/13.
//  Copyright © 2018 Kobus Swart. All rights reserved.
//

import UIKit


class EnterNicknameCAVC: UIViewController {

    
    @IBOutlet var tb_Nickname: UITextField!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var alertView: UIView!
    
    var titletext = ""
    var delegate: EnterNicknameCAVCDelegate?
    var selectedOption = "First"
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titletext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    func trysome()
    {
        
    }
    
    @IBAction func okay_Tap(_ sender: Any) {
        tb_Nickname.resignFirstResponder()
        delegate?.okButtonTapped(selectedOption: selectedOption, textFieldValue: tb_Nickname.text!)
        self.dismiss(animated: true, completion: nil)
    }
    func removeView()
    {
        self.dismiss(animated: true, completion: nil)
    }
}
