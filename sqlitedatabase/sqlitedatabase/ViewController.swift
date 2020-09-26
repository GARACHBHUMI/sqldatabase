//
//  ViewController.swift
//  sqlitedatabase
//
//  Created by ravi on 18/09/20.
//  Copyright © 2020 ravi. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    var contacts = [Contact]()
    var db : OpaquePointer?
    var timer = Timer()
    
    @IBOutlet weak var queryVal: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var addField: UITextField!
    @IBOutlet weak var contactsTable: UITableView!
    
    let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("ContactDatabase.sqlite")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return
        }
        let createTableQuery = "CREATE TABLE IF NOT EXISTS Contact(name TEXT,phone TEXT,address TEXT)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK
        {
            print("error creatin table")
            return
        }
        print("everything is fine")
        
        
        contactsTable.delegate = self
        contactsTable.dataSource = self
    }
    @IBAction func clearTextField(_ sender: UIButton) {
        nameField.text = ""
        phoneField.text = ""
        addField.text = ""
    }
    
    @IBAction func insertAction(_ sender: UIButton) {
        let name  = nameField.text!
        let phone = phoneField.text!
        let address = addField.text!
        // var arr = [name,phone,address]
        
        if sqlite3_open(fileUrl.path, &db) == SQLITE_OK
        {
            
            if (name.isEmpty)
            {
                queryVal.textColor = .red
                queryVal.text = "name is empty"
                return
            }
            if(phone.isEmpty)
            {
                 queryVal.textColor = .red
                queryVal.text = "phone is empty"
                return
            }
            if(phone.count != 10)
            {
                queryVal.textColor = .red
                queryVal.text = "phone number is not valid"
                return
            }
            if(address.isEmpty)
            {
                queryVal.textColor = .red
                queryVal.text = "adrress is empty"
                return
            }
            var stmt:OpaquePointer?
            
            
            
            if sqlite3_prepare_v2(db, "INSERT INTO Contact(name,phone,address) VALUES(?,?,?)", -1, &stmt, nil) == SQLITE_OK {
                
                sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 2, (phone as NSString).utf8String, -1, nil)
                sqlite3_bind_text(stmt, 3, (address as NSString).utf8String, -1, nil)
                
            }
            else
            {
                print("query is not per requiremnet ")
            }
            if sqlite3_step(stmt) == SQLITE_DONE
            {
                queryVal.text = "inserted data into table successfully"
                timer  = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting contact: \(errmsg)")
                return
            }
            sqlite3_finalize(stmt)
        }
        
        sqlite3_close(db)
    }
    
   @objc func timerAction()
   {
       queryVal.text = ""
       // we can clear textbox here too
    }
    
    @IBAction func updateAction(_ sender: UIButton) {
        print("update is clicked")
        let nameupdate = nameField.text!
        let phoneupdate = phoneField.text!
        
        var updateStatement: OpaquePointer?
        let updatestatementstring = "UPDATE Contact SET phone = (?) WHERE name = (?)"
        
        if sqlite3_open(fileUrl.path, &db) == SQLITE_OK
        {
            
            if sqlite3_prepare_v2(db, updatestatementstring, -1, &updateStatement, nil) ==
                SQLITE_OK
            {
                sqlite3_bind_text(updateStatement, 1, (phoneupdate as NSString).utf8String, -1, nil)
                sqlite3_bind_text(updateStatement, 2, (nameupdate as NSString).utf8String, -1, nil)
                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    queryVal.text = "Successfully updated row."
                    print("\nSuccessfully updated row.")
                } else {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("\nCould not update row.\(errmsg)")
                    queryVal.text = errmsg
                }
            }
                
            else
            {
                print("\nUPDATE statement is not prepared")
            }
            sqlite3_finalize(updateStatement)
        }
        sqlite3_close(db)
        
    }
    @IBAction func deleteAction(_ sender: UIButton) {
        let namedelete = nameField.text!
        print("delete clicked")
        var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM Contact where name = (?)"
        
        if sqlite3_open(fileUrl.path, &db) == SQLITE_OK
        {
            
            
            if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK
            {
                sqlite3_bind_text(deleteStatement, 1, (namedelete as NSString).utf8String, -1, nil)
                if sqlite3_step(deleteStatement) == SQLITE_DONE {
                    queryVal.text = "Successfully deleted row."
                    print("\nSuccessfully deleted row.")
                } else {
                    queryVal.textColor = UIColor.red
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    queryVal.text = errmsg
                    print("\nCould not delete row.\(errmsg)")
                }
                
            }
            else{
                print("delete statement could not prepared")
            }
            sqlite3_finalize(deleteStatement)
        }
        sqlite3_close(db)
        
    }
    @IBAction func selectRow(_ sender: UIButton) {
         contacts.removeAll()
        //        let nameselect = nameField.text!
        var selectStatement: OpaquePointer?
        let selectquery = "SELECT name,phone FROM Contact"
        
        if sqlite3_open(fileUrl.path, &db) == SQLITE_OK
        {
            print("open database")
            if sqlite3_prepare_v2(db, selectquery, -1, &selectStatement, nil) == SQLITE_OK
            {
                while (sqlite3_step(selectStatement) == SQLITE_ROW)
                {
                    guard let queryResultCol1 = sqlite3_column_text(selectStatement, 0)
                        else {
                            print("Query1 result is nil.")
                            return
                    }
                    guard let queryResultCol2 = sqlite3_column_text(selectStatement, 1)
                        else {
                            print("Query2 result is nil.")
                            return
                    }
                    let name = String(cString: queryResultCol1)
                    let phone = String(cString: queryResultCol2)
                    print(" \(name) \(phone)")
                    
                    let newcon = Contact(name: name, phone: phone, address:"landon")
                    contacts.append(newcon)
                }
                
                
            }
            else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("\nQuery is not prepared \(errorMessage)")
            }
            
             contactsTable.reloadData()
            
        }
        sqlite3_close(db)
       
    }
    
    //mark table methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contactsTable.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        //        var lable: UILabel!
        //        lable = cell.viewWithTag(1) as?  UILabel
        //        lable.text = contacts[indexPath.row].name
        //
        //        lable = cell.viewWithTag(2) as? UILabel // Phone label
        //        lable?.text = contacts[indexPath.row].phone

        cell.textLabel?.text =
            "\(contacts[indexPath.row].name)" + "  " + "\(contacts[indexPath.row].phone)"
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row selected")
        
    }
    
}

