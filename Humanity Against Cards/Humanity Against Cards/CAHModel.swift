//
//  CAHModel.swift
//  You Got Games
//
//  Created by Connor Rawls on 4/17/17.
//  Copyright © 2017 Connor Rawls. All rights reserved.
//

import Foundation
import Messages


class Game {
    
    var wDeck : Deck
    var bDeck : Deck
    private var players: [Player]
    private var usedCards : [UsedCard]?
    private var judgeIdx : Int
    private var currentPlayer : Int
    private var blackCard : Int
    private var roundHistory : GameHistory?
    let cardLoader : CardLoader
    
    static let maxWins : Int = 10
    
    //initializer for a new game
    init(humanPlayers: Int, botCount: Int) {
        
        players = [Player]()
        
        for i in 0...(humanPlayers - 1) {
            
            let playerNum = i + 1
            
            players.append(Player(id: i, name: "Player \(playerNum)"))
        }
        
        let pTemp = players[0]
        players.remove(at: 0)
        players.insert(pTemp, at: 1)
        
        //make sure only to execute the loop in the case that there are bots in the game
        if botCount > 0 {
            for i in 0...(botCount - 1) {
                players.append(Bot(id: i + humanPlayers, name: "Bot \(i + 1)"))
            }
        }
        
        //assign the creator to be the first judge
        judgeIdx = 0
        currentPlayer = 1
        
        wDeck = Deck(type: DeckType.white, max: 460)
        bDeck = Deck(type: DeckType.black, max: 90)
        
        blackCard = bDeck.drawCard()
        
        
        //deal to each player
        for player in players {
            for _ in 0...Hand.maxHandSize {
                player.addCard(card: wDeck.drawCard())
            }
        }
        
        cardLoader = CardLoader()
        
    }
    
    init(humanPlayers: Int, humanNames: [String], botCount: Int) {
        
        players = [Player]()
        
        for i in 0...(humanPlayers - 1) {
            
            players.append(Player(id: i, name: humanNames[i]))
        }
        
        let pTemp = players[0]
        players.remove(at: 0)
        players.insert(pTemp, at: 1)
        
        //make sure only to execute the loop in the case that there are bots in the game
        if botCount > 0 {
            for i in 0...(botCount - 1) {
                players.append(Bot(id: i + humanPlayers, name: "Bot \(i + 1)"))
            }
        }
        
        //assign the creator to be the first judge
        judgeIdx = 0
        currentPlayer = 1
        
        wDeck = Deck(type: DeckType.white, max: 460)
        bDeck = Deck(type: DeckType.black, max: 90)
        
        //blackCard = bDeck.drawCard()
        blackCard = 74 //for testing only
        
        //deal to each player
        for player in players {
            for _ in 0...Hand.maxHandSize {
                player.addCard(card: wDeck.drawCard())
            }
        }
        
        cardLoader = CardLoader()
    }
    
    //initializer for game in progress
    init(players: [Player], wCards: Deck, bCards: Deck, uCards: [UsedCard]?, cPlayer: Int, jPlayer: Int, currentGoal: Int, history: GameHistory?) {
    
        wDeck = wCards
        bDeck = bCards
        
        self.players = players
        
        usedCards = uCards
        
        currentPlayer = cPlayer
        
        judgeIdx = jPlayer
        
        blackCard = currentGoal
        
        if let h = history {
            roundHistory = h
        }
        
        cardLoader = CardLoader()
    }
    
    
    
    //function for passing reference to the game object to each of the players so that they can play their cards
    func passGameToPlayers() {
        
        for player in players {
            player.game = self
        }
    }
    
    //called from the player class to use cards
    func playCards(cards: UsedCard) {
        
        if let _ = usedCards {
            usedCards?.append(cards)
        } else {
            usedCards = [cards]
        }
        
        let playedCards = cards.cardNum
        
        //be sure to add to the discard pile when played
        wDeck.discard(forDiscard: playedCards)
        
        currentPlayer += 1
        
        currentPlayer = currentPlayer % players.count
        
    }
    
    //method to check if the current player is the current device
    func isCurrentPlayer(id: Int) -> Bool {
        if players[currentPlayer].id == id {
            return true
        }
        
        return false
    }
    
