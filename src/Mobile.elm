module Mobile exposing (..)

import Browser
import Css
import Css.Global
import Element exposing (centerX, column, fill, height, layout, none, row, width)
import Html.Styled exposing (toUnstyled)
import Loading exposing (loadingIndicator)
import Mobile.About.Views.About
import Mobile.About.Views.Help
import Mobile.About.Views.Options
import Mobile.Error.Views
import Mobile.Front.Views
import Mobile.Record.Views.InstitutionPage
import Mobile.Record.Views.PersonPage
import Mobile.Record.Views.PlacePage
import Mobile.Record.Views.SourcePage
import Mobile.Search.Views
import Model exposing (Model(..), toSession)
import Msg exposing (Msg)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize)
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
                ]
                [ column
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
