module Page.UI.Record.Previews.Person exposing (viewPersonPreview)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, htmlAttribute, paddingXY, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language, LanguageMap)
import Maybe.Extra as ME
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplate)
import Page.UI.Record.ReferencesNotesSection exposing (viewNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Record.WorksSection exposing (viewPersonWorksSection)
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
        isEmpty =
            ME.isNothing body.biographicalDetails
                && ME.isNothing body.nameVariants
                && ME.isNothing body.relationships
                && ME.isNothing body.notes
                && ME.isNothing body.externalResources

        previewBody =
            pageBodyOrEmpty language
                isEmpty
                [ viewMaybe
                    (viewBiographicalDetailsSection
                        { language = language
                        , summaryFormatter = summaryFormatter
                        }
                    )
                    body.biographicalDetails
                , viewMaybe
                    (viewNameVariantsSection
                        { language = language
                        , summaryFormatter = summaryFormatter
                        }
                    )
                    body.nameVariants
                , viewMaybe
                    (viewRelationshipsSection
                        { language = language
                        , relationshipFormatter = relationshipFormatter
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewNotesSection
                        { language = language
                        , paragraphFormatter = paragraphFormatter
                        }
                    )
                    body.notes
                , viewMaybe (viewExternalResourcesSection language) body.externalResources
                , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
                , viewMaybe (viewPersonWorksSection language) body.works
                ]

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
