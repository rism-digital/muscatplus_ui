module Mobile exposing (view)

import Browser
import Css
import Css.Global
import Element exposing (alignLeft, centerX, centerY, column, el, fill, height, layout, paddingXY, px, row, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Html.Styled exposing (toUnstyled)
import Loading exposing (loadingIndicator)
import Mobile.About.Views.About
import Mobile.About.Views.Help
import Mobile.About.Views.Options
import Mobile.BottomBar.Views
import Mobile.Error.Views
import Mobile.Front.Views
import Mobile.Record.Views
import Mobile.Record.Views.PlacePage
import Mobile.Search.Views
import Model exposing (Model(..), toSession)
import Msg exposing (Msg)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize)
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
                [ height (px 40)
                , width fill
                , Background.color colourScheme.darkBlue
                , spacing 5
                , paddingXY 8 5
                , Background.color colourScheme.darkBlue
                , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
                , Border.color colourScheme.darkGrey
                ]
                [ el [ alignLeft, centerY ] (rismLogo colourScheme.white 28)
                , el [ alignLeft, centerY, width (px 72) ] (onlineTextSvg colourScheme.white)
                ]

        pageSession =
            toSession model

        pageView =
            case model of
                NotFoundPage session pageModel ->
                    Element.map Msg.UserInteractedWithNotFoundPage (Mobile.Error.Views.view session pageModel)

                SearchPage session pageModel ->
                    Element.map Msg.UserInteractedWithSearchPage (Mobile.Search.Views.view session pageModel)

                FrontPage session pageModel ->
                    Element.map Msg.UserInteractedWithFrontPage (Mobile.Front.Views.view session pageModel)

                SourcePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.view session pageModel)

                PersonPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.view session pageModel)

                InstitutionPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Mobile.Record.Views.view session pageModel)

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
        [ toUnstyled
            (Css.Global.global
                [ Css.Global.a globalLinkColour
                , Css.Global.html
                    [ Css.property "text-size-adjust" "100%"
                    , Css.property "-webkit-text-size-adjust" "100%"
                    , Css.property "-moz-text-size-adjust" "100%"
                    ]
                ]
            )
        , layout
            [ width fill
            , bodyFont
            , bodyFontColour
            , fontBaseSize
            ]
            (row
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
                    , bottomBarView
                    ]
                ]
            )
        ]
    }
