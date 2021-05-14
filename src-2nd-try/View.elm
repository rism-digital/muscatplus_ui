module View exposing (view)

import Browser
import Element exposing (Element, alignBottom, alignLeft, alignRight, centerX, centerY, column, el, fill, fillPortion, height, html, layout, link, paddingXY, px, row, text, width)
import Element.Font as Font
import Language exposing (extractLabelFromLanguageMap, languageOptionsForDisplay, localTranslations)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.FrontPage
import Page.SearchPage
import Routes exposing (Route(..))
import Search exposing (Message)
import UI.Attributes exposing (bodyFont, bodyFontColour, desktopResponsiveWidth, fontBaseSize, footerBackground, headerBottomBorder, headingMD, headingXL, headingXXL, pageBackground)
import UI.Components exposing (languageSelect)
import UI.Images exposing (rismLogo)
import UI.Style exposing (colourScheme)


frontPageMessages :
    { searchSubmit : Search.Message
    , searchInput : String -> Search.Message
    }
frontPageMessages =
    { searchSubmit = Search.Submit
    , searchInput = Search.Input
    }


view : Model -> Browser.Document Msg
view model =
    let
        route =
            model.route

        pageView =
            case route.currentRoute of
                FrontPageRoute ->
                    Page.FrontPage.view model

                SearchPageRoute _ ->
                    Page.SearchPage.view model

                --SourceRoute _ ->
                --PersonRoute _ ->
                --InstitutionRoute _ ->
                --PlaceRoute _ ->
                --FestivalRoute _ ->
                --NotFound ->
                _ ->
                    Page.FrontPage.view model

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
                    , siteContent pageView
                    , siteFooter
                    ]
                )
            ]
    in
    { title = ""
    , body =
        wrappedPageView
    }


{-|

    Wraps the page content in a pre-determined layout.

    Views that are wrapped here cannot 'break out' of the width
    that is imposed by this wrapper, so elements that span the width
    of the page are not possible once the view function has been wrapped
    here.

-}
siteContent : Element Msg -> Element Msg
siteContent pageView =
    row
        [ width fill
        , height fill
        , paddingXY 0 20
        ]
        [ column
            [ desktopResponsiveWidth
            , height fill
            , centerX
            ]
            [ pageView ]
        ]


siteHeader : Model -> Element Msg
siteHeader model =
    row
        [ width fill
        , height (px 60)
        , headerBottomBorder
        ]
        [ column
            [ desktopResponsiveWidth
            , height fill
            , centerX
            ]
            [ row
                [ width fill
                , height fill
                ]
                [ column
                    [ width (fillPortion 2)
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
        , height (px 120)
        , footerBackground
        ]
        [ column
            [ desktopResponsiveWidth
            , height fill
            , centerX
            ]
            [ row
                [ width fill
                , height fill
                , Font.color colourScheme.white
                , Font.semiBold
                ]
                [ column
                    [ width (fillPortion 2) ]
                    [ el
                        []
                        (html (rismLogo "#ffffff" 100))
                    ]
                , column
                    [ width (fillPortion 10)
                    ]
                    [ text "Tagline / Impressum" ]
                ]
            ]
        ]
