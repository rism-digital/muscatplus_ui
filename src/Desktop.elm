module Desktop exposing (view)

import Browser
import Css
import Css.Global
import Desktop.About.Views.About
import Desktop.About.Views.Help
import Desktop.About.Views.Options
import Desktop.Error.Views
import Desktop.Front.Views
import Desktop.Record.Views.InstitutionPage
import Desktop.Record.Views.PersonPage
import Desktop.Record.Views.PlacePage
import Desktop.Record.Views.SourcePage
import Desktop.Search.Views
import Desktop.SideBar.Views
import Element exposing (DeviceClass(..), Element, Orientation(..), alignTop, centerX, column, fill, height, inFront, layout, px, row, text, width)
import Html.Styled exposing (toUnstyled)
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Loading exposing (loadingIndicator)
import Model exposing (Model(..), toSession)
import Msg exposing (Msg)
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Style exposing (colourScheme, rgbaFloatToInt)
import Response exposing (Response(..), ServerData(..))


view : Model -> Browser.Document Msg
view model =
    let
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

                PlacePage session pageModel ->
                    case pageModel.response of
                        Response (PlaceData body) ->
                            extractLabelFromLanguageMap session.language body.label

                        _ ->
                            defaultTitle

                _ ->
                    defaultTitle

        pageSession =
            toSession model

        sidebarView =
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
            case model of
                NotFoundPage session pageModel ->
                    Element.map Msg.UserInteractedWithNotFoundPage (Desktop.Error.Views.view session pageModel)

                SearchPage session pageModel ->
                    Element.map Msg.UserInteractedWithSearchPage (Desktop.Search.Views.view session pageModel)

                FrontPage session pageModel ->
                    Element.map Msg.UserInteractedWithFrontPage (Desktop.Front.Views.view session pageModel)

                SourcePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Desktop.Record.Views.SourcePage.view session pageModel)

                PersonPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Desktop.Record.Views.PersonPage.view session pageModel)

                InstitutionPage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Desktop.Record.Views.InstitutionPage.view session pageModel)

                AboutPage session pageModel ->
                    Element.map Msg.UserInteractedWithAboutPage (Desktop.About.Views.About.view session pageModel)

                HelpPage session ->
                    Element.map Msg.UserInteractedWithAboutPage (Desktop.About.Views.Help.view session)

                OptionsPage session pageModel ->
                    Element.map Msg.UserInteractedWithAboutPage (Desktop.About.Views.Options.view session pageModel)

                PlacePage session pageModel ->
                    Element.map Msg.UserInteractedWithRecordPage (Desktop.Record.Views.PlacePage.view session pageModel)
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
            (row
                [ width fill
                , height fill
                ]
                [ sidebarView
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
