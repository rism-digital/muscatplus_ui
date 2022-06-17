module Page.UI.Record.Previews.Institution exposing (viewInstitutionPreview)

import Element exposing (Element, alignTop, column, fill, height, paddingXY, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (pageHeaderTemplate, pageUriTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)


viewInstitutionPreview : Language -> InstitutionBody -> Element msg
viewInstitutionPreview language body =
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
                , height fill
                , alignTop
                ]
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
