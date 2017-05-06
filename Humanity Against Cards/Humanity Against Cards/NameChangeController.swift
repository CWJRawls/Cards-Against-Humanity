//
//  NameChangeController.swift
//  Humanity Against Cards
//
//  Created by Connor Rawls on 5/4/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation
import UIKit

class NameChangeController : UIViewController {
    
    @IBOutlet var nameField : UITextField!
    
    var name : String!
    
    var row : Int!
    
    var tableView : ViewController!
    
    let botLoader = BotLoader() //for generating a random name from a list
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = name
    }
    
    //set the value of team name when the field has been changed
    @IBAction func teamNameChanged(_ sender: UITextField)
    {
        if let text = sender.text {
            tableView.reloadCell(for: row, with: text)
        }
        else{
            sender.text = name
        }
    }
    
    //get rid of the keyboard when we tap away
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer)
    {
        nameField.resignFirstResponder()
    }
    
    @IBAction func getRandomName(_ sender: UIButton) {
        name = botLoader.getName()
        
        nameField.text = name
        
        tableView.reloadCell(for: row, with: name)
    }
}
