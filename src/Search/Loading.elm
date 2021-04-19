module Search.Loading exposing (viewSearchResultsLoading)

import Element exposing (Element, alignTop, column, fill, fillPortion, height, none, paddingEach, paddingXY, px, row, spacingXY, width)
import UI.Animations exposing (loadingBox)


viewSearchResultsLoading : List (Element msg)
viewSearchResultsLoading =
    [ viewModeFacetLoading
    , row
        [ width fill
        , alignTop
        ]
        [ column
            [ width (fillPortion 3)
            , alignTop
            , spacingXY 0 40
            ]
            [ viewSidebarFacetLoading
            , viewSidebarFacetLoading
            , viewSidebarFacetLoading
            , viewSidebarFacetLoading
            ]
        , column
            [ width (fillPortion 9)
            , alignTop
            , spacingXY 0 40
            ]
            [ viewResultLoading
            , viewResultLoading
            , viewResultLoading
            , viewResultLoading
            ]
        ]
    ]


viewModeFacetLoading : Element msg
viewModeFacetLoading =
    row
        [ width fill
        , paddingEach { top = 0, left = 0, bottom = 20, right = 0 }
        ]
        [ loadingBox 800 40 ]


viewSidebarFacetLoading : Element msg
viewSidebarFacetLoading =
    row
        [ width fill
        , paddingEach { top = 0, left = 0, right = 0, bottom = 30 }
        ]
        [ column
            [ width fill
            , spacingXY 0 5
            ]
            [ row
                [ paddingEach { top = 0, left = 0, right = 0, bottom = 10 } ]
                [ loadingBox 120 20 ]
            , row
                [ width fill ]
                [ loadingBox 200 100 ]
            ]
        ]


viewResultLoading : Element msg
viewResultLoading =
    row
        [ width fill
        , paddingEach { top = 0, left = 0, right = 0, bottom = 30 }
        ]
        [ column
            [ width fill
            , alignTop
            , spacingXY 0 5
            ]
            [ row
                [ paddingEach { top = 0, left = 0, right = 0, bottom = 10 } ]
                [ loadingBox 300 20 ]
            , row
                [ width fill ]
                [ loadingBox 800 100 ]
            ]
        ]
