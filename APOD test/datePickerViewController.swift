//
//  datePickerViewController.swift
//  APOD test
//
//  Created by Ron Cotton on 4/22/18.
// Copyright © 2018 Ron Cotton.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

protocol datePickerDelegate: class {
    func dateChanged(date: Date)
}

class datePickerViewController: UIViewController {
    @IBOutlet weak var APODdate: UIDatePicker!
    weak var delegate: datePickerDelegate?
    var returnDate : Date? = Date.init()
    
    @IBAction func APODChanged(_ sender: Any) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short

        returnDate = APODdate.date
    }
    
    @IBAction func OkAPODDatePicker(_ sender: Any) {
        delegate?.dateChanged(date: returnDate!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAPODDatePicker(_ sender: Any) {
        dismiss(animated: true, completion: nil) // return and do nothing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APODdate.maximumDate = Date() // maximum date to today
        // minimum date already set in attributes - June 16, 1995

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
