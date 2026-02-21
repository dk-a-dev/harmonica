//
//  BackgroundPushService.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import Foundation
import UserNotifications
import BackgroundTasks

class BackgroundPushService {
    static let shared = BackgroundPushService()
    
    // Identifier must match Info.plist
    let backgroundTaskIdentifier = "com.dkadev.harmonica-hn.refresh"
    
    private init() {}
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { [weak self] task in
            guard let task = task as? BGAppRefreshTask else { return }
            self?.handleAppRefresh(task: task)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        // Fetch no earlier than 15 minutes from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Reschedule the next one right away
        scheduleAppRefresh()
        
        task.expirationHandler = {
            // Task ran out of time
        }
        
        Task {
            await pollHackerNewsForReplies()
            task.setTaskCompleted(success: true)
        }
    }
    
    func pollHackerNewsForReplies() async {
        guard let username = AuthService.shared.username else { return }
        
        let urlString = "https://hacker-news.firebaseio.com/v0/user/\(username).json"
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let submitted = json["submitted"] as? [Int] else {
            return
        }
        
        // Track the top 15 most recent submissions
        let recentItems = Array(submitted.prefix(15))
        
        for itemId in recentItems {
            let itemUrlString = "https://hacker-news.firebaseio.com/v0/item/\(itemId).json"
            guard let itemUrl = URL(string: itemUrlString),
                  let (itemData, _) = try? await URLSession.shared.data(from: itemUrl),
                  let itemJson = try? JSONSerialization.jsonObject(with: itemData) as? [String: Any] else {
                continue
            }
            
            let currentKids = itemJson["kids"] as? [Int] ?? []
            
            // Check cache
            let cacheKey = "cached_kids_\(itemId)"
            let cachedKids = UserDefaults.standard.array(forKey: cacheKey) as? [Int] ?? []
            
            // Simple diff
            let newKids = currentKids.filter { !cachedKids.contains($0) }
            
            if !newKids.isEmpty {
                // We found new replies! Let's schedule a Local Notification for the FIRST new reply to avoid spam
                if let firstNewKid = newKids.first {
                    await scheduleLocalNotification(for: firstNewKid)
                }
                
                // Update Cache
                UserDefaults.standard.set(currentKids, forKey: cacheKey)
            } else if cachedKids.isEmpty && !currentKids.isEmpty {
                // If never cached before, just cache it
                UserDefaults.standard.set(currentKids, forKey: cacheKey)
            }
        }
    }
    
    private func scheduleLocalNotification(for itemId: Int) async {
        let urlString = "https://hacker-news.firebaseio.com/v0/item/\(itemId).json"
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        let by = json["by"] as? String ?? "Someone"
        let textHTML = json["text"] as? String ?? "Replied to your post."
        
        let strippedText = textHTML
            .replacingOccurrences(of: "<p>", with: "\n\n")
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&#x27;", with: "'")
        
        let content = UNMutableNotificationContent()
        content.title = "Reply from \(by)"
        content.body = strippedText
        content.sound = .default
        content.userInfo = ["item_id": itemId]
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule local notification: \(error)")
        }
    }
}
