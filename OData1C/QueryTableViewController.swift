//
//  QueryTableViewController.swift
//  OData1C
//
//  Created by Denis Zubkov on 26/04/2019.
//  Copyright © 2019 DenZu. All rights reserved.
//

import UIKit

class QueryTableViewController: UITableViewController, UITextFieldDelegate {

    
    @IBOutlet weak var schemeTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var databaseTextField: UITextField!
    
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var resourceTextField: UITextField!
    @IBOutlet weak var selectionFieldTextField: UITextField!
    @IBOutlet weak var filterTextField: UITextField!
    @IBOutlet weak var orderTextField: UITextField!
    
    @IBOutlet weak var outputTextView: UITextView!
    
    
     @IBOutlet weak var requestButton: UIButton!
    
    
   
    @IBAction func requestPressed(_ sender: Any) {
        let urlComponents = getUrlComponents()
        guard let url = urlComponents?.url else { return }
        print(url.absoluteURL.absoluteString)
        downloadData(url: url) { data in
            if let data = data {
                DispatchQueue.main.async {
                    self.outputTextView.text = String(data: data, encoding: .utf8)
                }
            } else {
                
            }
        }
    }
    
        
        
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        schemeTextField.delegate = self
        serverTextField.delegate = self
        portTextField.delegate = self
        databaseTextField.delegate = self
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        resourceTextField.delegate = self
        selectionFieldTextField.delegate = self
        filterTextField.delegate = self
        
        orderTextField.delegate = self
        
        
        requestButton.layer.borderWidth = 2
        requestButton.layer.cornerRadius = 22
        requestButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        outputTextView.text = ""
    
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupTextField()
        requestButton.isEnabled = checkInputData()
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        requestButton.isEnabled = checkInputData()
        if let text = sender.text {
            UserDefaults.standard.setValue(text, forKey: String(sender.tag))
        }

        
    }

    
    func checkInputData() -> Bool {
        if schemeTextField.text == nil ||
            serverTextField.text == nil ||
            portTextField.text == nil ||
            databaseTextField.text == nil ||
            loginTextField.text == nil ||
            passwordTextField.text == nil ||
            resourceTextField.text == nil ||
            schemeTextField.text == "" ||
            serverTextField.text == "" ||
            portTextField.text == "" ||
            databaseTextField.text == "" ||
            loginTextField.text == "" ||
            passwordTextField.text == "" ||
            resourceTextField.text == "" {
           return false
        } else {
            return true
        }
    }
    
    func setupTextField() {
        schemeTextField.text = UserDefaults.standard.value(forKey: "9") as? String
        serverTextField.text = UserDefaults.standard.value(forKey: "0") as? String
        portTextField.text = UserDefaults.standard.value(forKey: "1") as? String
        databaseTextField.text = UserDefaults.standard.value(forKey: "2") as? String
        loginTextField.text = UserDefaults.standard.value(forKey: "3") as? String
        passwordTextField.text = UserDefaults.standard.value(forKey: "4") as? String
        resourceTextField.text = UserDefaults.standard.value(forKey: "5") as? String
        selectionFieldTextField.text = UserDefaults.standard.value(forKey: "6") as? String
        filterTextField.text = UserDefaults.standard.value(forKey: "7") as? String
        orderTextField.text = UserDefaults.standard.value(forKey: "8") as? String
 
    }
    
    func getUrlComponents() -> URLComponents? {
        var urlComponents = URLComponents()
        urlComponents.scheme = schemeTextField.text
        urlComponents.host = serverTextField.text
        if let port = Int(portTextField.text ?? "80") {
            urlComponents.port = port
        }
        guard let database = databaseTextField.text else { return nil }
        guard let resource = resourceTextField.text else { return nil }
        let path = "/" + database + "/odata/standard.odata/" + resource
        urlComponents.path = path
        var queryItems: [URLQueryItem] = []
        if var filter = filterTextField.text, filter != "" {
            filter = filter.replacingOccurrences(of: "’", with: "'")
            let filterItem = URLQueryItem(name: "$filter", value: filter)
            queryItems.append(filterItem)
        }
        
        if var select = selectionFieldTextField.text, select != "" {
            select = select.replacingOccurrences(of: "’", with: "'")
            let selectItem = URLQueryItem(name: "$select", value: select)
            queryItems.append(selectItem)
        }
        
        if var orderBy = orderTextField.text, orderBy != "" {
            orderBy = orderBy.replacingOccurrences(of: "’", with: "'")
            let orderItem = URLQueryItem(name: "$orderby", value: orderBy)
            queryItems.append(orderItem)
        }
        
        let formatItem = URLQueryItem(name: "$format", value: "json")
        queryItems.append(formatItem)
                urlComponents.queryItems = queryItems
        if let login = loginTextField.text {
            urlComponents.user = login
        }
        if let password = passwordTextField.text {
            urlComponents.password = password
        }
        return urlComponents
    }
    
    func downloadData(url: URL, completion: @escaping (Data?) -> Void) {
        
        let request = URLRequest(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request)  { data, response, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(error?.localizedDescription.data(using: .utf8))
                }
            }
            guard let data = data else { return }
            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode != 200 {
                let statusCodeString = String(response.statusCode)
                completion(statusCodeString.data(using: .utf8))
                return
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
        task.resume()
        
    }

}
