module Page.Views.SourcePage.PartOfSection exposing (..)

import Element exposing (Element, column, fill, link, paddingXY, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h5)


viewPartOfSection : Language -> PartOfSectionBody -> Element Msg
viewPartOfSection language partOf =
    let
        source =
            partOf.source
    in
    row
        [ width fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , spacing 10
            ]
            [ row
                [ width fill
                ]
                [ h5 language partOf.label ]
            , row
                [ width fill ]
                [ link
                    [ linkColour ]
                    { url = source.id
                    , label = text (extractLabelFromLanguageMap language source.label)
                    }
                ]
            ]
        ]
