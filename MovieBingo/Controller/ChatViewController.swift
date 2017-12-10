//
//  ChatViewController.swift
//  MovieBingo
//
//  Created by Watson Li on 11/15/17.
//  Copyright © 2017 Huaxin Li. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController{
    
    var messages = [JSQMessage]()
    var userInfo = UserService.shared.recentChatUser ?? [:]
    var receiverInfo = UserService.shared.recentChatReceiver ?? [:]
    var selectedUser : User?
    var senderChatPath : DatabaseReference?
    var receiverChatPath : DatabaseReference?
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()

    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()

    func configure(selectedUser: User) {
        self.selectedUser = selectedUser
        UserService.shared.getRecentChatUser(receiverId: selectedUser.userId)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if let currentUser = UserService.shared.currentUser{
            senderId = currentUser.userId
            senderDisplayName = currentUser.name
        }
        // Set the navigation bar title
        if let selectedUser = selectedUser{
            title = "Chat: \(selectedUser.name)"
        }

        //save the recently chat user info
        let recentChatRef = UserService.shared.POST_DB_REF.child("\(String(describing: UserService.shared.currentUser!.userId))").child("recentChatUsers")
        let recentChatReceiverRef = UserService.shared.POST_DB_REF.child("\(String(describing: selectedUser!.userId))").child("recentChatUsers")
        
        self.userInfo[selectedUser!.userId] = selectedUser!.name
        self.receiverInfo[UserService.shared.currentUser!.userId] = UserService.shared.currentUser!.name
        
        recentChatRef.setValue(userInfo)
        recentChatReceiverRef.setValue(receiverInfo)
        UserService.shared.getRecentChatUser()
        
        // Remove the message bubble avatars, and the attachment button
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        // Prepare the Firebase query: all latest chat data limited to 20 items
        senderChatPath = UserService.shared.POST_DB_REF.child("\(String(describing: UserService.shared.currentUser!.userId))").child("receivers").child("\(String(describing: selectedUser!.userId))").child("chats")
        
        receiverChatPath = UserService.shared.POST_DB_REF.child("\(String(describing: selectedUser!.userId))").child("receivers").child("\(String(describing: UserService.shared.currentUser!.userId))").child("chats")
        
        let query = senderChatPath!.queryLimited(toLast: 20)

        // Observe the query for changes, and if a child is added, call the snapshot closure
        _ = query.observe(.childAdded, with: { [weak self] snapshot in

            // Get all the data from the snapshot
            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let name        = data["name"],
                let text        = data["text"],
                !text.isEmpty   // <-- check if the text length > 0
            {
                // Create a new JSQMessage object with the ID, display name and text
                if let message = JSQMessage(senderId: id, displayName: name, text: text)
                {
                    // Append to the local messages array
                    self?.messages.append(message)

                    // Tell JSQMVC that we're done adding this message and that it should reload the view
                    self?.finishReceivingMessage()
                }
            }
        })
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        // Return a specific message by index path
        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        // Return the number of messages
        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        // Return the right image bubble (see top): outgoing/blue for messages from the current user, and incoming/gray for other's messages
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        // No avatar!
        return nil
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        // Return an attributed string with the name of the user who's text bubble is shown, displayed on top of the bubble, or return `nil` for the current user
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        // Return the height of the bubble top label
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        // Get a reference for a new object on the `databaseChats` reference
        let sendRef = senderChatPath!.childByAutoId()
        let receiveRef = receiverChatPath!.child(sendRef.key)
        
        // Create the message data, as a dictionary
        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text]

        // Save the data on the new reference
        sendRef.setValue(message)
        receiveRef.setValue(message)
        
        // Tell JSQMVC we're done here
        // Note: the UI and bubbles don't update until the newly sent message is returned via the .observe(.childAdded,with:) closure. Neat!
        finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var nearbyController : NearbyProfileViewController?

        switch segue.identifier! {
        case "NearbyProfileSegue":
            nearbyController = segue.destination as? NearbyProfileViewController
            nearbyController?.configure(selectedUser: selectedUser!)
            nearbyController?.completionBlock = {self.dismiss(animated: true, completion: nil)}
        default:
            assert(false, "Unhandled Segue")
        }
    }
    
}


