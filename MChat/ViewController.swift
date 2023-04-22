//
//  ViewController.swift
//  MChat
//
//  Created by Michał Wolanin on 19/04/2023.
//

import UIKit

class ViewController: UIViewController {

    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ChatTableViewCell.self, forCellReuseIdentifier: ChatTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        
        return table
        }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.backgroundColor = .systemGray6
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.returnKeyType = .send
        textView.font = .systemFont(ofSize: 16)
        
        textView.textContainerInset = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        
        return textView
    }()
    
    lazy var sendImageView: UIImageView = {
        let sendImageView = UIImageView()
        sendImageView.translatesAutoresizingMaskIntoConstraints = false
        sendImageView.image = UIImage(systemName: "paperplane")
        sendImageView.tintColor = .label
        sendImageView.backgroundColor = .systemGray6
        sendImageView.contentMode = .scaleAspectFit
        sendImageView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapSend))
        sendImageView.addGestureRecognizer(gesture)
        
        return sendImageView
    }()
    
    var mockData = [
        "siema 1",
        "siema 2",
        "siema 3",
        "siema 4",
        "siema 5",
        "siema 6",
        "siema 7",
        "siema 8",
        "siema 9",
        "siema 10",
        "siema 11",
        "siema 12",
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        subscribeToKeyboardShowHide()

    }

    private func configureUI(){
        view.addSubview(tableView)
        view.addSubview(textView)
        view.addSubview(sendImageView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: textView.topAnchor),
            
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            textView.trailingAnchor.constraint(equalTo: sendImageView.leadingAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.heightAnchor.constraint(equalToConstant: 100),
            
            sendImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            sendImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sendImageView.heightAnchor.constraint(equalToConstant: 101),
            sendImageView.widthAnchor.constraint(equalToConstant: 50),

            
        ])
    }
    
    @objc func didTapSend(){
        if let textMessage = textView.text, textMessage.count > 2 {
            mockData.append(textMessage)
            textView.text = ""
            tableView.reloadData()
        }
    }
    
    
    
    //MARK: - Keyboard Events
    
    private func subscribeToKeyboardShowHide(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notifaction: Notification){
        let info = notifaction.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.view.frame.origin.y = -keyboardFrame.size.height
    }
    
    @objc func keyboardWillHide(notifaction: Notification){
        let info = notifaction.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.view.frame.origin.y = 0
    }
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as? ChatTableViewCell else{
            return UITableViewCell()
        }
        
        let index = indexPath.row
        if index % 2 == 0{
            cell.configureForMessage(message: mockData[index], isUser: true)
        }
        else{
            cell.configureForMessage(message: mockData[index], isUser: false)
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}


extension ViewController: UITextViewDelegate{
    
    
    
    
    
}
