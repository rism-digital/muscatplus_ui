module Page.UI.Record.Previews.Institution exposing (viewInstitutionPreview)

import Element exposing (Element, alignTop, column, fill, height, paddingXY, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.Record.Views.InstitutionPage.LocationSection exposing (viewLocationAddressSection)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)


viewInstitutionPreview : Language -> InstitutionBody -> Element msg
viewInstitutionPreview language body =
    let
        summaryBody labels =
            row
                (width fill
                    :: height fill
                    :: alignTop
                    :: sectionBorderStyles
                )
                [ column
                    [ width fill
                    , height fill
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
                    [ viewMaybe summaryBody body.summary
                    , viewMaybe (viewLocationAddressSection language) body.location
                    , viewMaybe (viewRelationshipsSection language) body.relationships
                    , viewMaybe (viewNotesSection language) body.notes
                    , viewMaybe (viewExternalResourcesSection language) body.externalResources
                    , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
                    ]
                ]
            ]
        ]
