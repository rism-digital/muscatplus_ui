module Page.Search.Views.Previews.Institution exposing (..)

import Element exposing (Element, column, el, fill, height, link, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h4, viewSummaryField)
import Page.UI.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Notes exposing (viewNotesSection)
import Page.UI.Relationship exposing (viewRelationshipsSection)


viewInstitutionPreview : Language -> InstitutionBody -> Element msg
viewInstitutionPreview language body =
    let
        institutionLink =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.viewRecord ++ ": "))
                , link
                    [ linkColour ]
                    { url = body.id, label = text body.id }
                ]
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
                [ width fill ]
                [ h4 language body.label ]
            , institutionLink
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewMaybe (viewSummaryField language) body.summary
                    , viewMaybe (viewRelationshipsSection language) body.relationships
                    , viewMaybe (viewNotesSection language) body.notes
                    , viewMaybe (viewExternalResourcesSection language) body.externalResources
                    ]
                ]
            ]
        ]
