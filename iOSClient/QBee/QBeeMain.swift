//
//  Main.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
import UIKit
import Foundation
class QBeeMain: UIViewController {
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var CreateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginButton.layer.cornerRadius=12.0
        LoginButton.layer.borderColor=UIColor.black.cgColor
        LoginButton.layer.borderWidth=0.5
        CreateButton.layer.cornerRadius=12.0
       
    }
    
    @IBAction func LoginButtonTouchUpInside(_ sender: Any) {
        
    }
    
    @IBAction func CreateYourAccountTouchUpInside(_ sender: Any) {
        
    }
}
//MARK:-
//MARK:END
