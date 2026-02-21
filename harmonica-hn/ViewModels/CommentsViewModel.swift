//
//  CommentsViewModel.swift
//  harmonica-hn
//
//  Created by Dev Keshwani on 21/02/26.
//

import SwiftUI
import Observation

@Observable
class CommentsViewModel {
    var comments: [AlgoliaService.AlgoliaComment] = []
    var story: AlgoliaService.AlgoliaItem?
    var isLoading = false
    var isFromCache = false
    var errorMessage: String?
    
    @MainActor
    func load(storyID: Int, forceRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil
        do {
            let item = try await CommentRepository.shared.fetchComments(
                storyID: storyID,
                forceRefresh: forceRefresh
            )
            story = item
            comments = item.children ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // Flatten recursive comment tree for List rendering
    var flatComments: [FlatComment] {
        var result: [FlatComment] = []
        func flatten(_ comments: [AlgoliaService.AlgoliaComment]) {
            for c in comments {
                result.append(FlatComment(comment: c, depth: c.depth))
                if let children = c.children { flatten(children) }
            }
        }
        flatten(comments)
        return result
    }
    
    struct FlatComment: Identifiable {
        let id = UUID()
        let comment: AlgoliaService.AlgoliaComment
        let depth: Int
    }
}
