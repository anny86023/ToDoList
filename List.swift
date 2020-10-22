//
//  List.swift
//  ToDoList
//
//  Created by anny on 2020/10/21.
//  Copyright © 2020 anny. All rights reserved.
//

import Foundation

struct ToDoList:Codable {
    var todo: String
    var note: String
    var date: String
    
    static func saveToFile(todo:[ToDoList], fini:[FinishList]){
        let saveToDo = try? JSONEncoder().encode(todo)
        let saveFini = try? JSONEncoder().encode(fini)
        
        UserDefaults.standard.set(saveToDo, forKey: "ToDoList")
        UserDefaults.standard.set(saveFini, forKey: "FinishList")
    }
    
    static func loadFromFile() -> [ToDoList]?{
        guard let loadDate = UserDefaults.standard.data(forKey: "ToDoList") else {return nil}
        return try? JSONDecoder().decode([ToDoList].self, from: loadDate)
    }
    
}

struct FinishList:Codable {
    var finish: String
    
    static func loadFromFile() -> [FinishList]?{
        guard let loadDate = UserDefaults.standard.data(forKey: "FinishList") else {return nil}
        return try? JSONDecoder().decode([FinishList].self, from: loadDate)
    }
}
