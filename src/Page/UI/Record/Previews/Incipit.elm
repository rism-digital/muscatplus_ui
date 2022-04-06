module Page.UI.Record.Previews.Incipit exposing (..)

import Element exposing (Element, alignTop, column, el, fill, height, link, none, paddingXY, paragraph, px, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Incipit exposing (EncodedIncipit(..), EncodingData, EncodingFormat(..), IncipitBody)
import Page.UI.Attributes exposing (bodySM, lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (h1)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Incipits exposing (viewIncipit)


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
            [ spacing sectionSpacing
            , width fill
            , height fill
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
                    [ viewMaybe (viewIncipit language) (Just body) ]
                ]
            , viewMaybe (viewEncodingsBlock language) body.encodings
            ]
        ]


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
                        EncodedIncipit PAEEncoding paeData ->
                            viewPaeData language paeData

                        _ ->
                            none
                )
                encodedIncipits
            )
        ]


viewPaeData : Language -> EncodingData -> Element msg
viewPaeData language pae =
    let
        clefRow =
            viewMaybe (viewPaeRow "@clef") pae.clef

        keysigRow =
            viewMaybe (viewPaeRow "@keysig") pae.keysig

        timesigRow =
            viewMaybe (viewPaeRow "@timesig") pae.timesig

        keyModeRow =
            viewMaybe (viewPaeRow "@key") pae.key

        dataRow =
            viewPaeRow "@data" pae.data
    in
    row
        ([ width (px 600)
         , height fill
         , alignTop
         ]
            ++ sectionBorderStyles
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


viewPaeRow : String -> String -> Element msg
viewPaeRow key value =
    paragraph
        [ width fill ]
        [ el
            [ Font.semiBold
            ]
            (text <| key ++ ":")
        , text value
        ]
