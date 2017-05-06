//
//  GameScene.swift
//  Humanity Against Cards
//
//  Created by Connor Rawls on 5/4/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene : SKScene {
    
    var game : Game
    
    var mode : SceneMode
    
    var cards : [Int]?
    
    var highlight_card : [Int]?
    var highlight_index : Int = -1
    
    //holds cards that are selected
    var selected_cards = [-1,-1,-1] // default is -1 for no card chosen
    var selected_cards_idx = [-1,-1,-1] //default is -1 for no card chosen
    
    //backgound for the game
    var background = SKSpriteNode(imageNamed: "green_felt_back")
    
    //submit button for playing or confirming judging
    var submitButton = SKSpriteNode(imageNamed: "submit_button")
    
    //buttons for changing which cards are in view
    var nextButton = SKSpriteNode(imageNamed: "next_button")
    var prevButton = SKSpriteNode(imageNamed: "previous_button")
    
    //SKNodes for drawing cards to the screen
    var showCardNodes : [SKSpriteNode]? //the nodes for "show" mode
    var showHighlightNode : SKSpriteNode? //the node for "show highlight" mode
    var selectorNodes  = [SKSpriteNode(imageNamed: "select_1"), SKSpriteNode(imageNamed: "select_2"), SKSpriteNode(imageNamed: "select_3"), SKSpriteNode(imageNamed: "deselect")]
    
    //Nodes for showing cards during judging
    var usedCards = [UsedCard]() //get contents from game object when judging
    var usedNodes = [SKSpriteNode]() //fill from above array
    var blackCardNode : SKSpriteNode? //will be constant during judging
    var currentUCardIndex : Int = 0
    
    
    //labels for displaying text
    let nameLabel = SKLabelNode(fontNamed: "Helvetica")
    let winsLabel = SKLabelNode(fontNamed: "Helvetica")
    
    init(game: Game, size: CGSize) {
        self.game = game
        
        mode = .show
        
        super.init(size: size)
        
        background.position = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        
        createShowNodes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        self.addChild(background)
        
        switch mode {
        case .show:
            createShowNodes()
            moveToShow()
            
        default:
            break
        }
        
        super.didMove(to: view)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first! //get what was tapped first
        let location = touch.location(in: self)
        let targetNodes = nodes(at: location)
        
        switch mode {
        case .show:
            if let nodes = showCardNodes {
                for (i,node) in nodes.enumerated() {
                    if node == targetNodes[0]{
                        let card = node as! Card
                        highlight_card = [card.cardIdx]
                        createShowHighlightNodes(for: i)
                        moveToShowHighlight(for: i)
                        break
                    }
                }
            }
            
            if targetNodes[0] == submitButton {
                let usedCard = createUsedCard()
                playCards(with: usedCard)
                createTransitionNodes()
                moveToTransition()
            }
        case .show_highlight:
            for (i,node) in selectorNodes.enumerated() {
                if node == targetNodes[0] {
                    transitionHighlightToShow(for: i)
                }
            }
        case .transition:
            selected_cards = [-1,-1,-1]
            selected_cards_idx = [-1,-1,-1]
            
            if game.isActivePlayerJudge() {
                createJudgeNodes()
                moveToJudge()
            } else {
                createShowNodes()
                moveToShow()
            }
        case .judge:
            if targetNodes[0] == nextButton {
                currentUCardIndex = (currentUCardIndex + 1) % usedCards.count
                createJudgeNodes()
                moveToJudge()
            }
            else if targetNodes[0] == prevButton {
                currentUCardIndex = (currentUCardIndex - 1)
                if currentUCardIndex < 0 {
                    currentUCardIndex = usedCards.count + currentUCardIndex
                }
                createJudgeNodes()
                moveToJudge()
            }
            else if targetNodes[0] == submitButton {
                game.assignWin(to: usedCards[currentUCardIndex].player)
                createTransitionNodes()
                moveToTransition()
            }
        }
    }
    
    private func createShowNodes() {
        
        let player = game.getActivePlayer()
        
        let blackcard = game.getCurrentBlackCard()
        
        cards = [blackcard]
        
        for card in player.hand.cards {
            cards?.append(card)
        }
        
        let scaled_size : CGFloat = frame.size.height / 5
        
        let origin : CGPoint = frame.origin
        
        let bottom_space : CGFloat = frame.maxY * 0.17
        
        let y_spacing : CGFloat = (frame.maxY * 0.85) / 4
        
        let left_space : CGFloat = frame.maxX * 0.28
        
        let x_spacing : CGFloat = (frame.maxX * 0.9) / 2
        
        
        for (index,card) in cards!.enumerated() {
            
            if index == 0 {
                showCardNodes = [Card(type: .black, number: card, loader: game.cardLoader)!]
            }
            else {
                showCardNodes?.append(Card(type: .white, number: card, loader: game.cardLoader)!)
            }
            
            let yVal : CGFloat = CGFloat(bottom_space + (CGFloat(index % 4) * y_spacing))
            let xVal : CGFloat = (floor(CGFloat((index) / 4)) * x_spacing) + left_space
            
            showCardNodes?[index].position = CGPoint(x: origin.x + xVal, y: origin.y + yVal)
            showCardNodes?[index].scale(to: CGSize(width: scaled_size, height: scaled_size))
        }
        
        nameLabel.text = game.getActivePlayer().name
        nameLabel.fontSize = 32
        nameLabel.fontColor = SKColor.white
        nameLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height * 0.025)
        
        winsLabel.text = "Wins: \(game.getActivePlayer().handWins)"
        winsLabel.fontSize = 32
        winsLabel.fontColor = SKColor.white
        winsLabel.position = CGPoint(x: frame.size.width * 0.25, y: frame.size.height * 0.925)
        
    }
    
    private func createShowHighlightNodes(for index: Int) {
        if index == 0 {
            showHighlightNode = Card(type: .black, number: highlight_card![0], loader: game.cardLoader)
        } else {
            showHighlightNode = Card(type: .white, number: highlight_card![0], loader: game.cardLoader)
        }
        
        let scaled_size = frame.size.width * 0.75
        
        let xOrigin = (frame.size.width / 2)
        
        let pos = CGPoint(x: xOrigin, y: frame.size.height / 2)
        
        showHighlightNode?.position = pos
        showHighlightNode?.scale(to: CGSize(width: scaled_size, height: scaled_size))
        
        //fix the position for the selector sprites
        for (index, select) in selectorNodes.enumerated() {
            
            let select_scaled_size : CGFloat = frame.size.height * 0.1
            select.scale(to: CGSize(width: select_scaled_size, height: select_scaled_size))
            
            let yStart = (frame.size.height / 2) + (scaled_size / 2) + (select_scaled_size * 0.6)
            let xSpace = scaled_size / 4
            
            let xStart = (xOrigin + (scaled_size / 2)) - (select_scaled_size / 2)
            
            select.position = CGPoint(x: xStart - (xSpace * CGFloat(index)), y: yStart )
        }
        
        highlight_index = index
        
        nameLabel.text = game.getActivePlayer().name
        nameLabel.fontSize = 32
        nameLabel.fontColor = SKColor.white
        nameLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height * 0.025)
        
        winsLabel.text = "Wins: \(game.getActivePlayer().handWins)"
        winsLabel.fontSize = 32
        winsLabel.fontColor = SKColor.white
        winsLabel.position = CGPoint(x: frame.size.width * 0.25, y: frame.size.height * 0.925)
    }
    
    private func createTransitionNodes() {
        
        //reset the label to show the next player
        nameLabel.text = game.getActivePlayer().name
        nameLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height * 0.4)
        
        //reset the wins label to say "Next Up"
        winsLabel.text = "Next Up"
        winsLabel.position = CGPoint(x: frame.size.width / 2, y: frame.size.height * 0.6)
    }
    
    private func createJudgeNodes() {
        
        if let uCards = game.getUsedCards() {
            usedCards = uCards
            
            //shuffle it up
            /*
            for (i, uCard) in usedCards.enumerated() {
                let shift : Int = Int(arc4random_uniform(UInt32(usedCards.count)))
                
                let newPos = (i + shift) % usedCards.count
                
                let temp = uCard
                
                usedCards[i] = usedCards[newPos]
                usedCards[newPos] = temp
            }
            
            */
            
            let cardCount = usedCards[currentUCardIndex].cardNum.count + 2 //1 for black card, 1 for spacing
            
            let scaled_size = frame.size.width * (0.45 - CGFloat(0.075 * Float(cardCount - 4)))
            
            let ySpace = (frame.size.height * (0.15 * CGFloat(cardCount)) / CGFloat(cardCount))
            let yOrigin = (frame.size.height * 0.5) + ((CGFloat(cardCount) / 2.0) * ySpace)
            
            for (i,card) in usedCards[currentUCardIndex].cardNum.enumerated() {
                
                if i == 0 {
                    usedNodes = [Card(type: .white, number: card, loader: game.cardLoader)!]
                }
                else {
                    usedNodes.append(Card(type: .white, number: card, loader: game.cardLoader)!)
                }
                
                let nodeIdx = usedNodes.count - 1
                
                usedNodes[nodeIdx].position = CGPoint(x: frame.size.width * 0.5, y: yOrigin - (CGFloat(i) * ySpace))
                usedNodes[nodeIdx].scale(to: CGSize(width: scaled_size, height: scaled_size))
            }
            
            blackCardNode = SKSpriteNode(imageNamed: game.cardLoader.getCardFileName(forType: .black, cardIdx: game.getCurrentBlackCard()))
            blackCardNode?.position = CGPoint(x: frame.size.width * 0.5, y: yOrigin - (CGFloat(cardCount - 1) * ySpace))
            blackCardNode?.scale(to: CGSize(width: scaled_size, height: scaled_size))
            
            let navButtonScale = frame.size.width * 0.075
            
            let buttonY = (blackCardNode?.position.y)! - scaled_size - (navButtonScale * 0.6)
            let nButtonX = (blackCardNode?.position.x)! + ((blackCardNode?.position.x)! * 0.45)
            let pButtonX = (blackCardNode?.position.x)! - ((blackCardNode?.position.x)! * 0.45)
            
            nextButton.position = CGPoint(x: nButtonX, y: buttonY)
            nextButton.scale(to: CGSize(width: navButtonScale, height: navButtonScale))
            
            prevButton.position = CGPoint(x: pButtonX, y: buttonY)
            prevButton.scale(to: CGSize(width: navButtonScale, height: navButtonScale))
            
            submitButton.position = CGPoint(x: frame.size.width * 0.5, y: buttonY)
            submitButton.scale(to: CGSize(width: frame.size.height * 0.125, height: frame.size.height * 0.0625))
        }
        
    }
    
    private func moveToShow() {
        
        //clear the board
        self.removeAllChildren()
        
        self.addChild(background)
        
        if let nodes = showCardNodes {
            for node in nodes {
                self.addChild(node)
            }
            
            var selectShowNodes = [SKSpriteNode]()
            let select_scale = frame.size.height * 0.075
            
            
            for (i, select) in selected_cards_idx.enumerated() {
                if select != -1{
                    switch i {
                    case 0:
                        selectShowNodes.append(SKSpriteNode(imageNamed: "select_1"))
                    case 1:
                        selectShowNodes.append(SKSpriteNode(imageNamed: "select_2"))
                    case 2:
                        selectShowNodes.append(SKSpriteNode(imageNamed: "select_3"))
                    default:
                        break
                    }
                    
                    let nodeIdx = selectShowNodes.count - 1
                    
                    selectShowNodes[nodeIdx].scale(to: CGSize(width: select_scale, height: select_scale))
                    let xPos = nodes[selected_cards_idx[i]].position.x + ((nodes[selected_cards_idx[i]].size.width / 2) * 0.8)
                    let yPos = nodes[selected_cards_idx[i]].position.y + ((nodes[selected_cards_idx[i]].size.height / 2) * 0.8)
                
                    selectShowNodes[nodeIdx].position = CGPoint(x: xPos, y: yPos)
                }
            }
            
            for sNode in selectShowNodes {
                self.addChild(sNode)
            }
            
            //check if all of the cards have been selected
            if selectionsComplete() {
                let submitY = frame.size.height * 0.95
                let submitX = frame.size.width * 0.75
                
                submitButton.position = CGPoint(x: submitX, y: submitY)
                
                let submitWidth = frame.size.width * 0.25
                let submitHeight = submitWidth / 2
                
                submitButton.scale(to: CGSize(width: submitWidth, height: submitHeight))
                
                self.addChild(submitButton)
            }
        }
        
        self.addChild(nameLabel)
        self.addChild(winsLabel)
   
        mode = .show
    }
    
    private func moveToShowHighlight(for index: Int) {
        //start by clearing the board
        self.removeAllChildren()
        
        self.addChild(background)
        self.addChild(showHighlightNode!)
        
        var cardsPlayed = game.cardLoader.getCardsToPlay(cardIdx: game.getCurrentBlackCard())

        if index == 0 {
            cardsPlayed = 0
        }
        
        for (i,select) in selectorNodes.enumerated() {
            if i < cardsPlayed || i == 3 {
                self.addChild(select)
            }
        }
        
        self.addChild(nameLabel)
        self.addChild(winsLabel)
        
        mode = .show_highlight
    }
    
    private func moveToTransition() {
        
        self.removeAllChildren()
        
        self.addChild(background)
        self.addChild(nameLabel)
        self.addChild(winsLabel)
        
        mode = .transition
    }
    
    private func moveToJudge() {
        self.removeAllChildren()
        
        self.addChild(background)
        
        for node in usedNodes {
            self.addChild(node)
        }
        
        self.addChild(blackCardNode!)
        self.addChild(nextButton)
        self.addChild(prevButton)
        self.addChild(submitButton)
        
        mode = .judge
    }
    
    //for checking if a card was selected by the player to be a part of their play
    private func transitionHighlightToShow(for selector: Int) {
        switch selector {
        case 0...2:
            selected_cards_idx[selector] = highlight_index
            selected_cards[selector] = cards![highlight_index]
            checkForDuplicateSelections(for: highlight_index, at: selector)
        default:
            break
        }
        
        createShowNodes()
        moveToShow()
    }
    
    //function to make sure that when a selection is changed, there are not duplicates for the same card
    private func checkForDuplicateSelections(for value: Int, at index: Int) {
        for (i,select) in selected_cards_idx.enumerated() {
            if i != index && select == value {
                selected_cards_idx[i] = -1
                selected_cards[i] = -1
            }
        }
    }
    
    private func selectionsComplete() -> Bool{
        
        let cardsRequired = game.cardLoader.getCardsToPlay(cardIdx: game.getCurrentBlackCard())
        
        //loop can only return false if conditions are met
        for (i,card) in selected_cards.enumerated() {
            if i < cardsRequired && card == -1 {
                return false
            }
        }
        
        //no default values found, we are good to go
        return true
    }
    
    //packages a usedCard object for use by the player
    private func createUsedCard() -> UsedCard {
        var cardsToPlay = [Int]()
        
        for card in selected_cards {
            if card != -1 {
                cardsToPlay.append(card)
            }
        }
        
        return UsedCard(cardNum: cardsToPlay, player: game.getActivePlayer().id)
    }
    
    private func playCards(with usedCard: UsedCard) {
        game.getActivePlayer().playCard(with: usedCard)
    }
    
    
    
    
}

enum SceneMode {
    case show //show a player their hand and the black card
    case show_highlight //when a player presses a card, make it bigger and give option to select for play
    case judge//show the judge all cards played
    case transition //screen waiting for the next player to be ready
}
