//
//  DetailTableViewController.swift
//  ToDoList
//
//  Created by anny on 2020/10/18.
//  Copyright © 2020 anny. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController, UITextFieldDelegate {
    var todolist: ToDoList?
    var date = ""

    @IBOutlet weak var myTextField: UITextField!
    @IBOutlet weak var myTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var timeSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction func dateSwitch(_ sender: UISwitch) {
        if sender.isOn == true{
            datePicker.datePickerMode = UIDatePicker.Mode.date
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }else{
            timeSwitch.isOn = false
            date = ""
            dateLabel.text = date // 更新dateLabel的內容
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    @IBAction func timeSwitch(_ sender: UISwitch) {
        if sender.isOn == true{
            datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
            
        }else{
            datePicker.datePickerMode = UIDatePicker.Mode.date
        }
    }
    
    // 取得 datePicker 選取日期
    @IBAction func dateSelect(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        if timeSwitch.isOn == true{
            dateFormatter.dateFormat = "YYYY/MM/dd a hh:mm" // 設定要顯示在日期時間格式
        }else{
            dateFormatter.dateFormat = "YYYY/MM/dd" // 設定要顯示在日期時間格式
        }
        dateFormatter.amSymbol = "上午"
        dateFormatter.pmSymbol = "下午"
        
        print(dateFormatter.string(from: datePicker.date))
        date = dateFormatter.string(from: datePicker.date)
        dateLabel.text = date // 更新dateLabel的內容
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTextField.text = todolist?.todo
        myTextView.text = todolist?.note
        
        if todolist?.date == ""{
            dateSwitch.isOn = false
        }else{
            dateSwitch.isOn = true
        }
        
        //設置點擊事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(closekeyboard))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
    }
    
    //點擊空白處收鍵盤
    @objc func closekeyboard(sender: UITapGestureRecognizer) {
        print("closekeyboard")
        myTextField.resignFirstResponder()
    }
    
    // 傳值回前一頁
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let todo = myTextField.text ?? ""
        let note = myTextView.text ?? ""
        todolist = ToDoList(todo: todo, note: note, date: date)
    }
    
    //檢查代辦事項是否為空
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if myTextField.text?.isEmpty == false{
            return true
        }else{
            let alertcontroller = UIAlertController(title: "錯誤", message: "請輸入代辦事項！", preferredStyle: .alert)
            alertcontroller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertcontroller, animated: true, completion: nil)
            return false
        }
    }
    
    // MARK: - Table view data source
    
    // dateSwitch 開關隱藏/顯示 datePicker cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.section, indexPath.row){
            case(1, 1):
                return dateSwitch.isOn ? 50 : 0
            case(1, 2):
                return dateSwitch.isOn ? 150 : 0
            case(1, 3):
                return dateSwitch.isOn ? 50 : 0
            default:
                return 50
        }
    }
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
     
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
*/
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

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
