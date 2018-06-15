//
//  ViewController.swift
//  APOD test
//
//  Created by Ron Cotton on 4/14/18.
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

// code to allow Textbox to have other attributes (bold, italics, normal)
// https://stackoverflow.com/questions/28496093/making-text-bold-using-attributed-string-in-swift/37992022
extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString { // note bold is for title
        let attrs:  [NSAttributedStringKey: Any] = [.font: UIFont.boldSystemFont(ofSize: 20)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        self.append(boldString)
        
        return self
    }
    
    @discardableResult func italics(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.italicSystemFont(ofSize: 16)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        self.append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 16)]
        let normal = NSAttributedString(string: text, attributes: attrs)
        self.append(normal)
        
        return self
    }
    
    @discardableResult func newline() -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 16)]
        let normal = NSAttributedString(string: "\n\n", attributes: attrs)
        self.append(normal)
        
        return self
    }
}

class ViewController: UIViewController, datePickerDelegate {
    let apiKey : String = "DEMO_KEY" // replace API key with https://api.nasa.gov/index.html#apply-for-an-api-key

    @IBOutlet weak var ViewImage: UIImageView!
    @IBOutlet weak var TextBox: UITextView!
    
    struct photoInfo: Codable {
        var date: String
        var title: String
        var description: String
        var url: URL
        var copyright: String?
        enum CodingKeys: String, CodingKey {
            case date
            case title
            case description  = "explanation"
            case url
            case copyright
        }
    }
    
    @IBAction func APODTest(_ sender: Any) {
        performSegue(withIdentifier: "pickDate", sender: self)
    }
    
    func dateChanged(date: Date) {
        convertData(date: date)
    }
    
    private func requestAPOD(date : Date, callback: @escaping (photoInfo, UIImage) -> Void ) -> Void {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=" + apiKey + "&date=" + dateFormatter.string(from: date))!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if (self.errorHandlerResp(data: data, response: response, error: error)) {
                let jsonDecoder = JSONDecoder()
                //let leftdata = data!
                if let photoInfo = try? jsonDecoder.decode(photoInfo.self, from: data!) {
                    let task2 = URLSession.shared.dataTask(with: photoInfo.url) { (data, response, error) in
                        if (self.errorHandlerResp(data: data, response: response, error: error)) {
                            callback(photoInfo, UIImage(data: data!)!)
                        }
                    }
                    task2.resume()
                }
            }
        }
        task.resume()
    }
    

    public func convertData(date: Date) -> Void {
        requestAPOD(date: date, callback: {(info: photoInfo?, image: UIImage?) in
            DispatchQueue.main.async {
                let formattedString = NSMutableAttributedString()
                if info != nil {
                    if image != nil {
//                        let ratio = Float((image?.size.width)!) / Float((image?.size.height)!)
//                        let width = self.ViewImage.frame.width
//                        let calcHeight = Float(self.ViewImage.frame.width) * ratio
//                        self.ViewImage.frame = CGRect(x: 0.0, y: 0.0, width: Double(width), height: Double(calcHeight))
                        self.ViewImage.image = image
                    } else {
                        self.ViewImage.image = nil
                    }
                    formattedString.bold((info?.title)!).newline().normal((info?.description)!).newline()
                    if info?.copyright == nil {
                        formattedString.italics("Copyright: Public Domain")
                    } else {
                        formattedString.italics("Copyright: " + (info?.copyright)!)
                    }
                } else {
                formattedString.bold("No Title").newline().normal("No Description")
                }
                self.TextBox.attributedText = formattedString
            }
        })
    } // end convertData
    
    private func errorHandlerResp(data: Data?, response: URLResponse?, error: Error?) -> Bool {
        let httpResponse = response as! HTTPURLResponse
        let title = "NASA APOD Error"
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                alertControl(title: title, message: "APIkey cannot currently handle any more responses...")
            } else { // key is dead
                alertControl(title: title, message: "Unexpected httpResponse code...")
            }
            return false
        }
        guard data != nil else {
            alertControl(title: title, message: "No Entry for this day, try another day.")
            return false
        }
        guard error == nil else {
            alertControl(title: title, message: "Unexpected Error.")
            return false
        }
        return true
    }
    
    func alertControl(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        convertData(date: Date.init())
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? datePickerViewController {
            vc.delegate = self
        }
    }
}

