module View exposing (view)

import Browser
import Element exposing (Element, alignRight, centerX, centerY, column, el, fill, fillPortion, height, inFront, layout, link, none, paddingXY, px, row, text, width)
import Element.Font as Font
import Element.Region as Region
import Language exposing (extractLabelFromLanguageMap, languageOptionsForDisplay, localTranslations, parseLocaleToLanguage)
import Model exposing (Model(..), toSession)
import Msg exposing (Msg(..))
import Page.Front.Views
import Page.NotFound.Views
import Page.Record.Model exposing (CurrentRecordViewTab(..))
import Page.Record.Views.InstitutionPage
import Page.Record.Views.PersonPage
import Page.Record.Views.PersonPage.TableOfContents exposing (createPersonRecordToc)
import Page.Record.Views.PlacePage
import Page.Record.Views.SourcePage
import Page.Record.Views.SourcePage.TableOfContents exposing (createSourceRecordToc)
import Page.Route exposing (Route(..))
import Page.Search.Views
import Page.UI.Animations exposing (progressBar)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize, footerBackground, headerBottomBorder, headingMD, linkColour, minimalDropShadow, pageBackground)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Images exposing (rismLogo)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor, footerHeight, headerHeight)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)


view : Model -> Browser.Document Msg
view model =
    let
        pageSession =
            toSession model

        pageView =
            case model of
                FrontPage session pageModel ->
                    Element.map Msg.UserInteractedWithFrontPage (Page.Front.Views.view session pageModel)

                SearchPage session pageModel ->
                    Element.map Msg.UserInteractedWithSearchPage (Page.Search.Views.view session pageModel)

                SourcePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.SourcePage.view session pageModel)

                PersonPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.PersonPage.view session pageModel)

                InstitutionPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.InstitutionPage.view session pageModel)

                PlacePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Page.Record.Views.PlacePage.view session pageModel)

                NotFoundPage session pageModel ->
                    Element.map Msg.UserInteractedWithNotFoundPage (Page.NotFound.Views.view session pageModel)

        defaultView =
            ( "RISM Online", none )

        ( pageTitle, pageToc ) =
            case model of
                SearchPage session _ ->
                    ( extractLabelFromLanguageMap session.language localTranslations.search ++ " RISM"
                    , none
                    )

                SourcePage session pageModel ->
                    case pageModel.response of
                        Response (SourceData body) ->
                            ( extractLabelFromLanguageMap session.language body.label
                            , Element.map UserInteractedWithRecordPage (createSourceRecordToc session.language body)
                            )

                        _ ->
                            defaultView

                PersonPage session pageModel ->
                    case pageModel.response of
                        Response (PersonData body) ->
                            let
                                toc =
                                    if pageModel.currentTab == DefaultRecordViewTab then
                                        Element.map UserInteractedWithRecordPage (createPersonRecordToc session.language body)

                                    else
                                        none
                            in
                            ( extractLabelFromLanguageMap session.language body.label
                            , toc
                            )

                        _ ->
                            defaultView

                InstitutionPage session pageModel ->
                    case pageModel.response of
                        Response (InstitutionData body) ->
                            ( extractLabelFromLanguageMap session.language body.label
                            , none
                            )

                        _ ->
                            defaultView

                _ ->
                    defaultView
    in
    { title = pageTitle
    , body =
        [ layout
            [ width fill
            , bodyFont
            , bodyFontColour
            , fontBaseSize
            , pageBackground
            , inFront pageToc
            ]
            (column
                [ centerX
                , width fill
                , height fill
                ]
                [ loadingIndicator pageSession model
                , siteHeader pageSession model
                , pageView
                , siteFooter pageSession model
                ]
            )
        ]
    }


loadingIndicator : Session -> Model -> Element Msg
loadingIndicator session model =
    let
        loadingView =
            row
                [ width fill
                ]
                [ progressBar ]

        chooseView resp =
            case resp of
                Loading _ ->
                    loadingView

                _ ->
                    none
    in
    case model of
        SearchPage _ pageModel ->
            chooseView pageModel.response

        SourcePage _ pageModel ->
            chooseView pageModel.response

        _ ->
            none


siteHeader : Session -> Model -> Element Msg
siteHeader session model =
    row
        [ width fill
        , height (px headerHeight)
        , headerBottomBorder
        ]
        [ column
            [ width fill
            , height fill
            , centerX
            , paddingXY 20 0
            ]
            [ row
                [ width fill
                , height fill
                ]
                [ column
                    [ width (px 200)
                    , Font.semiBold
                    , headingMD
                    , centerY
                    ]
                    [ link
                        [ Font.color (colourScheme.darkBlue |> convertColorToElementColor) ]
                        { url = "/", label = text "RISM Online" }
                    ]
                , column
                    [ width (fillPortion 8)
                    , centerY
                    ]
                    [ link
                        [ linkColour ]
                        { url = "/", label = text (extractLabelFromLanguageMap session.language localTranslations.home) }
                    ]
                , column
                    [ width (fillPortion 2)
                    , alignRight
                    ]
                    [ row
                        [ alignRight
                        ]
                        [ dropdownSelect UserChangedLanguageSelect languageOptionsForDisplay parseLocaleToLanguage session.language ]
                    ]
                ]
            ]
        ]


siteFooter : Session -> Model -> Element Msg
siteFooter session model =
    let
        muscatLink =
            if session.showMuscatLinks == True then
                viewMuscatLink session

            else
                none
    in
    row
        [ width fill
        , height (px footerHeight)
        , footerBackground
        , minimalDropShadow
        , Region.footer
        ]
        [ column
            [ width fill
            , height fill
            , centerX
            , paddingXY 20 0
            ]
            [ row
                [ width fill
                , height fill
                , Font.color (colourScheme.white |> convertColorToElementColor)
                , Font.semiBold
                ]
                [ column
                    [ width (px 200) ]
                    [ el
                        []
                        (rismLogo colourScheme.white (footerHeight - 10))
                    ]
                , column
                    [ width (fillPortion 10)
                    ]
                    [ text "Tagline / Impressum" ]
                , muscatLink
                ]
            ]
        ]


viewMuscatLink : Session -> Element msg
viewMuscatLink session =
    let
        linkBase =
            "https://muscat.rism.info/admin/"

        linkTmpl muscatUrl =
            column
                [ alignRight
                , paddingXY 5 0
                ]
                [ link
                    []
                    { url = muscatUrl
                    , label = text "View record in Muscat"
                    }
                ]
    in
    case session.route of
        SourcePageRoute id ->
            linkTmpl (linkBase ++ "sources/" ++ String.fromInt id)

        PersonPageRoute id ->
            linkTmpl (linkBase ++ "people/" ++ String.fromInt id)

        InstitutionPageRoute id ->
            linkTmpl (linkBase ++ "institutions/" ++ String.fromInt id)

        _ ->
            none
