//
//  ViewController.swift
//  Anagrammy
//
//  Created by James Allen on 2/3/15.
//  Copyright (c) 2015 James M Allen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private let notificationManager = NotificationManager()
    
    var anaDict: AnaDict?
    
    var inputString: String = ""
    
    var items: [String] = []
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // this has to be dispatched on the main thread, otherwise it doesn't show
        notificationManager.registerObserver(dictionaryLoadingNotificationKey) { notification in
            SVProgressHUD.showWithStatus("Loading dictionary...", maskType: SVProgressHUDMaskType.Black)
        }
        
        notificationManager.registerObserver(dictionaryLoadedNotificationKey) { notificiation in
            SVProgressHUD.dismiss()
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.loadAnaDict()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let anaDict = self.anaDict {
            label.text! += items[indexPath.row] + " "
            self.inputString = self.inputString.removeString(items[indexPath.row])
            
            items = anaDict.getAnagrams(self.inputString)
            tableView.reloadData()
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        findAnagrams(textField)
        return true
    }


    @IBAction func findAnagrams(sender: AnyObject) {
        inputString = textField.text
        label.text = ""
        if let anaDict = self.anaDict {
            items = anaDict.getAnagrams(inputString)
        }
        tableView.reloadData()
    }

    func loadAnaDict() {
        var dictPath = NSBundle.mainBundle().pathForResource("3esl", ofType: "txt")!
        anaDict = AnaDict(wordsFile: dictPath)
    }
    
}

