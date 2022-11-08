module Page.UI.Record.SourceItemsSection exposing (viewSourceItemsSection)

import Element exposing (Element, alignBottom, alignLeft, alignTop, centerY, column, el, fill, height, htmlAttribute, link, pointer, px, row, shrink, spacing, text, width)
import Element.Events as Events
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Source exposing (SourceItemsSectionBody)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody)
import Page.UI.Attributes exposing (emptyAttribute, headingLG, lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (h2, viewSummaryField)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Style exposing (colourScheme)


viewSourceItem : Language -> BasicSourceBody -> Element msg
viewSourceItem language source =
    row
        (width fill :: sectionBorderStyles)
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , spacing 5
                ]
                [ el
                    [ width (px 20)
                    , height (px 20)
                    , centerY
                    ]
                    (sourcesSvg colourScheme.slateGrey)
                , link
                    [ linkColour
                    , headingLG
                    , Font.medium
                    ]
                    { label = text (extractLabelFromLanguageMap language source.label)
                    , url = source.id
                    }
                ]
            , Maybe.withDefault [] source.summary
                |> viewSummaryField language
            ]
        ]


viewSourceItemsSection : Language -> Bool -> msg -> SourceItemsSectionBody -> Element msg
viewSourceItemsSection language expanded expandMsg siSection =
    let
        -- don't emit an anchor ID if the TOC value is an empty string
        tocId =
            if String.isEmpty siSection.sectionToc then
                emptyAttribute

            else
                htmlAttribute (HA.id siSection.sectionToc)

        sectionBody =
            if expanded then
                List.map (viewSourceItem language) siSection.items

            else
                []

        -- TODO: Translate
        linkLabel =
            if expanded then
                text "Collapse"

            else
                text ("Show " ++ String.fromInt (List.length siSection.items) ++ " items")
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
            ]
            [ row
                [ width shrink
                , alignLeft
                , alignBottom
                , spacing 5
                , tocId
                ]
                [ h2 language siSection.label
                , el
                    [ linkColour
                    , pointer
                    , Events.onClick expandMsg
                    ]
                    linkLabel
                ]
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
