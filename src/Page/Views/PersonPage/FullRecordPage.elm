module Page.Views.PersonPage.FullRecordPage exposing (..)

import Element exposing (Element, column, el, fill, height, htmlAttribute, link, row, spacing, text, width)
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Components exposing (h4, viewSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.Views.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Notes exposing (viewNotesSection)
import Page.Views.PersonPage.NameVariantsSection exposing (viewNameVariantsSection)
import Page.Views.Relationship exposing (viewPersonRelationshipsSection)


viewFullPersonPage : PersonBody -> Language -> Element Msg
viewFullPersonPage body language =
    let
        recordUri =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.recordURI ++ ": "))
                , link
                    [ Font.color colourScheme.lightBlue ]
                    { url = body.id
                    , label = text body.id
                    }
                ]

        extAuthorities =
            viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 5
            ]
            [ row
                [ width fill
                , htmlAttribute (HTA.id body.sectionToc)
                ]
                [ h4 language body.label ]
            , recordUri
            , extAuthorities
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewMaybe (viewSummaryField language) body.summary
                    , viewMaybe (viewNameVariantsSection language) body.nameVariants
                    , viewMaybe (viewPersonRelationshipsSection language) body.relationships
                    , viewMaybe (viewNotesSection language) body.notes
                    , viewMaybe (viewExternalResourcesSection language) body.externalResources
                    ]
                ]
            ]
        ]
