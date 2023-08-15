module Page.UI.Record.Previews.Incipit exposing (viewIncipitPreview)

import Element exposing (Element, alignTop, column, el, fill, height, link, none, paddingXY, row, scrollbarY, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Incipit exposing (EncodedIncipit(..), IncipitBody, PAEEncodedData)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionSpacing)
import Page.UI.Components exposing (h1)
import Page.UI.Record.Incipits exposing (viewIncipit, viewPAEData)
import Set exposing (Set)



--viewEncodingsBlock : Language -> List EncodedIncipit -> Element msg
--viewEncodingsBlock language encodedIncipits =
--    row
--        [ width fill
--        , alignTop
--        ]
--        [ column
--            [ width fill
--            , alignTop
--            ]
--            (List.map
--                (\encoding ->
--                    case encoding of
--                        PAEEncoding label paeData ->
--                            viewPaeData language label paeData
--
--                        _ ->
--                            none
--                )
--                encodedIncipits
--            )
--        ]
--


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
                    [ row
                        [ width fill
                        ]
                        [ h1 language body.label ]
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