    //after a player has taken their turn, call this to check if the next player is a bot
    func checkNextPlayer() {
        //if they are a bot, have them take their turn
        if players[currentPlayer].isBot {
            
        } else {
            //package the current state as a url and pass it along.
        }
        
    }
    
    
    //get a specific player by id from the game object, returns nil if there are no matches to the id
    func getPlayer(id: Int) -> Player? {
        
        for player in players {
            if player.id == id {
                return player
            }
        }
        
        return nil
        
    }
    
    //function to retrieve a reference to the active player in the gamescene
    func getActivePlayer() -> Player {
        return players[currentPlayer]
    }
    
    //gamescene calls this during transition to decide which configuration to show next
    func isActivePlayerJudge() -> Bool {
        if currentPlayer == judgeIdx {
            return true
        }
        
        return false
    }
    
    func drawCard(for type: DeckType) -> Int {
        switch type {
        case .white:
            return wDeck.drawCard()
        case .black:
            return bDeck.drawCard()        }
    }
    
    //function to retrieve the current black card in play
    func getCurrentBlackCard() -> Int {
        return blackCard
    }
    
    //used by in order to get the player array
    func getPlayers() ->[Player] {
        return players
    }
    
    //func used by gamescene to get the cards that have been played for the judge
    func getUsedCards() -> [UsedCard]? {
        
        return usedCards
    }
    
    func assignWin(to winPlayer: Int) {
        players[winPlayer].handWins += 1
        judgeIdx = (judgeIdx + 1) % players.count
        currentPlayer = (currentPlayer + 2) % players.count
        
        bDeck.discard(forDiscard: [blackCard])
        blackCard = bDeck.drawCard()
        
        usedCards = nil
    }
    
    func prepareURL() -> URL {
        
        //what will be compiled and passed on
        var components = URLComponents()
        
        //header, not going to test the host is real
        components.scheme = "http"
        components.host = "www.yougotgames.com"
        
        //first get the decks squared away
        let deckBegin = URLQueryItem(name: "deckBegin", value: "1")
        let deckEnd = URLQueryItem(name: "deckEnd", value: "1")
        let wDeckType = URLQueryItem(name: "deck_type", value: wDeck.getTypeString())
        let wDeckItem = URLQueryItem(name: "deck", value: wDeck.getCardString())
        let wDeckDiscard = URLQueryItem(name: "discard", value: wDeck.getDiscardString())
        
        components.queryItems = [deckBegin]
        components.queryItems?.append(wDeckType)
        components.queryItems?.append(wDeckItem)
        components.queryItems?.append(wDeckDiscard)
        components.queryItems?.append(deckEnd)
        
        let bDeckType = URLQueryItem(name: "deck_type", value: bDeck.getTypeString())
        let bDeckItem = URLQueryItem(name: "deck", value: bDeck.getCardString())
        
        components.queryItems?.append(deckBegin)
        components.queryItems?.append(bDeckType)
        components.queryItems?.append(bDeckItem)
        components.queryItems?.append(deckEnd)
        
        //get the judge index
        let judgePlayer = URLQueryItem(name: "judge_index", value: "\(judgeIdx)")
        components.queryItems?.append(judgePlayer)
        
        //get the current player index
        let currentPlayer = URLQueryItem(name: "current_player", value: "\(self.currentPlayer)")
        components.queryItems?.append(currentPlayer)
        
        //get the current black card
        let myBlackCard = URLQueryItem(name: "black_card", value: "\(blackCard)")
        components.queryItems?.append(myBlackCard)
        
        //get any white cards that have been played so far this round
        if let playedCards = usedCards {
            
            for element in playedCards {
                let usedCardBegin = URLQueryItem(name: "usedCardBegin", value: "1")
                let uCard = URLQueryItem(name: "play", value: element.getCardString())
                let uPlayer = URLQueryItem(name: "card_player", value: element.getPlayerString())
                let usedCardEnd = URLQueryItem(name: "usedCardEnd", value: "1")
                
                components.queryItems?.append(usedCardBegin)
                components.queryItems?.append(uCard)
                components.queryItems?.append(uPlayer)
                components.queryItems?.append(usedCardEnd)
            }
            
        }
        
        //get if there is anything history to be preserved
        if let history = roundHistory {
            
            let historyBegin = URLQueryItem(name: "historyBegin", value: "1")
            let players = URLQueryItem(name: "players", value: history.getPlayersString())
            let histBCard = URLQueryItem(name: "blackCard", value: history.getBlackCardString())
            
            components.queryItems?.append(historyBegin)
            components.queryItems?.append(players)
            components.queryItems?.append(histBCard)
            
            for ucard in history.usedCards {
               
                let usedCardBegin = URLQueryItem(name: "usedCardBegin", value: "1")
                let uCard = URLQueryItem(name: "play", value: ucard.getCardString())
                let uPlayer = URLQueryItem(name: "card_player", value: ucard.getPlayerString())
                let usedCardEnd = URLQueryItem(name: "usedCardEnd", value: "1")
                
                components.queryItems?.append(usedCardBegin)
                components.queryItems?.append(uCard)
                components.queryItems?.append(uPlayer)
                components.queryItems?.append(usedCardEnd)
            }
            
            let historyEnd = URLQueryItem(name: "historyEnd", value: "1")
            
            components.queryItems?.append(historyEnd)
        }
        
        //begin writing player values
        for player in players {
            
            let playerBegin = URLQueryItem(name: "playerStart", value: "1")
            let name = URLQueryItem(name: "name", value: player.name)
            let id = URLQueryItem(name: "id", value: player.getPlayerIDString())
            let hand = URLQueryItem(name: "hand", value: player.getHandString())
            let wins = URLQueryItem(name: "wins", value: player.getRoundWinsString())
            let type = URLQueryItem(name: "type", value: player.getPlayerTypeString())
            let playerEnd = URLQueryItem(name: "playerEnd", value: "1")
            
            components.queryItems?.append(playerBegin)
            components.queryItems?.append(name)
            components.queryItems?.append(id)
            components.queryItems?.append(hand)
            components.queryItems?.append(wins)
            components.queryItems?.append(type)
            components.queryItems?.append(playerEnd)
        }
        
        let countStr = "Item Count: \(components.queryItems?.count)"
        Swift.print(countStr)
        
        
        
        //append all of our items to the components object
        //components.queryItems?.append(contentsOf: queryItems)
        
        //for item in queryItems {
       //     components.queryItems?.append(item)
       // }
        
        //then get the url to output
        let outputURL : URL = components.url!
        
        
        Swift.print("\n\n--------------------------------\n\tOUTGOING URL\n")
        Swift.print(outputURL)
        
        return outputURL
    }
    
}

