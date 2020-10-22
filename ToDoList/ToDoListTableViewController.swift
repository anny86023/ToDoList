//
//  ToDoListTableViewController.swift
//  ToDoList
//
//  Created by anny on 2020/10/12.
//  Copyright © 2020 anny. All rights reserved.
//

import UIKit
import UserNotifications

class MyTableViewCell:  UITableViewCell{
    
    @IBOutlet weak var checkout: UIButton!
    @IBOutlet weak var check: UIButton!
    @IBOutlet weak var labelTime: UILabel!
    
}

class ToDoListTableViewController: UITableViewController, UITextFieldDelegate {
    
    var todoList = [ToDoList]()
    var finishList = [FinishList]()
    var detailUpdateRow = 0
    
    @IBOutlet weak var myTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delaysContentTouches = false
        
        // 新增 navigationItem edit 編輯按鈕
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.editButtonItem.tintColor = .systemPink
        
        // 讀取ToDoList、FinishList資料
        if let todolist = ToDoList.loadFromFile(),let finilist = FinishList.loadFromFile(){
            self.todoList = todolist
            self.finishList = finilist
        }
        
        myTextField.delegate = self
        
        //設置點擊事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(closekeyboard))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
    }
    
    // 新增待辦事項＿按鈕執行動作
    @IBAction func addList(_ sender: UIButton) {
        if let toDo = myTextField.text{
            if toDo != ""{
                todoList.append(ToDoList(todo: toDo, note: "", date: ""))
                tableView.reloadData()
            }
            myTextField.text = ""
            myTextField.resignFirstResponder()
        }
        //寫入List資料 將清單存到手機中
        ToDoList.saveToFile(todo: todoList, fini: finishList)
    }
    
    //點擊Return鍵收鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          myTextField.resignFirstResponder()
          return true
    }
    
    //點擊空白處收鍵盤
    @objc func closekeyboard(sender: UITapGestureRecognizer) {
        //print("closekeyboard")
        myTextField.resignFirstResponder()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return todoList.count
        }else{
            return finishList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyTableViewCell
        let finishcell = tableView.dequeueReusableCell(withIdentifier: "finish", for: indexPath) as! MyTableViewCell
        
        if indexPath.section == 0{
            cell.textLabel?.text = todoList[indexPath.row].todo
            cell.labelTime.text = todoList[indexPath.row].date
            // 進入判斷是否需要設置推播通知
            checkdate(todolist: todoList[indexPath.row])
            cell.checkout.tag = indexPath.row
            return cell
        }else{
            // 灰字+刪除線+斜體
            let AttributedString = NSMutableAttributedString(string: finishList[indexPath.row].finish)
            AttributedString.setAttributes([.foregroundColor: UIColor.gray, .strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue), .obliqueness: 0.5], range: NSMakeRange(0, AttributedString.length))

            finishcell.textLabel?.attributedText = AttributedString
            finishcell.check.tag = indexPath.row
            return finishcell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Undone"
        }else{
            return "Finish"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            detailUpdateRow = indexPath.row
            performSegue(withIdentifier: "showDetail", sender: nil)
        }
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0{
                todoList.remove(at: indexPath.row)
            }else{
                finishList.remove(at: indexPath.row)
            }
        }
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.reloadData()
        //寫入List資料 將清單存到手機中
        ToDoList.saveToFile(todo: todoList, fini: finishList)
    }
    
    // 各 cell 是否可以進入編輯狀態 及 左滑刪除
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if fromIndexPath.section == 0{
            // 將移動的項目賦值給 move
            let move = todoList[fromIndexPath.row]
            // 將原有位置的項目刪除
            todoList.remove(at: fromIndexPath.row)
            // 將剛剛移動的項目插入到新的位置
            todoList.insert(move, at: to.row)
        }else{
            let move = finishList[fromIndexPath.row]
            finishList.remove(at: fromIndexPath.row)
            finishList.insert(move, at: to.row)
        }
        tableView.reloadData()
        //寫入List資料 將清單存到手機中
        ToDoList.saveToFile(todo: todoList, fini: finishList)
    }
    

    //拖拽某行到一个目标上方时触发该方法，询问是否移动或者修正
    override func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        //如果目标位置和拖动行不是同一个分区，则拖动行返回自己原来的分区
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
//            var row = 0
//            //如果是往下面的分区拖动，则回到原分区末尾
//            //如果是往上面的分区拖动，则会到原分区开头位置
//            if sourceIndexPath.section < proposedDestinationIndexPath.section {
//                row = tableView.numberOfRows(inSection: sourceIndexPath.section)-1
//            }
//            return IndexPath(row: row, section: sourceIndexPath.section)
            return sourceIndexPath
        }else{
           return proposedDestinationIndexPath
        }
        //return proposedDestinationIndexPath
    }
    
    @IBAction func checkBtnAction(_ sender: UIButton) {
        let index = sender.tag
        print("Button with tag: \(index) clicked in todocell!")
        finishList.append(FinishList(finish: todoList[index].todo))
        tableView.reloadData()
        
        todoList.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        tableView.reloadData()
        
        //寫入List資料 將清單存到手機中
        ToDoList.saveToFile(todo: todoList, fini: finishList)
    }
    
    @IBAction func uncheckBtnAction(_ sender: UIButton) {
        let index = sender.tag
        print("Button with tag: \(index) clicked in finishcell!")
        todoList.append(ToDoList(todo: finishList[index].finish, note: "", date: ""))
        tableView.reloadData()
        
        finishList.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .fade)
        tableView.reloadData()
        
        //寫入List資料 將清單存到手機中
        ToDoList.saveToFile(todo: todoList, fini: finishList)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            if let detail = segue.destination as? DetailTableViewController{
                detail.todolist = todoList[detailUpdateRow]
            }
        }
    }
    
    @IBAction func unwindDetailBack(segue: UIStoryboardSegue) { // 註冊Unwind segue的標記
        let update = segue.source as? DetailTableViewController
        if let updateDate = update?.todolist{
            todoList[detailUpdateRow] = updateDate
            tableView.reloadData()
            //寫入List資料
            ToDoList.saveToFile(todo: todoList, fini: finishList)
        }
    }
    
    func checkdate(todolist: ToDoList){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd a hh:mm" // 設定要顯示在日期時間格式
        dateFormatter.amSymbol = "上午"
        dateFormatter.pmSymbol = "下午"
        
        if todolist.date != ""{
            // 時間dateString 改成 date
            if let date = dateFormatter.date(from: todolist.date){
                let list = (todo: todolist.todo, note: todolist.note, date: date)
                createNotification(list: list)
                //print("成功提醒")
            }
        }
    }
    
    func createNotification(list: (todo: String, note: String, date: Date)){
        // 設定提醒內容
        let content = UNMutableNotificationContent()
        content.title = "來提醒你囉!"
        content.subtitle = "事項:" + list.todo
        content.body = "備註:" + list.note
        content.badge = 1
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: list.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
           
        let request = UNNotificationRequest(identifier: list.todo, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}
