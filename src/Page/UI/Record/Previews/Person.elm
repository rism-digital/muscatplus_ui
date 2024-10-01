module Page.UI.Record.Previews.Person exposing (viewPersonPreview)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, htmlAttribute, paddingXY, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme)


viewPersonPreview : Language -> PersonBody -> Element msg
viewPersonPreview language body =
    let
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
                    [ viewMaybe (viewBiographicalDetailsSection language) body.biographicalDetails
                    , viewMaybe (viewNameVariantsSection language) body.nameVariants
                    , viewMaybe (viewRelationshipsSection language) body.relationships
                    , viewMaybe (viewNotesSection language) body.notes
                    , viewMaybe (viewExternalResourcesSection language) body.externalResources
                    ]
                ]
            ]
        ]
