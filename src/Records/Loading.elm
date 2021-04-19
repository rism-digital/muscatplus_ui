module Records.Loading exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, paddingXY, px, row, spacingXY, width)
import UI.Animations exposing (loadingBox)


viewRecordLoading : Element msg
viewRecordLoading =
    row
        [ alignTop
        , width fill
        ]
        [ column
            [ width fill
            , spacingXY 0 20
            ]
            [ row
                [ width fill
                , height (px 120)
                ]
                [ loadingBox 1000 60 ]
            , row
                [ width fill
                , height (px 100)
                , paddingXY 0 10
                ]
                [ loadingBox 800 100 ]
            , row
                [ width fill
                , height (px 100)
                , paddingXY 0 10
                ]
                [ loadingBox 800 100 ]
            , row
                [ width fill
                , height (px 100)
                , paddingXY 0 10
                ]
                [ loadingBox 800 100 ]
            , row
                [ width fill
                , height (px 100)
                , paddingXY 0 10
                ]
                [ loadingBox 800 100 ]
            , row
                [ width fill
                , height (px 100)
                , paddingXY 0 10
                ]
                [ loadingBox 800 100 ]
            ]
        ]
