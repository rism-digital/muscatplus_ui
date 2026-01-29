module Page.UI.Layout exposing (previewAvailableRightWidth, previewWidth, resultsPanelWidth)


resultsPanelWidth : Int -> Int -> Int
resultsPanelWidth windowWidth sidebarWidth =
    let
        availableWidth =
            max 320 (windowWidth - sidebarWidth)
    in
    round (toFloat availableWidth * 0.42)
        |> clamp 380 500
        |> min availableWidth


previewAvailableRightWidth : Int -> Int -> Int
previewAvailableRightWidth windowWidth sidebarWidth =
    let
        resultsWidth =
            resultsPanelWidth windowWidth sidebarWidth
    in
    max 0 (windowWidth - sidebarWidth - resultsWidth)


previewWidth : Int -> Int -> Int
previewWidth windowWidth sidebarWidth =
    let
        availableRight =
            previewAvailableRightWidth windowWidth sidebarWidth
    in
    round (toFloat availableRight * 0.92)
        |> clamp 260 900
        |> min availableRight
