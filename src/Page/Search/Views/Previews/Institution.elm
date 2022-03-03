module Page.Search.Views.Previews.Institution exposing (..)

import Element exposing (Element, alignTop, column, fill, height, paddingXY, row, spacing, width)
import Language exposing (Language)
import Page.Record.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Record.Views.Notes exposing (viewNotesSection)
import Page.Record.Views.PageTemplate exposing (pageHeaderTemplate, pageUriTemplate)
import Page.Record.Views.Relationship exposing (viewRelationshipsSection)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)


viewInstitutionPreview : Language -> InstitutionBody -> Element msg
viewInstitutionPreview language body =
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
                    [ viewMaybe (viewSummaryField language) body.summary
                    , viewMaybe (viewRelationshipsSection language) body.relationships
                    , viewMaybe (viewNotesSection language) body.notes
                    , viewMaybe (viewExternalResourcesSection language) body.externalResources
                    ]
                ]
            ]
        ]
