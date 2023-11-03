module Page.UI.Record.SourceItemsSection exposing (viewSourceItemsSection)

import Element exposing (Element, alignBottom, alignLeft, alignTop, centerY, column, el, fill, height, htmlAttribute, link, paragraph, pointer, px, row, shrink, spacing, text, width)
import Element.Events as Events
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMapReplacementVariable(..), extractLabelFromLanguageMap, extractLabelFromLanguageMapWithVariables)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Source exposing (SourceItemsSectionBody)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody)
import Page.UI.Attributes exposing (emptyAttribute, headingLG, lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (h2, sourceIconChooser, viewSummaryField)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Style exposing (colourScheme)


viewSourceItem : Language -> BasicSourceBody -> Element msg
viewSourceItem language source =
    let
        sourceIcon =
            sourceIconChooser (.type_ (.recordType source.sourceTypes))
    in
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
                    [ width (px 25)
                    , height (px 25)
                    , centerY
                    ]
                    (sourceIcon colourScheme.midGrey)
                , paragraph
                    [ width fill ]
                    [ link
                        [ linkColour
                        ]
                        { label = h2 language source.label
                        , url = source.id
                        }
                    ]
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

        linkLabel =
            if expanded then
                text (extractLabelFromLanguageMap language localTranslations.collapse)

            else
                extractLabelFromLanguageMapWithVariables language
                    [ LanguageMapReplacementVariable "numItems" (String.fromInt siSection.totalItems) ]
                    localTranslations.showNumItems
                    |> text
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
