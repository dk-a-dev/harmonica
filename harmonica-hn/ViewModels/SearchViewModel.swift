//
//  SearchViewModel.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//


import SwiftUI
import Observation
import Combine

@Observable
class SearchViewModel {
    var query = ""
    var results: [Story] = []
    var isSearching = false
    var errorMessage: String?
    
    private var searchTask: Task<Void, Never>?
    
    func search() {
        searchTask?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }
        
        searchTask = Task {
            // Debounce: wait 300ms
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            
            await MainActor.run { isSearching = true }
            
            do {
                let hits = try await AlgoliaService.shared.search(query: query)
                await MainActor.run {
                    results = hits
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSearching = false
                }
            }
        }
    }
    
    func clear() {
        query = ""
        results = []
        searchTask?.cancel()
    }
}