//
//  ChatTableViewCell.swift
//  MChat
//
//  Created by Michał Wolanin on 21/04/2023.
//

import UIKit
import SDWebImage

class ChatTableViewCell: UITableViewCell {
    
    static let identifier = "ChatTableViewCell"
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .white
        
        imageView.layer.cornerRadius = 16
        
        return imageView
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.backgroundColor = .systemBlue
        return view
    }()
    
    let chatTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "okej chat label super"
        
        return label
    }()
    
    var textLeading: NSLayoutConstraint!
    var textTrailing: NSLayoutConstraint!
    
    var imageLeading: NSLayoutConstraint!
    var imageTrailing: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        chatTextLabel.text = nil
    }
    
    
    
    
    private func configureUI(){
        addSubview(profileImageView)
        addSubview(bubbleView)
        addSubview(chatTextLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            
            chatTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            chatTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            chatTextLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            bubbleView.topAnchor.constraint(equalTo: chatTextLabel.topAnchor, constant: -8),
            bubbleView.leadingAnchor.constraint(equalTo: chatTextLabel.leadingAnchor, constant: -8),
            bubbleView.trailingAnchor.constraint(equalTo: chatTextLabel.trailingAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: chatTextLabel.bottomAnchor, constant: 8)
            
        ])
        
        imageLeading = profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        imageTrailing = profileImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        
        textLeading = chatTextLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16)
        textTrailing = chatTextLabel.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -16)

        
    }

    func configureForMessage(message: Message, currentUid: String){
        let isUser = currentUid == message.uid ? true : false
        chatTextLabel.text = message.text
        
        if message.photoURL.count > 0{
            let url = URL(string: message.photoURL)
            profileImageView.sd_setImage(with:  url)
        }
        
        if isUser {
            bubbleView.backgroundColor = .systemBlue
            imageLeading.isActive = false
            textLeading.isActive = false
            
            imageTrailing.isActive = true
            textTrailing.isActive = true
            
        }
        else{
            bubbleView.backgroundColor = .systemGray
            imageTrailing.isActive = false
            textTrailing.isActive = false
            
            imageLeading.isActive = true
            textLeading.isActive = true
        }
    }
    
    func configureForMock(message: String, isUser: Bool){
        chatTextLabel.text = message
        
        if isUser {
            bubbleView.backgroundColor = .systemBlue
            imageLeading.isActive = false
            textLeading.isActive = false
            
            imageTrailing.isActive = true
            textTrailing.isActive = true
            
        }
        else{
            bubbleView.backgroundColor = .systemGray
            imageTrailing.isActive = false
            textTrailing.isActive = false
            
            imageLeading.isActive = true
            textLeading.isActive = true
        }
    }
}
