//
//  TripSummaryViewController.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/18/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit

class TripSummaryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let hourRange = [0, 1, 2, 3, 4, 5, 6]
    let tripCastModel = TripCastModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripCastModel.setDepartureTime(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            case "ShowMap":
                let destination = segue.destinationViewController as! ViewController
                tripCastModel.locations.removeAll()
                destination.getDirections()
            default:
                break
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hourRange.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Now"
        }
        else if row == 1 {
            return "In \(String(hourRange[row])) Hour"
        }
        else {
            return "In \(String(hourRange[row])) Hours"
        }
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tripCastModel.setDepartureTime(Double(row))
    }
}
