//
//  MChatViewController.swift
//  MChat
//
//  Created by Michał Wolanin on 19/04/2023.
//

import UIKit
import FirebaseAuth
import Combine

class MChatViewController: UIViewController {

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
    
    var messages = [Message]()
    var mockData = [
        "message 1",
        "message 2",
        "message 3",
        "message 4",
        "message 5",
        "message 6",
        "message 7",
        "message 8",
        "message 9",
        "message 10",
        "message 11",
        "message 12",
    ]
    
    var tokens: Set<AnyCancellable> = []
    
    var currentUser: User!
    init(currentUser: User){
        self.currentUser = currentUser
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavBar()
        configureUI()
        subscribeToKeyboardShowHide()
        fetchMessages()
        subscribeToMessagePublisher()
    }

    private func setupNavBar(){
        navigationController?.navigationBar.topItem?.title = "MChat"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(didTapSignOut))
        navigationController?.navigationBar.tintColor = .systemRed
        
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
    
    @objc private func didTapSend(){
        //textView.resignFirstResponder()
        if let textMessage = textView.text, textMessage.count > 2 {
            let msg = Message(text: textMessage, uid: currentUser.uid, photoURL: currentUser.photoURL?.absoluteString ?? "", createdAt: Date())
            DatabaseManager.shared.sendMessageToDatabase(message: msg) 
            messages.append(msg)
            textView.text = ""
            tableView.reloadData()
            let index = IndexPath(row: messages.count-1, section: 0)
            tableView.scrollToRow(at: index, at: .bottom, animated: true)
        }
    }
    
    @objc private func didTapSignOut(){
        do{
            try AuthManager.shared.signOut()
            let chatVC = UINavigationController(rootViewController: SignInViewController())
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc: chatVC)
        } catch{
            print("error didTapSignOut")
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
        let _: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.view.frame.origin.y = 0
    }
    
    //MARK: - Fetch Messages
    private func fetchMessages(){
        Task {
            let msgs = try await DatabaseManager.shared.fetchAllMessages()
            self.messages = msgs
            await MainActor.run(body: {
                self.tableView.reloadData()
            })
            print(messages)
        }
        
    }
    
    private func subscribeToMessagePublisher(){
        DatabaseManager.shared.updatedMessagesPublisher.receive(on: DispatchQueue.main).sink { _ in
        
        } receiveValue: { messages in
            self.messages = messages
            self.tableView.reloadData()
        }.store(in: &tokens)

    }
    
}


extension MChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as? ChatTableViewCell else{
            return UITableViewCell()
        }
        
        let index = indexPath.row
//        if index % 2 == 0{
//            cell.configureForMessage(message: messages[index], isUser: true)
//        }
//        else{
//            cell.configureForMessage(message: messages[index], isUser: false)
//        }
        
        cell.configureForMessage(message: messages[index], currentUid: currentUser.uid)
        cell.selectionStyle = .none
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}


extension MChatViewController: UITextViewDelegate{
    
//    zamiast implemenotwac te funkjce wystarczy w textView zmienic textView.returnKeyType = .send na textView.returnKeyType = .default

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            didTapSend()
            return false
        }
        return true
    }
}
