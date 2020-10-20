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

class ToDoListTableViewController: UITableViewController {
    
    var toDoList = UserDefaults.standard.stringArray(forKey: "ToDoList") ?? [String]()
    var finishList = UserDefaults.standard.stringArray(forKey: "FinishList") ?? [String]()
    var dateLabel = UserDefaults.standard.stringArray(forKey: "DateLabel") ?? [String]()
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myTextField: UITextField!
    
    // 新增待辦事項＿按鈕執行動作
    @IBAction func addList(_ sender: UIButton) {
        if let list = myTextField.text{
            if list != ""{
                toDoList.append(list)
                dateLabel.append("")
                // 將清單存到手機中
                UserDefaults.standard.set(toDoList, forKey: "ToDoList")
                UserDefaults.standard.set(toDoList, forKey: "DateLabel")
                myTableView.reloadData()
            }
            myTextField.text = ""
            myTextField.resignFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delaysContentTouches = false
        //https://medium.com/@dafu1231/%E5%9C%A8uitableviewcell%E4%B8%8A%E7%9A%84button%E7%9A%84highlight-626f451ed023
        
        // 新增 navigationItem edit 編輯按鈕
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.editButtonItem.tintColor = .systemPink
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myTextField.becomeFirstResponder()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return toDoList.count
        }else{
            return finishList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyTableViewCell
        let finishcell = tableView.dequeueReusableCell(withIdentifier: "finish", for: indexPath) as! MyTableViewCell
        
        if indexPath.section == 0{
            cell.textLabel?.text = toDoList[indexPath.row]
            cell.labelTime.text = dateLabel[indexPath.row]
   
            if dateLabel[indexPath.row] != ""{
                createNotification(todo: toDoList[indexPath.row], dateString: dateLabel[indexPath.row])
            }
            
            cell.checkout.tag = indexPath.row
            return cell
        }else{
            // 灰字+刪除線+斜體
            let AttributedString = NSMutableAttributedString(string: finishList[indexPath.row])
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
    
    var detailUpdateRow = 0
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let todo = toDoList[indexPath.row]
            detailUpdateRow = indexPath.row
            performSegue(withIdentifier: "showDetail", sender: todo)
            print("按下的是 \(todo) 的 detail")
        }
        
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0{
                print("delete : ToDoList \(indexPath.row) row")
                toDoList.remove(at: indexPath.row)
                dateLabel.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                myTableView.reloadData()
                UserDefaults.standard.set(self.toDoList, forKey: "ToDoList")
                UserDefaults.standard.set(self.dateLabel, forKey: "DateLabel")
                
            }else{
                print("delete : FinishList \(indexPath.row) row")
                finishList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                myTableView.reloadData()
                UserDefaults.standard.set(self.finishList, forKey: "FinishList")
            }
        }
    }
    
    // 各 cell 是否可以進入編輯狀態 及 左滑刪除
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if fromIndexPath.section == 0{
            // 將移動的項目賦值給 number
            let move = toDoList[fromIndexPath.row]
            // 將原有位置的項目刪除
            toDoList.remove(at: fromIndexPath.row)
            // 將剛剛移動的項目插入到新的位置
            toDoList.insert(move, at: to.row)
        }else{
            // 將移動的項目賦值給 number
            let move = finishList[fromIndexPath.row]
            // 將原有位置的項目刪除
            finishList.remove(at: fromIndexPath.row)
            // 將剛剛移動的項目插入到新的位置
            finishList.insert(move, at: to.row)
        }
        
        myTableView.reloadData()
        UserDefaults.standard.set(self.toDoList, forKey: "ToDoList")
        UserDefaults.standard.set(self.finishList, forKey: "FinishList")
        
        //https://medium.com/@JJeremy.XUE/swift-tableview-%E4%B9%8B-editing-style-f8b48769d026
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
        print("Button with tag: \(index) clicked in cell!")
        finishList.append(toDoList[index])
        myTableView.reloadData()
        UserDefaults.standard.set(finishList, forKey: "FinishList")
        
        toDoList.remove(at: index)
        dateLabel.remove(at: index)
        myTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        myTableView.reloadData()
        UserDefaults.standard.set(toDoList, forKey: "ToDoList")
        UserDefaults.standard.set(dateLabel, forKey: "DateLabel")
    }
    
    @IBAction func uncheckBtnAction(_ sender: UIButton) {
        let index = sender.tag
        print("Button with tag: \(index) clicked in finishcell!")
        toDoList.append(finishList[index])
        myTableView.reloadData()
        UserDefaults.standard.set(toDoList, forKey: "ToDoList")
        
        finishList.remove(at: index)
        dateLabel.append("")
        myTableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .fade)
        myTableView.reloadData()
        UserDefaults.standard.set(finishList, forKey: "FinishList")
        UserDefaults.standard.set(dateLabel, forKey: "DateLabel")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            if let detail = segue.destination as? DetailTableViewController{
                detail.myText = sender as? String
            }
        }
    }

    @IBAction func unwindDetailBack(segue: UIStoryboardSegue) { // 註冊Unwind segue的標記
        let updateToDo = segue.source as? DetailTableViewController
        if let update = updateToDo?.updateToDo , let date = updateToDo?.dateLabel{
            print(update)
            toDoList[detailUpdateRow] = update
            dateLabel[detailUpdateRow] = date
            
            myTableView.reloadData()
            UserDefaults.standard.set(toDoList, forKey: "ToDoList")
            UserDefaults.standard.set(dateLabel, forKey: "DateLabel")
        }
    }

    func createNotification(todo:String, dateString:String){
        print(todo + " : " + dateString)
        
        // 時間dateString 改成 date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd a hh:mm" // 設定要顯示在日期時間格式
        dateFormatter.amSymbol = "上午"
        dateFormatter.pmSymbol = "下午"
        let date = dateFormatter.date(from: dateString)
        
        // 設定提醒內容
        let content = UNMutableNotificationContent()
        content.title = "來提醒你囉～"
        content.subtitle = todo
        content.body = ""
        content.badge = 1
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
           
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: todo, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    
    
    
    
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
