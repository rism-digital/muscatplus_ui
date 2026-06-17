module Page.UI.Record.Previews.Person exposing (viewPersonPreview)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, htmlAttribute, paddingXY, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.Bodies.Person exposing (viewPersonSections)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplate)
import Page.UI.Style exposing (colourScheme)


viewPersonPreview :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> PersonBody
    -> Element msg
viewPersonPreview { language, paragraphFormatter, relationshipFormatter, summaryFormatter } body =
    let
        previewBody =
            viewPersonSections
                { language = language
                , includeDigitalObjects = False
                , paragraphFormatter = paragraphFormatter
                , recordId = body.id
                , relationshipFormatter = relationshipFormatter
                , summaryFormatter = summaryFormatter
                }
                body

        recordIcon =
            el
                [ width (px 25)
                , height (px 25)
                , centerY
                ]
                (peopleSvg colourScheme.darkBlue)
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
            [ width fill
            , alignTop
            , spacing sectionSpacing
            ]
            [ row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ pageHeaderTemplate language (Just recordIcon) body
                    , pageFullRecordTemplate language body
                    ]
                ]
            , row
                [ width fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignTop
                    , spacing sectionSpacing
                    ]
                    previewBody
                ]
            ]
        ]
