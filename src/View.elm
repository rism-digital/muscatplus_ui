module View exposing (view)

import Browser
import Element exposing (Element, alignRight, centerX, centerY, column, el, fill, fillPortion, height, html, htmlAttribute, layout, link, paddingXY, px, row, text, width)
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html.Attributes as HA
import Language exposing (extractLabelFromLanguageMap, languageOptionsForDisplay, localTranslations)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.Route exposing (Route(..))
import Page.UI.Attributes exposing (bodyFont, bodyFontColour, fontBaseSize, footerBackground, headerBottomBorder, headingMD, minimalDropShadow, pageBackground)
import Page.UI.Components exposing (languageSelect)
import Page.UI.Images exposing (rismLogo)
import Page.UI.Style exposing (colourScheme, footerHeight, headerHeight)
import Page.Views.FrontPage
import Page.Views.SearchPage


view : Model -> Browser.Document Msg
view model =
    let
        page =
            model.page

        pageView =
            case page.route of
                FrontPageRoute ->
                    Page.Views.FrontPage.view

                SearchPageRoute _ ->
                    Page.Views.SearchPage.view

                --SourceRoute _ ->
                --PersonRoute _ ->
                --InstitutionRoute _ ->
                --PlaceRoute _ ->
                --FestivalRoute _ ->
                --NotFound ->
                _ ->
                    Page.Views.FrontPage.view

        wrappedPageView =
            [ layout
                [ width fill
                , bodyFont
                , bodyFontColour
                , fontBaseSize
                , pageBackground
                ]
                (column
                    [ centerX
                    , width fill
                    , height fill
                    ]
                    [ siteHeader model
                    , pageView model
                    , siteFooter
                    ]
                )
            ]
    in
    { title = ""
    , body =
        wrappedPageView
    }


siteHeader : Model -> Element Msg
siteHeader model =
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
                        [ Font.color colourScheme.darkBlue ]
                        { url = "/", label = text "RISM Online" }
                    ]
                , column
                    [ width (fillPortion 8)
                    , centerY
                    ]
                    [ link
                        [ Font.color colourScheme.lightBlue ]
                        { url = "/", label = text (extractLabelFromLanguageMap model.language localTranslations.home) }
                    ]
                , column
                    [ width (fillPortion 2)
                    , alignRight
                    ]
                    [ row
                        [ alignRight
                        ]
                        [ languageSelect LanguageSelectChanged languageOptionsForDisplay model.language ]
                    ]
                ]
            ]
        ]


siteFooter : Element msg
siteFooter =
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
                , Font.color colourScheme.white
                , Font.semiBold
                ]
                [ column
                    [ width (px 200) ]
                    [ el
                        []
                        (rismLogo "#ffffff" (footerHeight - 10))
                    ]
                , column
                    [ width (fillPortion 10)
                    ]
                    [ text "Tagline / Impressum" ]
                ]
            ]
        ]
