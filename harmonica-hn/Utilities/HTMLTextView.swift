//
//  HTMLTextView.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//
import SwiftUI

struct HTMLTextView: View {
    let html: String
    @AppStorage("commentTextSize") var commentTextSize: Double = 14.0
    
    var body: some View {
        Text(parseHTML(html))
            .font(.system(size: commentTextSize))
            .textSelection(.enabled)
    }
    
    private func parseHTML(_ html: String) -> String {
        var result = html
        
        // Replace common HTML entities and tags first
        result = result.replacingOccurrences(of: "<p>", with: "\n\n")
        result = result.replacingOccurrences(of: "</p>", with: "")
        result = result.replacingOccurrences(of: "<br>", with: "\n")
        result = result.replacingOccurrences(of: "<br/>", with: "\n")
        result = result.replacingOccurrences(of: "<br />", with: "\n")
        result = result.replacingOccurrences(of: "<i>", with: "")
        result = result.replacingOccurrences(of: "</i>", with: "")
        result = result.replacingOccurrences(of: "<b>", with: "")
        result = result.replacingOccurrences(of: "</b>", with: "")
        result = result.replacingOccurrences(of: "<pre>", with: "\n")
        result = result.replacingOccurrences(of: "</pre>", with: "\n")
        result = result.replacingOccurrences(of: "<code>", with: "")
        result = result.replacingOccurrences(of: "</code>", with: "")
        
        // Strip ALL remaining HTML tags using regex-safe approach
        // Build new string character by character
        var stripped = ""
        var insideTag = false
        for char in result {
            if char == "<" {
                insideTag = true
            } else if char == ">" {
                insideTag = false
            } else if !insideTag {
                stripped.append(char)
            }
        }
        
        // Fix HTML entities
        stripped = stripped.replacingOccurrences(of: "&gt;", with: ">")
        stripped = stripped.replacingOccurrences(of: "&lt;", with: "<")
        stripped = stripped.replacingOccurrences(of: "&amp;", with: "&")
        stripped = stripped.replacingOccurrences(of: "&quot;", with: "\"")
        stripped = stripped.replacingOccurrences(of: "&#x27;", with: "'")
        stripped = stripped.replacingOccurrences(of: "&apos;", with: "'")
        stripped = stripped.replacingOccurrences(of: "&#x2F;", with: "/")
        
        return stripped.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
