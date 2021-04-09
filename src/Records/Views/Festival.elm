module Records.Views.Festival exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, paddingXY, px, row, spacing, width)
import Records.DataTypes exposing (FestivalBody, Msg)
import Records.Views.Shared exposing (viewSummaryField)
import Shared.Language exposing (Language)
import UI.Components exposing (h2)


viewFestivalRecord : FestivalBody -> Language -> Element Msg
viewFestivalRecord body language =
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


viewSummarySection : FestivalBody -> Language -> Element Msg
viewSummarySection body language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ viewSummaryField body.summary language ]
        ]
