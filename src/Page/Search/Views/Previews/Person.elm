module Page.Search.Views.Previews.Person exposing (..)

import Element exposing (Element, alignTop, column, fill, height, paddingXY, row, spacing, width)
import Language exposing (Language)
import Page.Record.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Record.Views.Notes exposing (viewNotesSection)
import Page.Record.Views.PageTemplate exposing (pageHeaderTemplate, pageUriTemplate)
import Page.Record.Views.PersonPage.NameVariantsSection exposing (viewNameVariantsSection)
import Page.Record.Views.Relationship exposing (viewRelationshipsSection)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)


viewPersonPreview : Language -> PersonBody -> Element msg
viewPersonPreview language body =
    let
        summaryBody labels =
            row
                (List.concat [ widthFillHeightFill, sectionBorderStyles ])
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ viewSummaryField language labels ]
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY 20 10
        ]
        [ column
            (List.append [ spacing sectionSpacing ] widthFillHeightFill)
            [ row
                widthFillHeightFill
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ pageHeaderTemplate language body
                    , pageUriTemplate language body
                    ]
                ]
            , row
                widthFillHeightFill
                [ column
                    [ width fill
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
