module Page.Views.SourcePage.PartOfSection exposing (..)

import Element exposing (Element, column, fill, link, none, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (FullSourceBody, PartOfSectionBody)
import Page.UI.Components exposing (h5)
import Page.UI.Style exposing (colourScheme)


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
                    [ Font.color colourScheme.lightBlue ]
                    { url = source.id
                    , label = text (extractLabelFromLanguageMap language source.label)
                    }
                ]
            ]
        ]
