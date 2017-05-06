//
//  ViewController.swift
//  Humanity Against Cards
//
//  Created by Connor Rawls on 5/4/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var playerNames: [String] = [String]()
    let botLoader = BotLoader()
    var botCount : Int = 0
    
    
    @IBOutlet var botSlider : UISlider!
    @IBOutlet var botLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        let insets = UIEdgeInsets(top: statusBarHeight, left: 0, bottom: 0, right: 0)
        
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        botSlider.minimumValue = 3.0
        botLabel.text = "Bots: \(Int(botSlider.value))"
    }

    //the edit button is pressed
    @IBAction func toggleEditingMode(_ sender: UIButton)
    {
        print("Edit Pressed")
        if isEditing {
            sender.setTitle("Edit", for: .normal)
            setEditing(false, animated: true)
        }
        else {
            sender.setTitle("Done", for: .normal)
            setEditing(true, animated: true)
        }
    }
    
    //when the add button is pressed
    @IBAction func addNewItem(_ sender: UIButton)
    {
        
        playerNames.append("Player \(playerNames.count)")
        
            
        let indexPath = IndexPath(row: playerNames.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        var minBots = 3 - playerNames.count
        
        if minBots < 0 {
            minBots = 0
        }
        
        botSlider.minimumValue = Float(minBots)
        
    }
    
    @IBAction func botSliderDidChange(_ sender: UISlider) {
        
        let value : Float = floor(sender.value)
        
        botSlider.value = value
        
        let int_value : Int = Int(value)
        
        botLabel.text = "Bots: \(int_value)"
        
        botCount = int_value
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            
            cell.textLabel?.text = playerNames[indexPath.row]
            
            return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            playerNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func reloadCell(for cell: Int, with name: String)
    {
        playerNames[cell] = name
        
        let indexPath = [IndexPath(item: cell, section: 0)]
            
        tableView.reloadRows(at: indexPath, with: .top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNameEdit" {
            if let row = tableView.indexPathForSelectedRow?.row {
                
                let detailViewController = segue.destination as! NameChangeController
                detailViewController.row = row
                detailViewController.name = playerNames[row]
                detailViewController.tableView = self
                
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                
            }
        }
        else if segue.identifier == "toGame" {
            let game = Game(humanPlayers: playerNames.count, humanNames: playerNames, botCount: botCount)
            
            game.passGameToPlayers()
            
            let gameViewController = segue.destination as! GameViewController
            gameViewController.game = game
        }
    }
}

