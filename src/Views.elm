module Views exposing (view)

import Browser
import Css
import Css.Global
import Desktop.About.About
import Desktop.About.Help
import Desktop.About.Options
import Desktop.Error.Views
import Desktop.Front.Views
import Desktop.Record.Views
import Desktop.Search.Views
import Desktop.SideBar.Views
import Device exposing (DeviceView(..), detectView)
import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, height, inFront, layout, none, paddingXY, px, row, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Html.Styled exposing (toUnstyled)
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Loading exposing (loadingIndicator)
import Mobile.About.Views.About
import Mobile.About.Views.Options
import Mobile.BottomBar.Views
import Mobile.Error.Views
import Mobile.Front.Views
import Mobile.Record.Views
import Mobile.Search.Views
import Model exposing (Model(..), toSession)
import Msg exposing (Msg)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (onlineTextSvg, rismLogo)
import Page.UI.Style exposing (colourScheme, rgbaFloatToInt)
import Response exposing (Response(..), ServerData(..))


view : Model -> Browser.Document Msg
view model =
    let
        deviceView =
            toSession model
                |> .device
                |> detectView

        -- set the colour for links (a tags) globally.
        globalLinkColor =
            let
                { blue, green, red } =
                    colourScheme.lightBlue
                        |> rgbaFloatToInt
            in
            [ Css.color (Css.rgb red green blue) ]

        defaultTitle =
            "RISM Online"

        pageTitle =
            case model of
                SearchPage session _ ->
                    extractLabelFromLanguageMap session.language localTranslations.search ++ " RISM"

                SourcePage session pageModel ->
                    case pageModel.response of
                        Response (SourceData body) ->
                            extractLabelFromLanguageMap session.language body.label

                        _ ->
                            defaultTitle

                PersonPage session pageModel ->
                    case pageModel.response of
                        Response (PersonData body) ->
                            extractLabelFromLanguageMap session.language body.label

                        _ ->
                            defaultTitle

                InstitutionPage session pageModel ->
                    case pageModel.response of
                        Response (InstitutionData body) ->
                            extractLabelFromLanguageMap session.language body.label

                        _ ->
                            defaultTitle

                _ ->
                    defaultTitle
    in
    { title = pageTitle
    , body =
        [ toUnstyled
            (Css.Global.global
                [ Css.Global.a globalLinkColor -- Ensures in-text links are also displayed in blue.
                ]
            )
        , layout
            [ width fill
            , bodyFont
            , bodyFontColour
            , fontBaseSize

            --, pageBackground
            ]
            (viewPageBody deviceView model)
        ]
    }


viewPageBody : DeviceView -> Model -> Element Msg
viewPageBody deviceView model =
    let
        pageSession =
            toSession model

        navbarView =
            case deviceView of
                MobileView ->
                    Element.map Msg.UserInteractedWithBottomBar (Mobile.BottomBar.Views.view pageSession)

                DesktopView ->
                    viewIf
                        (column
                            [ width (px 70)
                            , height fill
                            , alignTop
                            , inFront (Element.map Msg.UserInteractedWithSideBar (Desktop.SideBar.Views.viewRouter pageSession))
                            ]
                            []
                        )
                        (not pageSession.isFramed)

        pageView =
            case ( model, deviceView ) of
                ( NotFoundPage session pageModel, MobileView ) ->
                    Element.map Msg.UserInteractedWithNotFoundPage (Mobile.Error.Views.view session pageModel)

                ( NotFoundPage session pageModel, DesktopView ) ->
                    Element.map Msg.UserInteractedWithNotFoundPage (Desktop.Error.Views.view session pageModel)

                ( SearchPage session pageModel, MobileView ) ->
                    Element.map Msg.UserInteractedWithSearchPage (Mobile.Search.Views.view session pageModel)

                ( SearchPage session pageModel, DesktopView ) ->
                    Element.map Msg.UserInteractedWithSearchPage (Desktop.Search.Views.view session pageModel)

                ( FrontPage session pageModel, MobileView ) ->
                    Element.map Msg.UserInteractedWithFrontPage (Mobile.Front.Views.view session pageModel)

                ( FrontPage session pageModel, DesktopView ) ->
                    Element.map Msg.UserInteractedWithFrontPage (Desktop.Front.Views.view session pageModel)

                ( SourcePage session pageModel, MobileView ) ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.view session pageModel)

                ( SourcePage session pageModel, DesktopView ) ->
                    Element.map Msg.UserInteractedWithRecordPage (Desktop.Record.Views.view session pageModel)

                ( PersonPage session pageModel, MobileView ) ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.view session pageModel)

                ( PersonPage session pageModel, DesktopView ) ->
                    Element.map Msg.UserInteractedWithRecordPage (Desktop.Record.Views.view session pageModel)

                ( InstitutionPage session pageModel, MobileView ) ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.view session pageModel)

                ( InstitutionPage session pageModel, DesktopView ) ->
                    Element.map Msg.UserInteractedWithRecordPage (Desktop.Record.Views.view session pageModel)

                ( AboutPage session pageModel, MobileView ) ->
                    Element.map Msg.UserInteractedWithAboutPage (Mobile.About.Views.About.view session pageModel)

                ( AboutPage session pageModel, DesktopView ) ->
                    Element.map Msg.UserInteractedWithAboutPage (Desktop.About.About.view session pageModel)

                ( HelpPage session, MobileView ) ->
                    Element.map Msg.UserInteractedWithAboutPage (Desktop.About.Help.view session)

                ( HelpPage session, DesktopView ) ->
                    Element.map Msg.UserInteractedWithAboutPage (Desktop.About.Help.view session)

                ( OptionsPage session pageModel, MobileView ) ->
                    Element.map Msg.UserInteractedWithAboutPage (Mobile.About.Views.Options.view session pageModel)

                ( OptionsPage session pageModel, DesktopView ) ->
                    Element.map Msg.UserInteractedWithAboutPage (Desktop.About.Options.view session pageModel)
    in
    case deviceView of
        MobileView ->
            let
                logoView =
                    row
                        [ height (px 40)
                        , width fill
                        , Background.color colourScheme.darkBlue
                        , spacing 5
                        , paddingXY 8 5
                        , Background.color colourScheme.darkBlue
                        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                        , Border.color colourScheme.darkGrey
                        ]
                        [ el [ alignLeft, centerY ] (rismLogo colourScheme.white 28)
                        , el [ alignLeft, centerY, width (px 72) ] (onlineTextSvg colourScheme.white)
                        ]
            in
            row
                [ width fill
                , height fill
                ]
                [ column
                    [ centerX
                    , width fill
                    , height fill
                    ]
                    [ logoView
                    , loadingIndicator model
                    , pageView
                    , navbarView
                    ]
                ]

        DesktopView ->
            row
                [ width fill
                , height fill
                ]
                [ navbarView
                , column
                    [ width fill
                    , height fill
                    ]
                    [ loadingIndicator model
                    , pageView
                    ]
                ]
