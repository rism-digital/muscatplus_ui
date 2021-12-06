module Page.Search.Views.Previews.Incipit exposing (..)

import Element exposing (Element, column, el, fill, height, link, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (h1, h4)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Incipits exposing (viewIncipit)
import Page.UI.PageTemplate exposing (pageHeaderTemplate, pageUriTemplate)


viewIncipitPreview : Language -> IncipitBody -> Element msg
viewIncipitPreview language body =
    let
        sourceUrl =
            case body.partOf of
                Just partOfBody ->
                    let
                        sourceBody =
                            partOfBody.source
                    in
                    sourceBody.id

                Nothing ->
                    ""

        incipitLink =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.viewRecord ++ ": "))
                , link
                    [ linkColour ]
                    { url = sourceUrl
                    , label = text sourceUrl
                    }
                ]

        pageBodyView =
            row
                widthFillHeightFill
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    ]
                    [ viewMaybe (viewIncipit language) (Just body) ]
                ]
    in
    row
        widthFillHeightFill
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
                    , pageUriTemplate language body
                    ]
                ]
            , pageBodyView
            ]
        ]
