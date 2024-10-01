module Page.UI.Record.Previews.Incipit exposing (viewIncipitPreview)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, htmlAttribute, paddingXY, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.UI.Attributes exposing (headingLG, lineSpacing, sectionSpacing)
import Page.UI.Images exposing (musicNotationSvg)
import Page.UI.Record.Incipits exposing (viewIncipit)
import Page.UI.Record.PageTemplate exposing (pageLinkTemplate, subHeaderTemplate)
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

        incipitLink =
            pageLinkTemplate cfg.language labelLanguageMap headingLG { id = sourceUrl }
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
