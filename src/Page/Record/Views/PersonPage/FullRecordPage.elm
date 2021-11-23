module Page.Record.Views.PersonPage.FullRecordPage exposing (..)

import Element exposing (Element, alignBottom, alignRight, column, el, fill, height, htmlAttribute, link, maximum, minimum, none, padding, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h4, viewRecordHistory, viewSummaryField)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Views.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.Views.ExternalResources exposing (viewExternalResourcesSection)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Notes exposing (viewNotesSection)
import Page.Record.Views.PersonPage.NameVariantsSection exposing (viewNameVariantsSection)
import Page.Record.Views.PersonPage.SourcesTab exposing (viewPersonSourcesTab)
import Page.Views.Relationship exposing (viewRelationshipsSection)


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

        recordUri =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.recordURI ++ ": "))
                , link
                    [ linkColour ]
                    { url = body.id
                    , label = text body.id
                    }
                ]

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
        [ width (fill |> minimum 800 |> maximum 1400)
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
            , viewTabSwitcher language currentTab body
            , pageBodyView
            , row
                [ width fill
                , alignBottom
                ]
                [ column
                    [ width fill
                    , alignRight
                    ]
                    [ viewRecordHistory body.recordHistory language
                    ]
                ]
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
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
            , viewMaybe (viewSummaryField language) body.summary
            , viewMaybe (viewNameVariantsSection language) body.nameVariants
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewNotesSection language) body.notes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            ]
        ]
