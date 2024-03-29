module Page.Record.Views.PersonPage.FullRecordPage exposing (viewFullPersonPage)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, none, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Border as Border
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.SourceSearch exposing (viewRecordSearchSourcesLink, viewRecordSourceSearchTabBar, viewSourceSearchTabBody)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (pageHeaderBackground, sectionSpacing)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, searchSourcesLinkHeight, tabBarHeight)
import Session exposing (Session)


viewDescriptionTab : Language -> PersonBody -> Element msg
viewDescriptionTab language body =
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        ]
        [ column
            [ width fill
            , spacing sectionSpacing
            , alignTop
            , padding 20
            ]
            [ viewMaybe (viewBiographicalDetailsSection language) body.biographicalDetails
            , viewMaybe (viewNameVariantsSection language) body.nameVariants
            , viewMaybe (viewRelationshipsSection language) body.relationships
            , viewMaybe (viewNotesSection language) body.notes
            , viewMaybe (viewExternalResourcesSection language) body.externalResources
            , viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
            ]
        ]


viewFullPersonPage :
    Session
    -> RecordPageModel RecordMsg
    -> PersonBody
    -> Element RecordMsg
viewFullPersonPage session model body =
    let
        pageBodyView =
            case model.currentTab of
                DefaultRecordViewTab _ ->
                    viewDescriptionTab session.language body

                RelatedSourcesSearchTab _ ->
                    viewSourceSearchTabBody session model

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (peopleSvg colourScheme.darkBlue)

        headerHeight =
            if session.isFramed then
                px (recordTitleHeight + searchSourcesLinkHeight)

            else
                px (tabBarHeight + recordTitleHeight)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just icon) body

            else
                pageHeaderTemplate session.language (Just icon) body

        tabBar =
            if session.isFramed then
                viewMaybe (viewRecordSearchSourcesLink session.language localTranslations.sources) body.sources

            else
                viewRecordTopBarRouter session.language model body
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , height headerHeight
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.darkBlue
                ]
                [ column
                    [ width fill
                    , height fill
                    , centerY
                    , alignLeft
                    , paddingXY 20 0
                    , pageHeaderBackground
                    ]
                    [ pageHeader
                    , tabBar
                    ]
                ]
            , pageBodyView
            , pageFooterTemplateRouter session session.language body
            ]
        ]


viewRecordTopBarRouter : Language -> RecordPageModel RecordMsg -> PersonBody -> Element RecordMsg
viewRecordTopBarRouter language model body =
    viewRecordSourceSearchTabBar
        { body = body.sources
        , language = language
        , model = model
        , recordId = body.id
        , tabLabel = localTranslations.sources
        }
