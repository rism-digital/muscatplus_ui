module Page.UI.Record.Previews.Institution exposing (viewInstitutionPreview)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, htmlAttribute, paddingXY, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Maybe.Extra as ME
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.LocationSection exposing (viewLocationAddressSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.OrganizationDetailsSection exposing (viewOrganizationDetailsSection)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme)


viewInstitutionPreview : Language -> InstitutionBody -> Element msg
viewInstitutionPreview language body =
    let
        isEmpty =
            ME.isNothing body.organizationDetails
                && ME.isNothing body.location
                && ME.isNothing body.relationships
                && ME.isNothing body.notes
                && ME.isNothing body.externalResources
                && ME.isNothing body.externalAuthorities

        previewBody =
            pageBodyOrEmpty language
                isEmpty
                [ viewMaybe (viewOrganizationDetailsSection language) body.organizationDetails
                , viewMaybe (viewLocationAddressSection language) body.location
                , viewMaybe (viewRelationshipsSection language) body.relationships
                , viewMaybe (viewNotesSection language) body.notes
                , viewMaybe (viewExternalResourcesSection language) body.externalResources
                , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
                ]

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
