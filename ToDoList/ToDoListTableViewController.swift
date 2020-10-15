//
//  ToDoListTableViewController.swift
//  ToDoList
//
//  Created by anny on 2020/10/12.
//  Copyright © 2020 anny. All rights reserved.
//

import UIKit

class ToDoListTableViewController: UITableViewController {
    
    var toDoList = UserDefaults.standard.stringArray(forKey: "ToDoList") ?? [String]()
    var finishList = UserDefaults.standard.stringArray(forKey: "FinishList") ?? [String]()
    var addButton :UIButton!
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myTextField: UITextField!
    
    // 新增待辦事項＿按鈕執行動作
    @objc func addList(_ sender: Any) {
        if let list = myTextField.text{
            if list != ""{
                toDoList.append(list)
                // 將清單存到手機中
                UserDefaults.standard.set(toDoList, forKey: "ToDoList")
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
        // 新增事項的按鈕
        addButton = UIButton(type: .contactAdd)
        addButton.center = CGPoint(x: 345, y: 25)
        addButton.addTarget(self, action: #selector(ToDoListTableViewController.addList(_:)), for: .touchUpInside)
        //self.view.addSubview(addButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        myTextField.becomeFirstResponder()
        self.view.addSubview(addButton)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let finishcell = tableView.dequeueReusableCell(withIdentifier: "finish", for: indexPath)
        func removeButtonFromCellContentView(){
            // 移除舊的按鈕
            for view in cell.contentView.subviews {
                if let v = view as? UIButton {
                    v.removeFromSuperview()
                }
            }
        }
        
        if indexPath.section == 0{
            cell.textLabel?.text = toDoList[indexPath.row]
            removeButtonFromCellContentView()
            
            // 完成事項的按鈕
            let checkBtn = UIButton(frame: CGRect(x: 317, y: 3.67, width: 43, height: 43))
            checkBtn.setImage(UIImage(named: "checkbox"), for: .normal)
            checkBtn.setImage(UIImage(named: "check"), for: .highlighted)
            checkBtn.tag = indexPath.row
            checkBtn.addTarget(self, action: #selector(ToDoListTableViewController.checkBtnAction), for: .touchUpInside)
            cell.contentView.addSubview(checkBtn)
            
            return cell
            
        }else{
            finishcell.textLabel?.text = finishList[indexPath.row]
            removeButtonFromCellContentView()
            
            // 返回未完成事項的按鈕
            let uncheckBtn = UIButton(frame: CGRect(x: 317, y: 3.67, width: 43, height: 43))
            uncheckBtn.setImage(UIImage(named: "check"), for: .normal)
            uncheckBtn.setImage(UIImage(named: "checkbox"), for: .highlighted)
            uncheckBtn.tag = indexPath.row
            uncheckBtn.addTarget(self, action: #selector(ToDoListTableViewController.uncheckBtnAction), for: .touchUpInside)
            finishcell.contentView.addSubview(uncheckBtn)
            
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
            // 更新事項
            let updateAlertController = UIAlertController(title: "更新", message: nil, preferredStyle: .alert)
            
            // 建立輸入框
            updateAlertController.addTextField { (textFields) in
                textFields.placeholder = "更新事項"
                textFields.text = self.toDoList[indexPath.row]
            }
            
            // 建立更新按鈕
            let updateAction = UIAlertAction(title: "完成", style: .default) { (UIAlertAction) in
                if let updata = updateAlertController.textFields![0].text{
                    // 有輸入內容才做更新
                    if updata != ""{
                        self.toDoList[indexPath.row] = updata
                        UserDefaults.standard.set(self.toDoList, forKey: "ToDoList")
                        self.myTableView.reloadData()
                    }
                }
            }
            updateAlertController.addAction(updateAction)

            // 建立取消按鈕
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            updateAlertController.addAction(cancelAction)
            
            // 顯示提示框
            present(updateAlertController, animated: true, completion: nil)
        }
        
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if indexPath.section == 0{
                print("delete : ToDoList \(indexPath.row) row")
                toDoList.remove(at: indexPath.row)
                //tableView.deleteRows(at: [indexPath], with: .fade)
                myTableView.reloadData()
                UserDefaults.standard.set(self.toDoList, forKey: "ToDoList")
                
            }else{
                print("delete : FinishList \(indexPath.row) row")
                finishList.remove(at: indexPath.row)
                //tableView.deleteRows(at: [indexPath], with: .fade)
                myTableView.reloadData()
                UserDefaults.standard.set(self.finishList, forKey: "FinishList")
            }
        }
    }
    
    // 各 cell 是否可以進入編輯狀態 及 左滑刪除
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //完成代辦事項＿按鈕執行動作
    @objc func checkBtnAction(_ sender: UIButton) {
        let index = sender.tag
        print("Button with tag: \(index) clicked in cell!")
        finishList.append(toDoList[index])
        myTableView.reloadData()
        UserDefaults.standard.set(finishList, forKey: "FinishList")
        
        toDoList.remove(at: index)
        myTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        myTableView.reloadData()
        UserDefaults.standard.set(toDoList, forKey: "ToDoList")
    }
    
    //完成代辦事項＿按鈕執行動作
    @objc func uncheckBtnAction(_ sender: UIButton) {
        let index = sender.tag
        print("Button with tag: \(index) clicked in finishcell!")
        toDoList.append(finishList[index])
        myTableView.reloadData()
        UserDefaults.standard.set(toDoList, forKey: "ToDoList")
        
        finishList.remove(at: index)
        myTableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .fade)
        myTableView.reloadData()
        UserDefaults.standard.set(finishList, forKey: "FinishList")
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showDetail"{
//            if let detail = segue.destination as? DetailViewController{
//                detail.animal = sender as? String
//                // 設定下一頁標題～
//                detail.navigationItem.title = sender as? String
//            }
//        }
//    }


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
