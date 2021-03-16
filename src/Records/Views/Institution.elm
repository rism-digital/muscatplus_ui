module Records.Views.Institution exposing (..)

import Api.Records exposing (InstitutionBody)
import Element exposing (Element, alignTop, column, fill, height, px, row, width)
import Language exposing (Language)
import Records.DataTypes exposing (Msg)
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
            ]
        ]
