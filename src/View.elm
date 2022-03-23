module View exposing (view)

import Browser
import Css
import Css.Global
import Element exposing (Element, alignRight, alignTop, centerX, column, el, fill, fillPortion, height, inFront, layout, link, none, paddingXY, px, row, text, width)
import Element.Font as Font
import Element.Region as Region
import Html.Styled exposing (toUnstyled)
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
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
import Page.SideBar.Views
import Page.UI.Animations exposing (progressBar)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize, footerBackground, pageBackground)
import Page.UI.Images exposing (rismLogo)
import Page.UI.Style exposing (colourScheme, colours, convertColorToElementColor, footerHeight)
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

        ( pageTitle, _ ) =
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

                PlacePage session pageModel ->
                    case pageModel.response of
                        Response (PlaceData body) ->
                            ( extractLabelFromLanguageMap session.language body.label
                            , none
                            )

                        _ ->
                            defaultView

                _ ->
                    defaultView

        -- set the colour for links (a tags) globally.
        globalLinkColor =
            let
                { red, green, blue, alpha } =
                    colours.lightBlue
            in
            [ Css.color (Css.rgb red green blue) ]
    in
    { title = pageTitle
    , body =
        [ toUnstyled
            (Css.Global.global
                [ Css.Global.a globalLinkColor
                ]
            )
        , layout
            [ width fill
            , bodyFont
            , bodyFontColour
            , fontBaseSize
            , pageBackground
            ]
            (row
                [ width fill
                , height fill
                ]
                [ column
                    [ width (px 90)
                    , height fill
                    , alignTop
                    , inFront (Element.map Msg.UserInteractedWithSideBar (Page.SideBar.Views.view pageSession))
                    ]
                    []
                , column
                    [ centerX
                    , width fill
                    , height fill
                    ]
                    [ loadingIndicator model
                    , pageView
                    ]
                ]
            )
        ]
    }


loadingIndicator : Model -> Element Msg
loadingIndicator model =
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
            case pageModel.response of
                Loading _ ->
                    loadingView

                _ ->
                    case pageModel.preview of
                        Loading _ ->
                            loadingView

                        _ ->
                            none

        SourcePage _ pageModel ->
            chooseView pageModel.response

        PersonPage _ pageModel ->
            chooseView pageModel.response

        InstitutionPage _ pageModel ->
            chooseView pageModel.response

        FrontPage _ pageModel ->
            chooseView pageModel.response

        _ ->
            none


siteFooter : Session -> Element Msg
siteFooter session =
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
