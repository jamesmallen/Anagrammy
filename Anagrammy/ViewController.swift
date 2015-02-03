//
//  ViewController.swift
//  Anagrammy
//
//  Created by James Allen on 2/3/15.
//  Copyright (c) 2015 James M Allen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var anaDict: AnaDict?
    
    var items: [String] = []
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // SVProgressHUD.showWithStatus("Loading words...")
        dispatch_async(dispatch_get_main_queue(), {
            SVProgressHUD.showWithStatus("Loading dictionary...", maskType: SVProgressHUDMaskType.Black)
            })
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.loadAnaDict()
            dispatch_async(dispatch_get_main_queue(), {
                SVProgressHUD.dismiss()
            })
        })
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        items = ["Eenie", "Meenie", "Miney"]
        
        
        /*
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [[MyServer sharedManager] fetchFromServerwithCompletionHandler:^(NSArray *elements, BOOL error) {
                _elements = elements;
                [_elementsTableView reloadData];
                [SVProgressHUD dismiss];
                }];
            });
        
        */
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
        // noop
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        findAnagrams(textField)
        return true
    }


    @IBAction func findAnagrams(sender: AnyObject) {
        if let anaDict = self.anaDict {
            items = anaDict.getAnagrams(textField.text)
        }
        tableView.reloadData()
    }

    func loadAnaDict() {
        var dictPath = NSBundle.mainBundle().pathForResource("3esl", ofType: "txt")!
        anaDict = AnaDict(wordsFile: dictPath)
    }
    
}
