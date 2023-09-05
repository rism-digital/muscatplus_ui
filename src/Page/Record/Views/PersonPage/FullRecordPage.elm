module Page.Record.Views.PersonPage.FullRecordPage exposing (viewFullPersonPage)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, padding, paddingXY, px, row, scrollbarY, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.SourceSearch exposing (viewRecordSourceSearchTabBar, viewSourceSearchTab)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (userCircleSvg)
import Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.NameVariantsSection exposing (viewNameVariantsSection)
import Page.UI.Record.Notes exposing (viewNotesSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplate, pageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, searchHeaderHeight)
import Session exposing (Session)


viewDescriptionTab : Language -> PersonBody -> Element msg
viewDescriptionTab language body =
    let
        summaryBody labels =
            row
                (width fill
                    :: height fill
                    :: alignTop
                    :: sectionBorderStyles
                )
                [ column
                    [ spacing lineSpacing
                    , width fill
                    , height fill
                    ]
                    [ viewSummaryField language labels ]
                ]
    in
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
            [ viewMaybe summaryBody body.summary
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
                    viewSourceSearchTab session model
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
                , height (px searchHeaderHeight)
                , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
                , Border.color (colourScheme.darkBlue |> convertColorToElementColor)
                ]
                [ column
                    [ spacingXY 0 lineSpacing
                    , width fill
                    , height fill
                    , centerY
                    , alignLeft
                    , paddingXY 20 0
                    ]
                    [ pageHeaderTemplate session.language Nothing body
                    , viewRecordTopBarRouter session.language model body
                    ]
                ]
            , pageBodyView
            , pageFooterTemplate session session.language body
            ]
        ]


viewRecordTopBarRouter : Language -> RecordPageModel RecordMsg -> PersonBody -> Element RecordMsg
viewRecordTopBarRouter language model body =
    let
        spacerEl =
            el [ height (px 35) ] (text "")
    in
    ME.unpack (\() -> spacerEl)
        (\sourceBlock ->
            if sourceBlock.totalItems /= 0 then
                viewRecordSourceSearchTabBar
                    { language = language
                    , model = model
                    , recordId = body.id
                    , searchUrl = sourceBlock.url
                    , tabLabel = localTranslations.sourceContents
                    }

            else
                spacerEl
        )
        body.sources
