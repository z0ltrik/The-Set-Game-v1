//
//  SetCard.swift
//  The Set Game v1
//
//  Created by sealucky on 25.12.2017.
//  Copyright © 2017 sealucky. All rights reserved.
//

import Foundation

struct Card: Equatable {
    
    // Наша модель ничего не должна знать о цветах, формах и проч
    let shape: Int
    let color: Int
    let texture: Int
    let number: Int
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        
        if lhs.shape == rhs.shape && lhs.color == rhs.color
            && lhs.texture == rhs.texture && lhs.number == rhs.number {
            return true
        } else {
            return false
        }
    }
    
    // Определение составляют ли выбранные 3 карты Сет
    func isInSet(with secondCard: Card, and thirdCard:Card) -> Bool{
        // GodMode
        //return true
        // Cформируем из каждого вида свойств отдельные множества
        let setOfShapes: Set = [self.shape,secondCard.shape, thirdCard.shape]
        let setOfColor: Set = [self.color,secondCard.color, thirdCard.color]
        let setOfTexture: Set = [self.texture,secondCard.texture, thirdCard.texture]
        let setOfNumber: Set = [self.number,secondCard.number, thirdCard.number]
        //        // без сравнения множеств
        //        return (setOfColor.count == 1 || setOfColor.count == 3) && (setOfNumber.count == 1 || setOfNumber.count == 3)
        //            && (setOfShapes.count == 1 || setOfShapes.count == 3) && (setOfTexture.count == 1 || setOfTexture.count == 3)
        
        // Cформируем множество из количеств элементов в каждом множестве свойств
        let setForCheckingSet: Set = [setOfColor.count, setOfNumber.count, setOfTexture.count, setOfShapes.count]
        // Если карты составляют Сет, то сформированное на прошлом этапе множество может содержать либо 1 элемент (1 или 3), либо 2 (1 и 3)
        let defaultSet: Set = [1,3]
        // Проверяем
        return setForCheckingSet.isSubset(of: defaultSet)
    }
}
