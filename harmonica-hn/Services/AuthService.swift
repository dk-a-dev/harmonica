//
//  AuthService.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import Foundation
import Observation

@Observable
class AuthService {
    static let shared = AuthService()
    
    var isLoggedIn: Bool = false
    var username: String? = nil
    
    private let hnBaseURL = "https://news.ycombinator.com"
    private var session: URLSession
    
    // Auth token cache: ITEM_ID -> AUTH_TOKEN
    private var tokenCache: [Int: String] = [:]
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.httpCookieAcceptPolicy = .always
        self.session = URLSession(configuration: configuration)
        
        loadSession()
    }
    
    // MARK: - Login
    
    func login(username: String, password: String) async throws -> Bool {
        guard let url = URL(string: "\(hnBaseURL)/login") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyString = "goto=news&acct=\(username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? username)&pw=\(password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? password)"
        request.httpBody = bodyString.data(using: .utf8)
        
        // Reset cookies before login
        HTTPCookieStorage.shared.cookies(for: URL(string: hnBaseURL)!)?.forEach {
            HTTPCookieStorage.shared.deleteCookie($0)
        }
        
        let (_, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            // Check if "user" cookie was set
            if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
                if cookies.contains(where: { $0.name == "user" }) {
                    saveSession(username: username)
                    return true
                }
            }
        }
        
        return false
    }
    
    func logout() {
        if let url = URL(string: hnBaseURL) {
            HTTPCookieStorage.shared.cookies(for: url)?.forEach {
                HTTPCookieStorage.shared.deleteCookie($0)
            }
        }
        UserDefaults.standard.removeObject(forKey: "hn_username")
        UserDefaults.standard.removeObject(forKey: "user_cookie_value")
        self.username = nil
        self.isLoggedIn = false
        self.tokenCache.removeAll()
    }
    
    // MARK: - Voting
    
    func vote(itemId: Int, how: String = "up") async throws -> Bool {
        guard isLoggedIn else { return false }
        
        // 1. Get the auth token (from cache or parse HTML lazily)
        let token = try await getAuthToken(for: itemId)
        
        // 2. Fire the VOTE GET request
        guard let url = URL(string: "\(hnBaseURL)/vote?id=\(itemId)&how=\(how)&auth=\(token)&goto=news") else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (_, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            return true
        }
        return false
    }
    
    /// Lazily fetches the HTML of the item, parses the 'auth' token, and caches it
    private func getAuthToken(for itemId: Int) async throws -> String {
        if let cachedToken = tokenCache[itemId] {
            return cachedToken
        }
        
        guard let url = URL(string: "\(hnBaseURL)/item?id=\(itemId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await session.data(for: request)
        guard let html = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }
        
        // Search for <a id='up_47091419' href='vote?id=47091419&amp;how=up&amp;auth=XXXX&amp;goto=item%3Fid%3D47091419'>
        // or just `auth=XXXX` associated with this item ID
        let pattern = "vote\\?id=\(itemId)&amp;how=up&amp;auth=([^&]+)"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count)) {
            
            if let range = Range(match.range(at: 1), in: html) {
                let token = String(html[range])
                tokenCache[itemId] = token
                return token
            }
        }
        
        throw NSError(domain: "AuthService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Voting auth token not found on item page. You may have already voted or you are not logged in."])
    }
    
    // MARK: - Session Persistence
    
    private func saveSession(username: String) {
        self.username = username
        self.isLoggedIn = true
        UserDefaults.standard.set(username, forKey: "hn_username")
        
        // Save user cookie explicitly since HTTPCookieStorage is ephemeral across launches (sometimes)
        if let url = URL(string: hnBaseURL),
           let cookies = HTTPCookieStorage.shared.cookies(for: url),
           let userCookie = cookies.first(where: { $0.name == "user" }) {
            UserDefaults.standard.set(userCookie.value, forKey: "user_cookie_value")
        }
    }
    
    private func loadSession() {
        if let savedUser = UserDefaults.standard.string(forKey: "hn_username"),
           let savedCookieValue = UserDefaults.standard.string(forKey: "user_cookie_value") {
            self.username = savedUser
            self.isLoggedIn = true
            
            // Re-create the cookie
            var properties: [HTTPCookiePropertyKey: Any] = [:]
            properties[.name] = "user"
            properties[.value] = savedCookieValue
            properties[.domain] = "news.ycombinator.com"
            properties[.path] = "/"
            properties[.secure] = "TRUE"
            properties[.expires] = Date().addingTimeInterval(60*60*24*365) // 1 year
            
            if let cookie = HTTPCookie(properties: properties) {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
}
