//
//  AddStockPopoverViewController.swift
//  KStockData
//
//  Created by khr on 7/3/15.
//  Copyright (c) 2015 khr. All rights reserved.
//

import UIKit

class AddStockPopoverViewController: UIViewController, UITextFieldDelegate {
  @IBOutlet var symbolTextField: UITextField!
  @IBOutlet var overBoughtSold: UISegmentedControl!
  @IBOutlet var presentingPopoverController: UIPopoverController!
  @IBOutlet var masterViewController: KSDMasterViewController!

  let stockDataRetriever = StockDataRetriever()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    let symbol = textField.text!.uppercaseString
    stockDataRetriever.stockDataFor(symbol, commands: "e1") {
      (data: NSData?, response: NSURLResponse?, error: NSError?) in
      let csv = NSString(data: data!, encoding: NSUTF8StringEncoding)
      let array = csv!.khr_csv()

      if array[0] as! String == "N/A" {
        _ = self.masterViewController.fetchedResultsController.managedObjectContext
        let entity = self.masterViewController.fetchedResultsController.fetchRequest.entity
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "symbol == \(symbol)")

        
      }
    }
    return true;
  }
}
