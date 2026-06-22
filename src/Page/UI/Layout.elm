module Page.UI.Layout exposing (clampResultsPanelWidth, previewAvailableRightWidthFromResultsWidth, previewWidthFromAvailableRightWidth, resultsDividerWidth, resultsPanelWidth)


minimumResultsPanelWidth : Int
minimumResultsPanelWidth =
    320


minimumRightPanelWidth : Int
minimumRightPanelWidth =
    360


resultsDividerWidth : Int
resultsDividerWidth =
    16


availableSplitWidth : Int -> Int -> Int
availableSplitWidth windowWidth sidebarWidth =
    max 320 (windowWidth - sidebarWidth - resultsDividerWidth)


resultsPanelWidth : Int -> Int -> Int
resultsPanelWidth windowWidth sidebarWidth =
    let
        availableWidth =
            availableSplitWidth windowWidth sidebarWidth
    in
    round (toFloat availableWidth * 0.42)
        |> clamp 380 500
        |> min availableWidth


clampResultsPanelWidth : Int -> Int -> Int -> Int
clampResultsPanelWidth windowWidth sidebarWidth requestedWidth =
    let
        availableWidth =
            availableSplitWidth windowWidth sidebarWidth

        maximumResultsWidth =
            max minimumResultsPanelWidth (availableWidth - minimumRightPanelWidth)
    in
    clamp minimumResultsPanelWidth maximumResultsWidth requestedWidth
        |> min availableWidth


previewAvailableRightWidthFromResultsWidth : Int -> Int -> Int -> Int
previewAvailableRightWidthFromResultsWidth windowWidth sidebarWidth resultsWidth =
    max 0 (availableSplitWidth windowWidth sidebarWidth - clampResultsPanelWidth windowWidth sidebarWidth resultsWidth)


previewWidthFromAvailableRightWidth : Int -> Int
previewWidthFromAvailableRightWidth availableRight =
    round (toFloat availableRight * 0.92)
        |> clamp 260 900
        |> min availableRight
