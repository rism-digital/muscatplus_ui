module Page.UI.Record.Previews.Person exposing (..)

import Element exposing (Element, alignTop, column, fill, height, paddingXY, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (pageHeaderTemplate, pageUriTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)


viewPersonPreview : Language -> PersonBody -> Element msg
viewPersonPreview language body =
    let
        summaryBody labels =
            row
                ([ width fill
                 , height fill
                 , alignTop
                 ]
                    ++ sectionBorderStyles
                )
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewSummaryField language labels ]
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
                    [ pageHeaderTemplate language body
                    , pageUriTemplate language body
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
                    [ viewMaybe summaryBody body.summary
                    , viewMaybe (viewNameVariantsSection language) body.nameVariants
                    , viewMaybe (viewRelationshipsSection language) body.relationships
                    , viewMaybe (viewNotesSection language) body.notes
                    , viewMaybe (viewExternalResourcesSection language) body.externalResources
                    ]
                ]
            ]
        ]