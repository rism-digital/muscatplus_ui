module Page.Search.Views.Previews.Incipit exposing (..)

import Element exposing (Element, alignTop, column, el, fill, height, link, paddingXY, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (h1)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Incipits exposing (viewIncipit)


viewIncipitPreview : Language -> IncipitBody -> Element msg
viewIncipitPreview language body =
    let
        sourceUrl =
            .source body.partOf
                |> .id

        labelLanguageMap =
            .label body.partOf

        incipitLink =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language labelLanguageMap ++ ": "))
                , link
                    [ linkColour ]
                    { url = sourceUrl
                    , label = text sourceUrl
                    }
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY 20 10
        ]
        [ column
            (List.append [ spacing sectionSpacing ] widthFillHeightFill)
            [ row
                widthFillHeightFill
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ row
                        [ width fill
                        ]
                        [ h1 language body.label ]
                    , incipitLink
                    ]
                ]
            , row
                widthFillHeightFill
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    ]
                    [ viewMaybe (viewIncipit language) (Just body) ]
                ]
            ]
        ]
