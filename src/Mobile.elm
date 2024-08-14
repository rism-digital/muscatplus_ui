module Mobile exposing (..)

import Browser
import Css
import Css.Global
import Element exposing (above, alignRight, centerX, centerY, column, el, fill, height, htmlAttribute, inFront, layout, none, padding, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Html.Attributes as HA
import Html.Styled exposing (toUnstyled)
import Loading exposing (loadingIndicator)
import Mobile.About.Views.About
import Mobile.About.Views.Help
import Mobile.About.Views.Options
import Mobile.BottomBar.Views
import Mobile.Error.Views
import Mobile.Front.Views
import Mobile.Record.Views.InstitutionPage
import Mobile.Record.Views.PersonPage
import Mobile.Record.Views.PlacePage
import Mobile.Record.Views.SourcePage
import Mobile.Search.Views
import Model exposing (Model(..), toSession)
import Msg exposing (Msg)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize, minimalDropShadow)
import Page.UI.Images exposing (onlineTextSvg, rismLogo)
import Page.UI.Style exposing (colourScheme, rgbaFloatToInt)


view : Model -> Browser.Document Msg
view model =
    let
        globalLinkColour =
            let
                { blue, green, red } =
                    colourScheme.lightBlue
                        |> rgbaFloatToInt
            in
            [ Css.color (Css.rgb red green blue) ]

        defaultTitle =
            "RISM Online"

        logoView =
            row
                [ height (px 60)
                , Background.color colourScheme.darkBlue
                , spacing 5
                , paddingXY 8 5
                , minimalDropShadow
                , alignRight
                ]
                [ el [ centerX, centerY ] (rismLogo colourScheme.white 50)
                , el [ centerX, centerY, width (px 100) ] (onlineTextSvg colourScheme.white)
                ]

        pageSession =
            toSession model

        pageView =
            case model of
                FrontPage session pageModel ->
                    Element.map Msg.UserInteractedWithFrontPage (Mobile.Front.Views.view session pageModel)

                NotFoundPage session pageModel ->
                    Element.map Msg.UserInteractedWithNotFoundPage (Mobile.Error.Views.view session pageModel)

                SearchPage session pageModel ->
                    Element.map Msg.UserInteractedWithSearchPage (Mobile.Search.Views.view session pageModel)

                SourcePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.SourcePage.view session pageModel)

                PersonPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.PersonPage.view session pageModel)

                InstitutionPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.InstitutionPage.view session pageModel)

                AboutPage session pageModel ->
                    Element.map Msg.UserInteractedWithAboutPage (Mobile.About.Views.About.view session pageModel)

                HelpPage session ->
                    Element.map Msg.UserInteractedWithAboutPage (Mobile.About.Views.Help.view session)

                OptionsPage session pageModel ->
                    Element.map Msg.UserInteractedWithAboutPage (Mobile.About.Views.Options.view session pageModel)

                PlacePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.PlacePage.view session pageModel)

        bottomBarView =
            Element.map Msg.UserInteractedWithBottomBar (Mobile.BottomBar.Views.view pageSession)
    in
    { title = defaultTitle
    , body =
        [ toUnstyled (Css.Global.global [ Css.Global.a globalLinkColour ])
        , layout
            [ width fill
            , bodyFont
            , bodyFontColour
            , fontBaseSize
            ]
            (row
                [ width fill
                , height fill
                , htmlAttribute (HA.style "height" "100vh")
                ]
                [ column
                    [ centerX
                    , width fill
                    , height fill
                    , inFront logoView
                    ]
                    [ loadingIndicator model
                    , pageView
                    , bottomBarView
                    ]
                ]
            )
        ]
    }
