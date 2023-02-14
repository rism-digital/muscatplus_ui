module Page.UI.Record.Previews.Incipit exposing (viewIncipitPreview)

import Element exposing (Element, alignTop, column, el, fill, height, link, none, paddingXY, paragraph, px, row, scrollbarY, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Incipit exposing (EncodedIncipit(..), IncipitBody, PAEEncodedData)
import Page.UI.Attributes exposing (bodySM, lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (h1, h3)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Incipits exposing (viewIncipit)


viewEncodingsBlock : Language -> List EncodedIncipit -> Element msg
viewEncodingsBlock language encodedIncipits =
    row
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            (List.map
                (\encoding ->
                    case encoding of
                        PAEEncoding label paeData ->
                            viewPaeData language label paeData

                        _ ->
                            none
                )
                encodedIncipits
            )
        ]


viewIncipitPreview : Language -> IncipitBody -> Element msg
viewIncipitPreview language body =
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
                    [ viewMaybe (viewIncipit True language) (Just body) ]
                ]
            , viewMaybe (viewEncodingsBlock language) body.encodings
            ]
        ]


viewPaeData : Language -> LanguageMap -> PAEEncodedData -> Element msg
viewPaeData language label pae =
    let
        clefRow =
            viewMaybe (viewPaeRow "@clef") pae.clef

        dataRow =
            viewPaeRow "@data" pae.data

        keyModeRow =
            viewMaybe (viewPaeRow "@key") pae.key

        keysigRow =
            viewMaybe (viewPaeRow "@keysig") pae.keysig

        timesigRow =
            viewMaybe (viewPaeRow "@timesig") pae.timesig
    in
    row
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , alignTop
                ]
                [ h3 language label ]
            , row
                (width (px 600)
                    :: height fill
                    :: alignTop
                    :: sectionBorderStyles
                )
                [ column
                    [ width fill
                    , alignTop
                    , Font.family [ Font.monospace ]
                    , bodySM
                    , spacing 5
                    ]
                    [ clefRow
                    , keysigRow
                    , timesigRow
                    , keyModeRow
                    , dataRow
                    ]
                ]
            ]
        ]


viewPaeRow : String -> String -> Element msg
viewPaeRow key value =
    paragraph
        [ width fill ]
        [ el
            [ Font.semiBold
            ]
            (text (key ++ ":"))
        , text value
        ]
