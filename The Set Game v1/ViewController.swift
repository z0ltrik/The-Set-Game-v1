//
//  ViewController.swift
//  The Set Game v1
//
//  Created by sealucky on 25.12.2017.
//  Copyright © 2017 sealucky. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum Shape: Int {
        case triangle = 1, square, circle
        var value: Character {
            switch self {
            case .triangle:
                return "▲"
            case .square:
                return "■"
            case .circle:
                return "●"
            }
        }
    }
    
    
    enum Color: Int {
        case red = 1, green, blue
        var value: UIColor {
            switch self {
            case .red:
                return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            case .green:
                return #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
            case .blue:
                return #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            }
        }
    }
    
    enum Texture: Int {
        case hollow = 1, striped, filled
    }
    
    var setGame = Game()
    
    @IBOutlet var cardButtons: [UIButton]!
    
    @IBOutlet var lastSetCards: [UIButton]!
    
    @IBOutlet weak var add3MoreCardsButton: UIButton!
    
    @IBOutlet weak var cardsLeftLable: UILabel!
    
    @IBOutlet weak var setsFoundQuantityLabel: UILabel!
    
    @IBOutlet weak var gameScoreLable: UILabel!
    
    @IBOutlet weak var iPhoneScoreLable: UILabel!
    
    @IBOutlet weak var iPhoneGameProcessLabel: UILabel!
    
    @IBOutlet weak var playVSiPhoneSwitcher: UISwitch!{
        didSet{
            iPhoneScoreLable.isHidden = !playVSiPhoneSwitcher.isOn
            iPhoneGameProcessLabel.isHidden = !playVSiPhoneSwitcher.isOn
        }
    }
    
    private var visibleCards: Int {
        get{
            var visCards = 0
            for card in cardButtons{
                if !card.isHidden {
                    visCards += 1
                }
            }
            return visCards
        }
        set{
            var hidden = false
            for i in 0...23{
                if i < newValue {
                    hidden = false
                }
                else {
                    hidden = true
                    cardButtons[i].setAttributedTitle(nil, for: UIControlState.normal)
                    cardButtons[i].setTitle(nil, for: UIControlState.normal)
                }
                cardButtons[i].isHidden = hidden
            }
        }
    }
    
    func setAttributedTitleForButton(_ cardButton: UIButton, withShape cardShape:Int, color cardColor:Int, texture cardTexture: Int, number characterQuantity: Int  ){
        
        if let currentShape = Shape(rawValue: cardShape), let currentColor = Color(rawValue: cardColor), let currentTexture = Texture(rawValue: cardTexture)  {
            
            var cardTitle = ""
            
            for _ in 1...characterQuantity{
                cardTitle += String(currentShape.value)
            }
            
            var colorAndTextureOfTheCardTitle: [NSAttributedStringKey: Any]
            
            switch currentTexture{
            case .filled:
                colorAndTextureOfTheCardTitle = [
                    .strokeColor: currentColor.value,
                    .foregroundColor: currentColor.value.withAlphaComponent(1.0),
                    .strokeWidth: -6.0
                ]
            case .hollow:
                colorAndTextureOfTheCardTitle = [
                    .strokeColor: currentColor.value,
                    .foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).withAlphaComponent(1.0),
                    .strokeWidth: -6.0
                ]
                
            case .striped:
                colorAndTextureOfTheCardTitle = [
                    .strokeColor: currentColor.value,
                    .foregroundColor: currentColor.value.withAlphaComponent(0.15),
                    .strokeWidth: -6.0
                ]
                
            }
            cardButton.setAttributedTitle(NSAttributedString(string: cardTitle, attributes: colorAndTextureOfTheCardTitle), for: UIControlState.normal)
            }
        
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardIndex = cardButtons.index(of: sender) {
            setGame.chooseCardAndCheckSet(at: cardIndex)
            updateCardButtonsView()
            if let itIsSet = setGame.itIsSet, itIsSet{
                setGame.replaceSelectedCardsWithNewCards()
                updateCardButtons()
            }
            updateLabel(gameScoreLable, withText: "Your score: \(setGame.gameScore)", withStrokeColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
            
        }
    }
    
    func updateCardButtonsView() {
        var lastSetCardIndex = 0
        // выполним выделение выбранных карт или карт, которые не попали в сет
        for indexOfCard in cardButtons.indices{
            cardButtons[indexOfCard].layer.borderWidth = 2
            cardButtons[indexOfCard].layer.borderColor = #colorLiteral(red: 0.7586801506, green: 0.7586801506, blue: 0.7586801506, alpha: 1)
            cardButtons[indexOfCard].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            if setGame.selectedCardsIndeces.contains(indexOfCard){
                if setGame.itIsSet == nil {
                    cardButtons[indexOfCard].layer.borderWidth = 3
                    cardButtons[indexOfCard].layer.borderColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
                    cardButtons[indexOfCard].backgroundColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 0.06464568665)
                } else {
                    if setGame.itIsSet! == false{
                        cardButtons[indexOfCard].layer.borderWidth = 3
                        cardButtons[indexOfCard].layer.borderColor = #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
                        cardButtons[indexOfCard].backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.1)
                    } else {
                        lastSetCards[lastSetCardIndex].setAttributedTitle(cardButtons[indexOfCard].attributedTitle(for: UIControlState.normal), for: UIControlState.normal)
                        lastSetCardIndex += 1
                    }
                    
                }
            }
        }
    }
    
    private func updateCardButtons()
    {
        visibleCards = setGame.cardsInGame.count
        add3MoreCardsButton.isEnabled = visibleCards != cardButtons.count
        cardsLeftLable.text = "Cards left: \(setGame.cardsLeftInDeck)"
        setsFoundQuantityLabel.text = "Sets found: \(setGame.setsFoundQuantity)"
        var index = 0
        for card in setGame.cardsInGame {
            setAttributedTitleForButton(cardButtons[index], withShape: card.shape, color: card.color, texture: card.texture, number: card.number)
            index += 1
        }
    }
    
    private func updateLabel(_ label: UILabel, withText text: String, withStrokeColor strokeColor: UIColor){
        let attributesForLabel: [NSAttributedStringKey: Any] = [
            .strokeColor: strokeColor,
            .strokeWidth: -3.0
        ]
        label.attributedText = NSAttributedString(string: text, attributes: attributesForLabel)
    }
    
    func startNewGame()
    {
        for card in cardButtons{
            card.setAttributedTitle(nil, for: UIControlState.normal)
            card.setTitle(nil, for: UIControlState.normal)
        }
        for setCard in lastSetCards{
            setCard.setAttributedTitle(nil, for: UIControlState.normal)
            setCard.setTitle(nil, for: UIControlState.normal)
        }
        setGame.startNewGame()
        updateCardButtonsView()
        updateCardButtons()
        updateLabel(gameScoreLable, withText: "Your score: \(setGame.gameScore)", withStrokeColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        playVSiPhoneSwitcher.isOn = false
        
    }
    
    @IBAction func add3MoreCards(_ sender: UIButton) {
        let numberOfCardsPossibleToAdd = min(cardButtons.count-visibleCards, 3)
        if numberOfCardsPossibleToAdd > 0 {
        setGame.addMoreCards(quantity: numberOfCardsPossibleToAdd)
        updateCardButtons()
        updateLabel(gameScoreLable, withText: "Your score: \(setGame.gameScore)", withStrokeColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        }
    }
    
    @IBAction func NewGame(_ sender: UIButton) {
        startNewGame()
    }
    
    @IBAction func findSet(_ sender: UIButton) {
        setGame.findTheSet()
        updateCardButtonsView()
        updateLabel(gameScoreLable, withText: "Your score: \(setGame.gameScore)", withStrokeColor: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
        
    }
    
    @IBAction func playVsIPhone(_ sender: UISwitch) {
        iPhoneScoreLable.isHidden = !sender.isOn
        iPhoneGameProcessLabel.isHidden = !sender.isOn
        if sender.isOn{
            updateLabel(iPhoneScoreLable, withText: "iPhone Score: \(setGame.iPhoneScore)", withStrokeColor: #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1))
            //updateLabel(iPhoneGameProcessLabel, withText: "Hmm, let me think 🤔 ...", withStrokeColor: #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1))
            iPhoneGameProcessLabel.text = "Hmm, let me think 🤔 ..."
        }
    }
    
    
    override func viewDidLoad() {
        startNewGame()
        
    }
    
}
