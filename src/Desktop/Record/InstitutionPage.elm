module Desktop.Record.InstitutionPage exposing (viewFullInstitutionPage)

import Desktop.Record.SourceSearch exposing (viewRecordSearchSourcesLink, viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, maximum, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Attributes exposing (desktopDisplayWidth, minimalDropShadow, sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.LocationSection exposing (viewLocationAddressSection, viewLocationMapSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.OrganizationDetailsSection exposing (viewOrganizationDetailsSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, searchSourcesLinkHeight, tabBarHeight)
import Session exposing (Session)


viewDescriptionTab : Language -> ( Int, Int ) -> InstitutionBody -> Element msg
viewDescriptionTab language ( windowWidth, windowHeight ) body =
    let
        isEmpty =
            ME.isNothing body.organizationDetails
                && ME.isNothing body.location
                && ME.isNothing body.relationships
                && ME.isNothing body.notes
                && ME.isNothing body.externalResources
                && ME.isNothing body.externalAuthorities

        pageBody =
            pageBodyOrEmpty language
                isEmpty
                [ viewMaybe
                    (viewOrganizationDetailsSection
                        { language = language
                        , summaryFormatter = viewSummaryField
                        }
                    )
                    body.organizationDetails
                , viewMaybe
                    (viewLocationAddressSection
                        { language = language
                        , summaryFormatter = viewSummaryField
                        }
                    )
                    body.location
                , viewMaybe
                    (viewRelationshipsSection
                        { language = language
                        , relationshipFormatter = viewRelationshipBody
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewNotesSection
                        { language = language
                        , paragraphFormatter = viewParagraphField
                        }
                    )
                    body.notes
                , viewMaybe (viewExternalResourcesSection language) body.externalResources
                , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
                , viewMaybe
                    (viewLocationMapSection
                        { language = language
                        , summaryFormatter = viewSummaryField
                        }
                        ( windowWidth, windowHeight )
                    )
                    body.location
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width (fill |> maximum desktopDisplayWidth)
            , alignTop
            , spacing sectionSpacing
            , padding 20
            ]
            pageBody
        ]


viewFullInstitutionPage :
    Session
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewFullInstitutionPage session model body =
    let
        pageBodyView =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    viewDescriptionTab session.language session.window body

                RelatedSourcesSearchTab _ ->
                    viewSourceSearchTabBody session model

        headerHeight =
            if session.isFramed then
                px (recordTitleHeight + searchSourcesLinkHeight)

            else
                px (tabBarHeight + recordTitleHeight)

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (institutionSvg colourScheme.darkBlue)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just icon) body

            else
                pageHeaderTemplate session.language (Just icon) body

        tabBar =
            if session.isFramed then
                viewMaybe (viewRecordSearchSourcesLink session.language localTranslations.sources) body.sources

            else
                viewRecordTopBar session.language model body
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ row
                [ width fill
                , height headerHeight
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.midGrey
                ]
                [ column
                    [ width fill
                    , height fill
                    , centerY
                    , alignLeft
                    , paddingXY 20 0
                    , minimalDropShadow
                    ]
                    [ pageHeader
                    , tabBar
                    ]
                ]
            , pageBodyView
            , pageFooterTemplateRouter session session.language body
            ]
        ]


viewRecordTopBar :
    Language
    -> RecordPageModel RecordMsg
    -> InstitutionBody
    -> Element RecordMsg
viewRecordTopBar language model body =
    viewRecordSourceSearchTabBar
        { body = body.sources
        , language = language
        , model = model
        , recordId = body.id
        , tabLabel = localTranslations.sources
        }
