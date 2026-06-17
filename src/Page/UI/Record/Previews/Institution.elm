module Page.UI.Record.Previews.Institution exposing (viewInstitutionPreview)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, htmlAttribute, paddingXY, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.Bodies.Institution exposing (viewInstitutionSections)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplate)
import Page.UI.Style exposing (colourScheme)


viewInstitutionPreview :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    , window : ( Int, Int )
    }
    -> InstitutionBody
    -> Element msg
viewInstitutionPreview { language, paragraphFormatter, relationshipFormatter, summaryFormatter, window } body =
    let
        previewBody =
            viewInstitutionSections
                { includeContributions = True
                , includeDigitalObjects = False
                , includeLocationMap = True
                , language = language
                , paragraphFormatter = paragraphFormatter
                , recordId = body.id
                , relationshipFormatter = relationshipFormatter
                , summaryFormatter = summaryFormatter
                , window = window
                }
                body

        recordIcon =
            el
                [ width (px 25)
                , height (px 25)
                , centerY
                ]
                (institutionSvg colourScheme.darkBlue)
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
                , height fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    ]
                    previewBody
                ]
            ]
        ]
