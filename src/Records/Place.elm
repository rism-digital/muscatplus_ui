module Records.Place exposing (..)

import DataTypes exposing (Msg, PlaceBody)
import Element exposing (Element, alignTop, column, fill, height, none, paddingXY, px, row, spacing, width)
import Language exposing (Language)
import Records.Shared exposing (viewSummaryField)
import UI.Components exposing (h2)


viewPlaceRecord : PlaceBody -> Language -> Element Msg
viewPlaceRecord body language =
    row
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , height (px 120)
                ]
                [ h2 language body.label ]
            , row
                [ width fill
                , height fill
                ]
                [ column
                    [ width fill
                    , spacing 20
                    ]
                    (List.map (\viewSection -> viewSection body language)
                        [ viewSummarySection ]
                    )
                ]
            ]
        ]


viewSummarySection : PlaceBody -> Language -> Element Msg
viewSummarySection body language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ viewSummaryField body.summary language ]
        ]
