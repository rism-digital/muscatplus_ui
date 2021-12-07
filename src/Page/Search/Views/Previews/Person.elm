module Page.Search.Views.Previews.Person exposing (..)

import Element exposing (Element, column, el, fill, link, none, paddingXY, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Page.Record.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Record.Views.Notes exposing (viewNotesSection)
import Page.Record.Views.PageTemplate exposing (pageHeaderTemplate, pageUriTemplate)
import Page.Record.Views.PersonPage.NameVariantsSection exposing (viewNameVariantsSection)
import Page.Record.Views.Relationship exposing (viewRelationshipsSection)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, sectionSpacing, widthFillHeightFill)
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

        pageBodyView =
            row
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
    in
    row
        widthFillHeightFill
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
            , pageBodyView
            ]
        ]
