module Page.UI.Record.Previews.Incipit exposing (viewIncipitPreview)

import Element exposing (Attribute, Element, alignLeft, alignTop, centerY, column, el, fill, height, htmlAttribute, paddingXY, paragraph, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.UI.Attributes exposing (headingLG, lineSpacing, linkColour, sectionSpacing)
import Page.UI.Components exposing (externalLinkTemplate, resourceLink)
import Page.UI.Images exposing (musicNotationSvg)
import Page.UI.Record.Incipits exposing (viewIncipit)
import Page.UI.Record.PageTemplate exposing (subHeaderTemplate)
import Page.UI.Style exposing (colourScheme)
import Set exposing (Set)


viewIncipitPreview :
    { incipitInfoExpanded : Set String
    , infoToggleMsg : String -> msg
    , language : Language
    }
    -> IncipitBody
    -> Element msg
viewIncipitPreview cfg body =
    let
        recordIcon =
            el
                [ width (px 25)
                , height (px 25)
                , centerY
                ]
                (musicNotationSvg colourScheme.darkBlue)

        labelLanguageMap =
            .label body.partOf

        sourceUrl =
            .source body.partOf
                |> .id

        sourceLabel =
            .source body.partOf
                |> .label

        incipitLink =
            incipitLinkTemplate cfg.language labelLanguageMap headingLG { id = sourceUrl, label = sourceLabel }
    in
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY 20 10
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
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
                    , centerY
                    ]
                    [ subHeaderTemplate cfg.language (Just recordIcon) body
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
                        , language = cfg.language
                        , infoIsExpanded = Set.member body.id cfg.incipitInfoExpanded
                        , infoToggleMsg = cfg.infoToggleMsg
                        }
                        body
                    ]
                ]
            ]
        ]


incipitLinkTemplate : Language -> LanguageMap -> Attribute msg -> { a | id : String, label : LanguageMap } -> Element msg
incipitLinkTemplate language langMap fontSize body =
    row
        [ width fill
        , alignLeft
        , spacing 5
        ]
        [ column
            [ width shrink ]
            [ row
                [ width fill ]
                [ el
                    [ fontSize
                    , Font.semiBold
                    ]
                    (text (extractLabelFromLanguageMap language langMap ++ ": "))
                , resourceLink body.id
                    [ linkColour ]
                    { label =
                        paragraph
                            [ fontSize ]
                            [ text (extractLabelFromLanguageMap language body.label) ]
                    , url = body.id
                    }
                ]
            ]
        , externalLinkTemplate body.id
        ]
