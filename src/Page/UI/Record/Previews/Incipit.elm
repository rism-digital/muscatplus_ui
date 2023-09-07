module Page.UI.Record.Previews.Incipit exposing (viewIncipitPreview)

import Element exposing (Element, alignTop, column, el, fill, height, link, paddingXY, row, scrollbarY, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionSpacing)
import Page.UI.Record.Incipits exposing (viewIncipit)
import Page.UI.Record.PageTemplate exposing (pageHeaderTemplateNoToc)
import Set exposing (Set)


viewIncipitPreview : Language -> Set String -> (String -> msg) -> IncipitBody -> Element msg
viewIncipitPreview language incipitInfoExpanded infoToggleMsg body =
    let
        labelLanguageMap =
            .label body.partOf

        sourceUrl =
            .source body.partOf
                |> .id

        sourceLabel =
            .source body.partOf
                |> .label

        incipitLink =
            row
                [ width fill
                ]
                [ column
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ row
                        [ width fill ]
                        [ el
                            []
                            (text (extractLabelFromLanguageMap language labelLanguageMap ++ ": "))
                        , el
                            [ Font.medium ]
                            (link
                                [ linkColour ]
                                { label = text (extractLabelFromLanguageMap language sourceLabel)
                                , url = sourceUrl
                                }
                            )
                        ]
                    ]
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY 20 10
        , scrollbarY
        ]
        [ column
            [ spacing sectionSpacing
            , width fill
            , alignTop
            ]
            [ row
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
                    [ pageHeaderTemplateNoToc language Nothing body
                    , incipitLink
                    ]
                ]
            , row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    ]
                    [ viewIncipit
                        { suppressTitle = True
                        , language = language
                        , infoIsExpanded = Set.member body.id incipitInfoExpanded
                        , infoToggleMsg = infoToggleMsg
                        }
                        body
                    ]
                ]

            --, viewMaybe (viewEncodingsBlock language) body.encodings
            ]
        ]
