module Page.Record.Views.PersonPage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, column, el, fill, height, none, padding, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, formatNumberByLanguage)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Views.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.Record.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Record.Views.Notes exposing (viewNotesSection)
import Page.Record.Views.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate, pageUriTemplate)
import Page.Record.Views.PersonPage.NameVariantsSection exposing (viewNameVariantsSection)
import Page.Record.Views.PersonPage.SourcesTab exposing (viewPersonSourcesTab)
import Page.Record.Views.Relationship exposing (viewRelationshipsSection)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewFullPersonPage :
    Language
    -> RecordPageModel
    -> PersonBody
    -> Element RecordMsg
viewFullPersonPage language model body =
    let
        currentTab =
            model.currentTab

        searchData =
            model.searchResults

        searchParams =
            model.activeSearch

        pageBodyView =
            case currentTab of
                DefaultRecordViewTab ->
                    viewDescriptionTab language body

                PersonSourcesRecordSearchTab sourcesUrl ->
                    viewPersonSourcesTab language sourcesUrl searchParams searchData

                _ ->
                    none
    in
    row
        widthFillHeightFill
        [ column
            (List.append [ spacing sectionSpacing ] widthFillHeightFill)
            [ row
                [ width fill
                , alignTop
                ]
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ pageHeaderTemplate language body
                    , pageUriTemplate language body
                    ]
                ]

            --, viewTabSwitcher language currentTab body
            , pageBodyView
            , pageFooterTemplate language body
            ]
        ]


viewTabSwitcher :
    Language
    -> CurrentRecordViewTab
    -> PersonBody
    -> Element RecordMsg
viewTabSwitcher language currentTab body =
    let
        descriptionTab =
            let
                ( backgroundColour, fontColour ) =
                    case currentTab of
                        DefaultRecordViewTab ->
                            ( colourScheme.lightBlue, colourScheme.white )

                        _ ->
                            ( colourScheme.white, colourScheme.black )
            in
            column
                [ Border.width 1
                , padding 12
                , onClick (UserClickedRecordViewTab DefaultRecordViewTab)
                , pointer
                , Background.color (backgroundColour |> convertColorToElementColor)
                , Font.color (fontColour |> convertColorToElementColor)
                ]
                [ el
                    []
                    (text "Description")
                ]

        sourcesTab =
            case body.sources of
                Just sources ->
                    let
                        ( backgroundColour, fontColour ) =
                            case currentTab of
                                PersonSourcesRecordSearchTab _ ->
                                    ( colourScheme.lightBlue, colourScheme.white )

                                _ ->
                                    ( colourScheme.white, colourScheme.black )

                        sourceCount =
                            formatNumberByLanguage (toFloat sources.totalItems) language
                    in
                    column
                        [ Border.width 1
                        , padding 12
                        , onClick (UserClickedRecordViewTab (PersonSourcesRecordSearchTab sources.url))
                        , pointer
                        , Background.color (backgroundColour |> convertColorToElementColor)
                        , Font.color (fontColour |> convertColorToElementColor)
                        ]
                        [ el
                            []
                            (text ("Sources (" ++ sourceCount ++ ")"))
                        ]

                Nothing ->
                    none
    in
    row
        [ width fill
        , height (px 60)
        , spacing 20
        ]
        [ descriptionTab
        , sourcesTab
        ]


viewDescriptionTab : Language -> PersonBody -> Element msg
viewDescriptionTab language body =
    let
        summaryBody labels =
            row
                (List.concat [ widthFillHeightFill, sectionBorderStyles ])
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ viewSummaryField language labels ]
                ]
    in
    row
        widthFillHeightFill
        [ column
            [ width fill
            , spacing sectionSpacing
            , alignTop
            ]
            [ viewMaybe summaryBody body.summary
            , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
            , viewMaybe (viewNameVariantsSection language) body.nameVariants
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewNotesSection language) body.notes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            ]
        ]
