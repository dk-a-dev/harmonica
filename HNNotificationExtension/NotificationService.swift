//
//  NotificationService.swift
//  HNNotificationExtension
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            return
        }
        
        // 1. Extract the Hacker News Item ID from the APNs Payload
        let userInfo = request.content.userInfo
        guard let itemIdStr = userInfo["item_id"] as? String ?? (userInfo["item_id"] as? Int).map(String.init),
              let itemId = Int(itemIdStr) else {
            
            // Fallback if there's no item ID
            bestAttemptContent.title = "New Reply on Hacker News"
            bestAttemptContent.body = "Open the app to see your new reply."
            contentHandler(bestAttemptContent)
            return
        }
        
        // 2. Fetch the comment content from Hacker News Firebase API
        let urlString = "https://hacker-news.firebaseio.com/v0/item/\(itemId).json"
        guard let url = URL(string: urlString) else {
            contentHandler(bestAttemptContent)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                // Ensure we ALWAYS call the contentHandler within the 30-second execution window
                contentHandler(bestAttemptContent)
            }
            
            guard let data = data, error == nil else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Extract author and text
                    let by = json["by"] as? String ?? "Someone"
                    let textHTML = json["text"] as? String ?? "Replied to your post."
                    
                    // Simple HTML stripping for the notification body
                    let strippedText = textHTML
                        .replacingOccurrences(of: "<p>", with: "\n\n")
                        .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                        .replacingOccurrences(of: "&quot;", with: "\"")
                        .replacingOccurrences(of: "&amp;", with: "&")
                        .replacingOccurrences(of: "&gt;", with: ">")
                        .replacingOccurrences(of: "&lt;", with: "<")
                        .replacingOccurrences(of: "&#x27;", with: "'")
                    
                    // Update the notification UI
                    bestAttemptContent.title = "Reply from \(by)"
                    bestAttemptContent.body = strippedText
                }
            } catch {
                print("Error parsing HN Item JSON: \(error)")
            }
        }
        task.resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
