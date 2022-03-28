module Page.Record.Views.SectionTemplate exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, row, spacing, width)
import Html.Attributes as HTA
import Language exposing (Language, LanguageMap)
import Page.UI.Attributes exposing (emptyAttribute, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (h2)


{-|

    Helper for consistently formatting sections of a
    record page. Takes in a language, an object with a
    TOC and label, and a pre-rendered section body.

-}
sectionTemplate :
    Language
    -> { a | sectionToc : String, label : LanguageMap }
    -> List (Element msg)
    -> Element msg
sectionTemplate language header sectionBody =
    let
        -- don't emit an anchor ID if the TOC value is an empty string
        tocId =
            if String.isEmpty header.sectionToc then
                emptyAttribute

            else
                htmlAttribute (HTA.id header.sectionToc)
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , tocId
                ]
                [ h2 language header.label ]
            , row
                [ width fill ]
                [ column
                    [ spacing sectionSpacing
                    , width fill
                    , height fill
                    , alignTop
                    ]
                    sectionBody
                ]
            ]
        ]
