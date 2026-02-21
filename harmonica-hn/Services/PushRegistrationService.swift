//
//  PushRegistrationService.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import Foundation
import UIKit
import UserNotifications

class PushRegistrationService {
    static let shared = PushRegistrationService()
    
    // Replace this with your actual Cloudflare Worker URL when deployed
    private let backendURL = "http://localhost:8787/register_device"
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Push notifications authorized.")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Push permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func registerDevice(token: String) async {
        guard let username = AuthService.shared.username else {
            print("Not logged in, skipping push registration.")
            return
        }
        
        guard let url = URL(string: backendURL) else { return }
        
        let payload: [String: Any] = [
            "hn_username": username,
            "device_token": token,
            "watch_all_replies": true,
            "watched_item_ids": []
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Successfully registered device token with backend.")
            } else {
                print("Failed to register device token. Server responded with error.")
            }
        } catch {
            print("Network error registering device token: \(error)")
        }
    }
}
