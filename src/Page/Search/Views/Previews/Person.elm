module Page.Search.Views.Previews.Person exposing (..)

import Element exposing (Element, column, el, fill, height, link, none, paddingXY, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.Record.Views.PersonPage.NameVariantsSection exposing (viewNameVariantsSection)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h4, viewSummaryField)
import Page.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Notes exposing (viewNotesSection)
import Page.Views.Relationship exposing (viewRelationshipsSection)


viewPersonPreview : Language -> PersonBody -> Element msg
viewPersonPreview language body =
    let
        sourcesLink =
            case body.sources of
                Just _ ->
                    link
                        [ linkColour
                        , paddingXY 20 0
                        ]
                        { url = body.id ++ "#sources", label = text "(Sources)" }

                Nothing ->
                    none

        personLink =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.viewRecord ++ ": "))
                , link
                    [ linkColour ]
                    { url = body.id, label = text body.id }
                , sourcesLink
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
            , personLink
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewMaybe (viewSummaryField language) body.summary
                    , viewMaybe (viewNameVariantsSection language) body.nameVariants
                    , viewMaybe (viewRelationshipsSection language) body.relationships
                    , viewMaybe (viewNotesSection language) body.notes
                    , viewMaybe (viewExternalResourcesSection language) body.externalResources
                    ]
                ]
            ]
        ]
