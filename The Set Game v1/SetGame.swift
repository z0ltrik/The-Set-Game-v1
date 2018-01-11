//
//  SetGame.swift
//  The Set Game v1
//
//  Created by sealucky on 26.12.2017.
//  Copyright © 2017 sealucky. All rights reserved.
//

import Foundation

struct Game{
    // Колода для игры - 81 карта в нашем случае
    private var allGameCards = [Card]()
    // Карты, с которыми игрок взаимодействует на экране
    var cardsInGame = [Card]()
    // Минимальное количество карт на экране, при условии, что в колоде есть неиспользованные карты
    private let minCardsOnTheScreen = 12
    // Карты, выбранные играком
    private var selectedCards = [Card]()
    // Геттер для получения индексов, выбранных карт
    var selectedCardsIndeces: [Int] {
        var array = [Int]()
        for card in selectedCards{
            array.append(cardsInGame.index(of: card)!)
        }
        return array
    }
    // Индекс следующей карты из колоды
    private var indexOfNextCard = 0
    // Индекс последней карты в колоде
    private var lastCardIndex: Int {
        return allGameCards.count-1
    }
    // Признак, что мы угадали Сет
    private(set) var itIsSet: Bool?{
        didSet{
            if itIsSet != nil {
                if itIsSet!{
                    gameScore += GamePoints.defaultPointsForMatching
                    setsFoundQuantity += 1
                } else {
                    gameScore += GamePoints.pointsForMissMatch
                }
            }
        }
    }
    
    private(set) var gameScore = 0
    private(set) var iPhoneScore = 0
    
    private(set) var setsFoundQuantity = 0
    
    var cardsLeftInDeck: Int {
        get{
            return allGameCards.count - indexOfNextCard
        }
    }
    
    struct GamePoints{
        static let defaultPointsForMatching = 3
        static let pointsForMissMatch = -5
        static let pointsForFindSetPressingOrDeal3MoreCardsIfSetExists = -10
    }
    
    init() {
        // Создадим колоду
        for shape in 1...3{
            for color in 1...3{
                for texture in 1...3{
                    for number in 1...3{
                        let newCard = Card(shape: shape, color: color, texture: texture, number: number)
                        allGameCards.append(newCard)
                    }
                }
            }
        }
        // Перемешаем, чтобы игра была интереснее
        allGameCards.shuffle()
    }
    
    // Инициализация новой игры
    mutating func startNewGame(){
        allGameCards.shuffle()
        indexOfNextCard = 0
        gameScore = 0
        iPhoneScore = 0
        setsFoundQuantity = 0
        cardsInGame.removeAll()
        addCards(quantity: 12)
        selectedCards.removeAll()
    }
    
    // Добавление карт в игру
    mutating func addCards(quantity: Int){
        for _ in 1...quantity{
            if let newCard = getNewCard(){
                cardsInGame.append(newCard)
            }
        }
    }
    
    mutating func addMoreCards(quantity: Int){
        findTheSet()
        selectedCards.removeAll()
        addCards(quantity: quantity)
    }
    
    // Получение очередной карты из колоды
    mutating func getNewCard() -> Card?{
        // Если все карты из колоды уже использованы, то добавлять нечего
        if indexOfNextCard > lastCardIndex { return nil }
        // Возьмем следующую карту
        let newCard =  allGameCards[indexOfNextCard]
        // Сдвинем индекс последней использованной карты колоды
        indexOfNextCard += 1
        return newCard
    }
    
    // Обработка карт из угаданного Сета
    mutating func replaceSelectedCardsWithNewCards(){
        // Пройдемся по выделеннным картам, они же и составляют Сет
        for selectedCard in selectedCards {
            // Получим индекс карты из выбранных карт
            if var indexOfSelectedCard = cardsInGame.index(of: selectedCard){
                // Брать новые карты из колоды, нужно только, если на экране не более 12 карт
                if cardsInGame.count <= minCardsOnTheScreen{
                    // Получим новую карту
                    if let newCard = getNewCard(){
                        // Вставим новую карту по тому же индексу, что и удаленная
                        cardsInGame.insert(newCard, at: indexOfSelectedCard)
                        // Старая карта теперь сдвинулась на 1 позицию дальше
                        indexOfSelectedCard+=1
                    }
                }
                // Удалим выделенную и попавшую в Сет карту из карт в игре
                cardsInGame.remove(at: indexOfSelectedCard)
            }
        }
        // очистим выделенные карты
        selectedCards.removeAll()
    }
    
    // Обработка выбора карты на экране
    mutating func chooseCardAndCheckSet(at index: Int){
        // Сбросим флаг угаданного Сета
        itIsSet = nil
        // Если до этого уже было выделено 3 карты, сбросим их выделение, т.к. по услвоию игры выделить можно только 3 карты
        if selectedCards.count == 3 {
            selectedCards.removeAll()
        }
        
        let touchedCard = cardsInGame[index]
        // Если выбранная на экране карта ранее не была выделена, то добавим ее в выделенные
        if !selectedCards.contains(touchedCard){
            selectedCards.append(touchedCard)
        } else {
            // тут мы точно знаем, что карта touchedCard есть в массиве, поэтому получим ее индекс, чтобы удалить - сделать невыделенной карту
            let indexOfTouchedCard = selectedCards.index(of: touchedCard)!
            selectedCards.remove(at: indexOfTouchedCard)
        }
        // если выбрано 3 карты, необходимо проверить Сет
        if selectedCards.count == 3{
            itIsSet = selectedCards[0].isInSet(with: selectedCards[1], and: selectedCards[2])
        }
    }
    
    // Поиск первого попавшегося Сета из карт на экране
    mutating func findTheSet(){
        itIsSet = nil
        selectedCards.removeAll()
        var setIsFound = false
        gameLoop: for firstCardIndex in 0..<cardsInGame.count-2{
            for secondCardIndex in firstCardIndex+1..<cardsInGame.count-1{
                for thirdCardIndex in secondCardIndex+1..<cardsInGame.count{
                    setIsFound = cardsInGame[firstCardIndex].isInSet(with: cardsInGame[secondCardIndex], and: cardsInGame[thirdCardIndex])
                    if setIsFound {
                        gameScore += GamePoints.pointsForFindSetPressingOrDeal3MoreCardsIfSetExists
                        // Добавим карты найденного Сета в выделенные карты
                        selectedCards.append(cardsInGame[firstCardIndex])
                        selectedCards.append(cardsInGame[secondCardIndex])
                        selectedCards.append(cardsInGame[thirdCardIndex])
                        break gameLoop
                    }
                }
            }
        }
    }
}

extension Int {
    var randomInt: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        }else if self < 0 {
            return Int(arc4random_uniform(UInt32(abs(self))))
        }else{
            return 0
        }
    }
}

extension Array{
    mutating func shuffle(){
        if count < 2 {return}
        var last = count-1
        while last > 0 {
            let randomIndex = last.randomInt
            swapAt(last, randomIndex)
            last -= 1
        }
    }
}
