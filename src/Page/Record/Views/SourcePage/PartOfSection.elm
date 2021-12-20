module Page.Record.Views.SourcePage.PartOfSection exposing (..)

import Element exposing (Element, column, el, fill, height, link, maximum, paddingXY, row, spacing, text, width)
import Element.Border as Border
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.UI.Attributes exposing (headingSM, lineSpacing, linkColour)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewPartOfSection : Language -> PartOfSectionBody -> Element msg
viewPartOfSection language partOf =
    let
        source =
            partOf.source

        --sectionHeader =
        --    { sectionToc = ""
        --    , label =
        --    }
        sectionBody =
            []
    in
    row
        [ width (fill |> maximum 600)
        , Border.widthEach { top = 6, left = 1, right = 1, bottom = 1 }
        , Border.color (colourScheme.lightBlue |> convertColorToElementColor)
        , paddingXY 10 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill ]
                [ el [ headingSM ] (text "This record is part of a collection: ") -- TODO: Translate!
                , link
                    [ linkColour
                    , headingSM
                    ]
                    { url = source.id
                    , label = text (extractLabelFromLanguageMap language source.label)
                    }
                ]
            ]
        ]



-- sectionTemplate language sectionHeader sectionBody
