//
//  AppInfoManager+AppStoreResponse+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension AppInfoManager.AppStoreResponse: ParraFixture {
    public static func validStates() -> [AppInfoManager.AppStoreResponse] {
        return [
            AppInfoManager.AppStoreResponse(
                results: [
                    AppInfoManager.AppStoreResponse.Result(
                        description: "Do you frequently look for recipes only to find yourself wading through pages of back stories and personal anecdotes before getting to meat and potatoes? Only Recipes is here to help!\n\n\nAll you have to do is look up a recipe and copy the link. Then just paste it into Only Recipes and we'll scan the website to look for the important parts, like the instructions and ingredients.\n\nEvery recipe you add will be stored in a list so they're easy to access again later.\n\n\nWorks with many popular recipe websites like...\n\n• food.com\n• foodnetwork.com\n• 101cookbooks.com\n• allrecipes.com\n• seriouseats.com\n• yummly.com\n• eatingwell.com\n• epicurious.com\n\n...and many, many more!\n\n\n*Only Recipes is not affiliated with any of the recipe websites listed above, or supported in the app.\n*We current only support scanning websites on English language websites.",
                        bundleId: "com.humblebots.onlyrecipes",
                        trackName: "Only Recipes",
                        currentVersionReleaseDate: Date.fromIso8601String(
                            "2022-06-12T22:33:24.000Z"
                        )!,
                        releaseNotes: "* Added support for editing your recipes\n* Added a warning when scanning a recipe that's already saved\n* Show prep and cook times when applicable\n* Show descriptions of recipes on the recipe screen\n* Improved the reliability of our recipe scanner\n* Support for scanning new recipe websites",
                        version: "1.4.1"
                    )
                ],
                resultCount: 1
            )
        ]
    }

    public static func invalidStates() -> [AppInfoManager.AppStoreResponse] {
        return []
    }
}
