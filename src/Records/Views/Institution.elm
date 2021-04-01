module Records.Views.Institution exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, paddingXY, px, row, spacing, width)
import Records.DataTypes exposing (InstitutionBody, Msg)
import Records.Views.Shared exposing (viewRelations, viewSummaryField)
import Shared.Language exposing (Language, LanguageMap)
import UI.Components exposing (h2)


viewInstitutionRecord : InstitutionBody -> Language -> Element Msg
viewInstitutionRecord body language =
    row
        [ alignTop
        , width fill
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
                        [ viewSummarySection
                        , viewRelationsSection
                        ]
                    )
                ]
            ]
        ]


viewSummarySection : InstitutionBody -> Language -> Element Msg
viewSummarySection body language =
    row
        [ width fill
        , paddingXY 0 10
        ]
        [ column
            [ width fill ]
            [ viewSummaryField body.summary language ]
        ]


viewRelationsSection : InstitutionBody -> Language -> Element Msg
viewRelationsSection body language =
    case body.relations of
        Just relationships ->
            viewRelations relationships language

        Nothing ->
            none