/*
 Game History Class
 */

class GameHistory {
    
    var playersToShow : [UUID]?
    var blackCard : Int
    var usedCards : [UsedCard]
    
    init(players: [UUID], bCard: Int, cards: [UsedCard]){
        playersToShow = players
        blackCard = bCard
        usedCards = cards
    }
    
    func willShowHistoryToPlayer(id: UUID) -> Bool {
        if let players = playersToShow {
            
            for player in players {
                if id == player {
                    return true
                }
            }
            
        }
        
        return false
    }
    
    func hasPlayersToShow() -> Bool {
        if let players = playersToShow {
            if players.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    func hasShownPlayer(id: UUID) {
        if let players = playersToShow {
            for (index, p) in players.enumerated() {
                if p == id {
                    playersToShow?.remove(at: index)
                }
            }
        }
    }
    
    func getBlackCardString() -> String {
        return "\(blackCard)"
    }
    
    func getPlayersString() -> String {
        var str : String = ""
        
        for (index, player) in (playersToShow?.enumerated())! {
            
            if index < (playersToShow?.count)! - 1 {
                str += player.uuidString
                str += "+"
            } else {
                str += player.uuidString
            }
        }
        
        return str
    }
    
}


/* 
 ==========================================================================================================================================
  CODE FOR CREATING AND MAINTAINING PLAYERS
 ==========================================================================================================================================
 */

class Player {
    
    var name : String
    var hand : Hand
    var isJudge : Bool
    var handWins : Int
    var game : Game? //a reference to the game object so that we can pass cards or get cards
    var isBot = false
    var id : Int
    
    //default so that items can be added piecemeal
    init() {
        name = "default"
        hand = Hand()
        isJudge = false
        handWins = 0
        id = 0
    }
    
    //initializer for new player
    init(id: Int, name: String)
    {        self.name = name
        hand = Hand()
        isJudge = false
        handWins = 0
        self.id = id
        
    }
    
    //initializer for a player in a game in progress
    required init(name: String, hand: Hand, judge: Bool, wins: Int, id: Int) {
        
        self.name = name
        
        self.hand = hand
        
        isJudge = judge
        
        handWins = wins
        
        self.id = id
    }
    
    func addCard(card: Int) {
        
        hand.addCard(card: card)
        
    }
    
    //method for playing white cards, array parameter for hands where multiple cards need to be played
    func playCard(cardIndex: [Int]) {
        let play = UsedCard(cardNum: cardIndex, player: id)
        
        game?.playCards(cards: play)
        
        for i in 0...cardIndex.count {
            hand.removeCard(index: cardIndex[i])
        }
    }
    
    //overloaded function to be called from gamescene, UsedCard object is prepackaged
    func playCard(with usedCard: UsedCard) {
        game?.playCards(cards: usedCard)
        
        for card in usedCard.cardNum {
            //get rid of the card we used
            hand.removeCard(value: card)
            
            //draw a card to replace it
            let newCard = game?.drawCard(for: .white)
            hand.addCard(card: newCard!)
        }
    }
    
    func getPlayerTypeString() -> String {
        return "player"
    }
    
    func getPlayerIDString() -> String {
        return "\(id)"
    }
    
    func getHandString() -> String {
        return hand.getContentString()
    }
    
    func getRoundWinsString() -> String {
        return "\(handWins)"
    }
    
}

//sub class of player for computer player that fills out small games
class Bot : Player {

    
    required init(name: String, hand: Hand, judge: Bool, wins: Int, id: Int) {
        super.init(name: name, hand: hand, judge: judge, wins: wins, id: id)
        
        isBot = true
    }
    
    override init() {
        super.init()
        isBot = true
    }
    
    //initializer for new player
    override init(id: Int, name: String)
    {
        super.init(id: id, name: name)
        isBot = true
    }
    
    func botPlayCards(count: Int) -> UsedCard {
        
        if count == 1 {
            let card  = Int(arc4random_uniform(UInt32(hand.cards.count)))
            
            let uCard = UsedCard(cardNum: [hand.cards[card]], player: self.id)
            
            hand.removeCard(index: card)
            
            return uCard
        }
        else {
         
            //shuffle the cards in the hand
            for (index, _) in hand.cards.enumerated() {
                let shift = Int(arc4random_uniform(7)) - 3
                
                let oldCard = hand.cards[index]
                
                let newPos = (index + shift) % 7
                
                hand.cards[index] = hand.cards[newPos]
                hand.cards[newPos] = oldCard
            }
            
            var cards = [Int]()
            
            //use the first n cards
            for _ in 0...count {
                cards.append(hand.cards[0])
                hand.removeCard(index: 0)
            }
            
            let uCard = UsedCard(cardNum: cards, player: self.id)
            
            return uCard
        }
        
        
    }
    
    override func getPlayerTypeString() -> String {
        return "bot"
    }
    
}

/* 
 ==========================================================================================================================================
  CODE FOR CREATING AND MAINTAINING PLAYER HANDS
 ==========================================================================================================================================
 */

class Hand {
    var cards : [Int] = [Int]()
    static let maxHandSize : Int = 7
    
    //default initializer
    init() {} //just waits for cards to be added
    
    //initializer for existing hand
    init(myCards: [Int]) {
        for card in myCards {
            cards.append(card)
        }
    }
    
    func addCard(card: Int) {
        if cards.count < Hand.maxHandSize {
            cards.append(card)
        }
    }
    
    func removeCard(index: Int) {
        if index >= 0 && index < cards.count {
            cards.remove(at: index)
        }
    }
    
    //overloaded remove card func for when only the card value is known
    func removeCard(value: Int) {
        
        for (i,card) in cards.enumerated() {
            if card == value {
                cards.remove(at: i)
            }
        }
        
    }
    
    func getContentString() -> String {
        var str : String = ""
        
        for (index, card) in cards.enumerated() {
            if index < cards.count - 1 {
                str += "\(card)-"
            } else {
                str += "\(card)"
            }
        }
        
        return str
    }
    
}



//class to represent white cards that have been played by non-judges
class UsedCard {
    //which card it is
    var cardNum : [Int] //intentionally left an array in the case of a multi card play
    
    //unique identifier of who played it
    var player : Int
    
    init(cardNum: [Int], player: Int) {
        self.cardNum = cardNum
        self.player = player
    }
    
    func getCardString() -> String {
        
        var str : String = ""
        
        for (index, card) in cardNum.enumerated() {
            if index < cardNum.count - 1 {
                str += "\(card)-"
            } else {
                str += "\(card)"
            }
        }
        
        return str
    }
    
    func getPlayerString() -> String {
        return "\(player)"
    }
    
    func getPlayer() -> Int {
        return player
    }
}

/*
 ==========================================================================================================================================
  CODE FOR CREATING AND MAINTING CARD DECKS
 ==========================================================================================================================================
 */


enum DeckType : String {
    case black = "black"
    case white = "white"
}

class Deck {
    var type : DeckType = DeckType.white
    var cards : [Int] = [0]
    var discard = [Int]()
    
    
    //creates the deck from URL Data
    init(type: DeckType, cards: [Int], dCards: [Int]?)
    {
        self.type = type;
        self.cards = cards
        if let discards = dCards {
            discard.append(contentsOf: discards)
        }
    }
    
    //creates a new deck of the specified type with the specified number of cards
    init(type: DeckType, max: Int)
    {
        self.type = type
        
        cards = [Int]()
        
        //create an ordered sequence in the deck
        for i in 0...max {
            cards.append(i)
        }
        
        //"shuffle" by randomly deciding where to move each card to
        for i in 0...(cards.count - 1) {
            
            //come up with the distance to shift by
            var shift = Int(arc4random_uniform(UInt32(cards.count)))
            shift = shift - (cards.count / 2)
            
            //calculate the new position of the card in the deck
            var newPos = i + shift
            
            if newPos >= cards.count {
                newPos = newPos % cards.count
            }
            
            //account for a possible value less than 0
            if(newPos < 0) {
                newPos = cards.count - abs(newPos)
            }
            
            //swap data between points
            let temp = cards[i]
            cards[i] = cards[Int(newPos)]
            cards[Int(newPos)] = temp
        }
    }
    
    //DO NOT CALL WITHOUT CHECKING FIRST
    func drawCard() -> Int {
        
        let rValue = cards[0]
        
        cards.remove(at: 0)
        
        return rValue
    }
    
    //should be called before calling draw card
    func hasCards() -> Bool {
        
        if cards.count == 0 && discard.count > 0 {
            
            //call for a shuffle and return true
            reFillDeck()
            return true
        }
        else if cards.count == 0 {
            
            //we have no cards and the discard is empty, must be the black deck or a gigantic game
            return false
        }
        else {
            //we have cards to draw
            return true
        }
    }
    
    private func reFillDeck() {
        
        //create a new array
        cards = [Int]()
        
        //fill with what is in the discard pile
        for i in 0...discard.count {
            cards[i] = discard[i]
        }
        
        //"shuffle" by randomly deciding where to move each card to
        for i in 0...cards.count {
            
            //come up with the distance to shift by
            var shift = arc4random_uniform(UInt32(cards.count))
            shift = shift - UInt32(cards.count / 2)
            
            //calculate the new position of the card in the deck
            var newPos = i + Int32(shift)
            
            //account for a possible value less than 0
            if(newPos < 0) {
                newPos = Int32(cards.count) - abs(newPos)
            }
            
            //swap data between points
            let temp = cards[i]
            cards[i] = cards[Int(newPos)]
            cards[Int(newPos)] = temp
        }
        
    }
    
    func discard(forDiscard: [Int]) {
        
        for card in forDiscard {
            discard.append(card)
        }
        
    }
    
    func getTypeString() -> String {
        return type.rawValue
    }
    
    func getCardString() -> String {
        var str : String = ""
        
        for (index, card) in cards.enumerated() {
            if index < cards.count - 1 {
                str += "\(card)-"
            } else {
                str += "\(card)"
            }
        }
        
        return str
    }
    
    func getDiscardString() -> String {
        if discard.count > 0 {
            
            var str : String = ""

            for (index, card) in discard.enumerated() {
                if index < cards.count - 1 {
                    str += "\(card)-"
                } else {
                    str += "\(card)"
                }
            }
            
            return str
            
        } else {
            return "-1"
        }
    }
}
