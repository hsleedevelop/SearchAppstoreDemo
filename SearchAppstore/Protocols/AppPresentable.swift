//
//  AppPresentable.swift
//  SearchAppstore
//
//  Created by HS Lee on 09/04/2019.
//  Copyright © 2019 hsleedevelop.io All rights reserved.
//

import Foundation
import UIKit

protocol AppPresentable {
    var app: SearchResultApp? { get set }
}

extension AppPresentable {
    
    var name: String? {
        return app?.name
    }
    
    var sellerUrl: String {
        return app?.sellerUrl ?? ""
    }
    
    var sellerName: String {
        return app?.sellerName ?? ""
    }
    
    var artistName: String? {
        return app?.artistName
    }
    
    var genre: String {
        return app?.genre ?? ""
    }
    
    var rating: Double {
        return app?.rating ?? app?.currentRating ?? 0
    }
    
    var ratingCount: String {
        let count = app?.ratingCount ?? app?.currentRatingCount ?? 0
        var fcount = count >= 1000 ? String(format: "%.2fK", Double(count) * 0.001) : "\(count)"
        fcount = count >= 1000000 ? String(format: "%.2fM", Double(count) * 0.000001) : fcount
        return fcount
    }
    
    var iconUrl: String {
        return app?.artwork ?? ""
    }
    
    var screenshotsUrls: [String]? {
        return app?.screenshots
    }
    
    var contentAdvisoryRating: String {
        return app?.contentAdvisoryRating ?? "0+"
    }
    
    var version: String {
        return app?.version ?? ""
    }
    
    var releaseDate: String? {
        guard let releaseDate = app?.currentReleaseDate ?? app?.releaseDate else { return nil }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: releaseDate)
    }
    
    var releaseNotes: String {
        return app?.releaseNotes ?? ""
    }
    
    var appDescription: String {
        return app?.description ?? ""
    }
    
    var screenshotSize: CGSize {
        return screenshotsUrls?.count ?? 0 > 0 ? CGSize(width: 180, height: 300) : CGSize.zero
    }
    
    var fileSize: String {
        let size = Double(app?.fileSize ?? "0") ?? 0
        var fsize = size >= 1024 ? String(format: "%.2fK", size * 0.001) : "\(size)"
        fsize = size >= 1024 * 1024 ? String(format: "%.2fM", size * 0.000001) : fsize
        fsize = size >= 1024 * 1024 * 1024 ? String(format: "%.2fG", size * 0.000000001) : fsize
        return fsize
    }
    
    var informations: [AppInformationType] {
        return [AppInformationType(subject: "Seller", content: sellerName),
                AppInformationType(subject: "Size", content: fileSize),
                AppInformationType(subject: "Category", content: genre),
                AppInformationType(subject: "Compatibility", content: "iPhone"),
                AppInformationType(subject: "Languages", content: "KO"),
                AppInformationType(subject: "Age Rating", content: contentAdvisoryRating),
                AppInformationType(subject: "Copyright", content: "제공안됨"),
                AppInformationType(subject: "Developer Website", content: sellerUrl),
                AppInformationType(subject: "Private Policy", content: "제공안됨")]
    }
}
