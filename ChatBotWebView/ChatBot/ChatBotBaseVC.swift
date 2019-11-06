//
//  ChatBotBaseVC.swift
//  ChatBotWebView
//
//  Created by Ravi Rana on 30/06/19.
//  Copyright © 2019 Ravi Rana. All rights reserved.
//

import UIKit

class ChatBotBaseVC: UIViewController, UIGestureRecognizerDelegate {
    var startButton:UIButton!
    
    fileprivate func addStartButton() {
        startButton = UIButton.init(type: .custom)
        startButton.setImage(UIImage(named: "floating"), for: .normal)
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ startButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -100), startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100), startButton.heightAnchor.constraint(equalToConstant: 88),
                                      startButton.widthAnchor.constraint(equalToConstant: 88)])
        startButton.addTarget(self, action: #selector(startChatAction), for: .touchUpInside)
    }
    
    fileprivate func addPanGesture() {
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(moveButton))
        panGesture.delegate = self
        startButton.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addStartButton()
        
        addPanGesture()
    }
    
    @objc func moveButton(sender: UIPanGestureRecognizer)
    {
        let translation = sender.translation(in: self.view)
        
        let newX = sender.view!.center.x + translation.x
        var newY = sender.view!.center.y + translation.y
        let senderWidth = sender.view!.bounds.width / 2
        let senderHight = sender.view!.bounds.height / 2
        
        if newY < 64 {
            newY = 64
        }
        
        if newX <= senderWidth
        {
            sender.view!.center = CGPoint(x: senderWidth, y: sender.view!.center.y + translation.y)
        }
        else if newX >= self.view.bounds.maxX - senderWidth
        {
            sender.view!.center = CGPoint(x: self.view.bounds.maxX - senderWidth, y: sender.view!.center.y + translation.y)
        }
        if newY <= 2*senderHight
        {
            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: 2*senderHight)
        }
        else if newY >= self.view.bounds.maxY - senderHight
        {
            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: self.view.bounds.maxY - senderHight)
        }
        else
        {
            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        }
        
        sender.setTranslation(.zero, in: self.view)
    }
    
    @objc func startChatAction() {
        let chatbotvc = ChatBotVC()
        chatbotvc.view.layoutIfNeeded()
        chatbotvc.modalPresentationStyle = .fullScreen
        present(chatbotvc, animated: true, completion: nil)
    }

}
