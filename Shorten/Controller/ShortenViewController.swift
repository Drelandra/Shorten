//
//  ViewController.swift
//  Shorten
//
//  Created by Andre Elandra on 16/06/20.
//  Copyright © 2020 Andre Elandra. All rights reserved.
//

import UIKit
import CoreData

class ShortenViewController: UIViewController {
    
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shortenTableView: UITableView!
    
    var shortenManager = ShortenManager()
    var shortenUrlArray = [ShortenUrl]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var originalURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addCancelTapGesture()
        loadShortenUrls()
    }
    
    func setupUI() {
        shortenManager.delegate = self
        urlTextField.delegate = self
        shortenTableView.delegate = self
        shortenTableView.dataSource = self
        
        urlTextField.autocorrectionType = .no
        shortenTableView.separatorStyle = .singleLine
        sendButton.layer.cornerRadius = 10
        sendButton.setTitle("Shorten", for: .normal)
        shareButton.isHidden = true
    }
    
    func addCancelTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Data Manipulation Methods
    func saveShortenUrl(){
        
        do{
            try context.save()
        }catch{
            print("Error saving category, \(error)")
        }
        shortenTableView.reloadData()
    }
    
    func loadShortenUrls() {
        
        let request: NSFetchRequest<ShortenUrl> = ShortenUrl.fetchRequest()
        
        do{
            shortenUrlArray = try context.fetch(request)
        }catch{
            print("Error in loading cell, \(error)")
        }
        shortenTableView.reloadData()
    }
    
    //MARK: - Button Action
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        guard let text = urlLabel.text else { fatalError() }
        let vc = UIActivityViewController(activityItems: ["https://\(text)"], applicationActivities: [])
        if let popoverController = vc.popoverPresentationController{
            popoverController.sourceView = self.view
            popoverPresentationController?.sourceRect = self.view.bounds
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func urlTFPressed(_ sender: UITextField) {
        urlLabel.text = ""
        sendButton.setTitle("Shorten", for: .normal)
        shareButton.isHidden = true
    }
}

//MARK: - UITextFieldDelegate

extension ShortenViewController: UITextFieldDelegate{
    
    @IBAction func shortenButtonPressed(_ sender: UIButton) {
        if urlTextField.endEditing(true){
            sendButton.setTitle("Copy", for: .normal)
            let pasteboard = UIPasteboard.general
            pasteboard.string = urlLabel.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        urlTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        }else{
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if shortenManager.isValidUrl(url: textField.text!) == true{
            if(!textField.text!.hasPrefix("https://")){
                textField.text =  "https://" + textField.text!
                guard let link = textField.text else { fatalError() }
                originalURL = link
                shortenManager.getUrlShortener(for: link)
            }else{
                guard let link = textField.text else { fatalError() }
                originalURL = link
                shortenManager.getUrlShortener(for: link)
            }
            
        }else{
            let alert = UIAlertController(title: "Invalid URL 🧐", message: "Please input a valid URL.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
        }
        textField.text = ""
    }
}

//MARK: - ShortenManagerDelegate

extension ShortenViewController: ShortenManagerDelegate{
    
    func didShortenURL(_ link: String) {
        DispatchQueue.main.async {
            print(link)
            let parsed = self.originalURL?.replacingOccurrences(of: "https://", with: "")
            let newShortenUrl = ShortenUrl(context: self.context)
            newShortenUrl.shortenUrlText = link
            newShortenUrl.originalUrlText = parsed
            
            self.shortenUrlArray.append(newShortenUrl)
            
            self.saveShortenUrl()
            
            self.urlLabel.text = link
            self.urlTextField.placeholder = ""
            self.sendButton.setTitle("Copy", for: .normal)
            self.shareButton.isHidden = false
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSoURCE

extension ShortenViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shortenUrlArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShortenUrlCell", for: indexPath) as! ShortenTableViewCell
        cell.backgroundColor = .clear
        cell.urlText.text = shortenUrlArray[indexPath.row].shortenUrlText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            context.delete(shortenUrlArray[indexPath.row])
            shortenUrlArray.remove(at: indexPath.row)
            saveShortenUrl()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let shortenUrl = shortenUrlArray[indexPath.row].shortenUrlText else {fatalError()}
        guard let originalUrl = shortenUrlArray[indexPath.row].originalUrlText else {fatalError()}
        
        let alert = UIAlertController(title: "\(shortenUrl)", message: "Original URL: \(originalUrl)", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { (action) in
            let pasteboard = UIPasteboard.general
            pasteboard.string = shortenUrl
        }))
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { (action) in
            let vc = UIActivityViewController(activityItems: ["https://\(shortenUrl)"], applicationActivities: [])
            if let popoverController = vc.popoverPresentationController{
                popoverController.sourceView = self.view
                self.popoverPresentationController?.sourceRect = self.view.bounds
            }
            self.present(vc, animated: true, completion: nil)
        }))

        self.present(alert, animated: true)
    }
    
}
