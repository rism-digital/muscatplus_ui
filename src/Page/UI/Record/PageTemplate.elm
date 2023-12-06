module Page.UI.Record.PageTemplate exposing
    ( externalLinkTemplate
    , isExternalLink
    , pageFooterTemplate
    , pageFullRecordTemplate
    , pageHeaderTemplate
    , pageHeaderTemplateNoToc
    , pageLinkTemplate
    , subHeaderTemplate
    )

import Config as C
import Element exposing (Attribute, Element, above, alignBottom, alignLeft, alignRight, centerY, column, el, fill, height, htmlAttribute, link, newTabLink, none, padding, px, row, shrink, spacing, spacingXY, text, width)
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Shared exposing (RecordHistory)
import Page.Route exposing (Route(..))
import Page.UI.Attributes exposing (headingLG, lineSpacing, linkColour, minimalDropShadow)
import Page.UI.Components exposing (h1, h2s)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (externalLinkSvg)
import Page.UI.Record.RecordHistory exposing (viewRecordHistory)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)
import Session exposing (Session)
import Url


pageFooterTemplate : Session -> Language -> { a | id : String, recordHistory : RecordHistory } -> Element msg
pageFooterTemplate session language footer =
    let
        currentUrl =
            Url.toString session.url
                |> String.replace "#" "%23"

        feedbackLink =
            newTabLink
                [ linkColour
                ]
                { label = text (extractLabelFromLanguageMap language localTranslations.reportAnIssue)
                , url = "https://docs.google.com/forms/d/e/1FAIpQLScZ5kDwgmraT3oMaiAA3_FYaEl_s_XpQ-t932SzUfKa63SpMg/viewform?usp=pp_url&entry.1082206543=" ++ currentUrl
                }

        aperoLinks =
            newTabLink
                [ linkColour ]
                { label = text "API Viewer"
                , url = "/apero/?url=" ++ currentUrl
                }

        muscatLinks =
            if session.showMuscatLinks then
                viewMuscatLinks session

            else
                none
    in
    row
        [ width fill
        , padding 20
        , alignBottom
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 1 }
        , minimalDropShadow
        , Border.color colourScheme.darkBlue
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ pageUriTemplate language footer
            , row
                [ width fill
                , alignLeft
                , spacing lineSpacing
                ]
                [ aperoLinks
                , muscatLinks
                , feedbackLink
                ]
            ]
        , column
            [ width fill
            , alignRight
            , spacing lineSpacing
            ]
            [ viewRecordHistory language footer.recordHistory
            ]
        ]


pageHeaderTemplate :
    Language
    -> Maybe (Element msg)
    ->
        { a
            | label : LanguageMap
            , sectionToc : String
        }
    -> Element msg
pageHeaderTemplate language icon header =
    headerTmpl
        { body = header
        , extraAttrs =
            [ htmlAttribute (HA.id header.sectionToc)
            ]
        , hLevel = h1 language
        , icon = icon
        }


pageHeaderTemplateNoToc :
    Language
    -> Maybe (Element msg)
    ->
        { a
            | label : LanguageMap
        }
    -> Element msg
pageHeaderTemplateNoToc language icon header =
    headerTmpl
        { body = header
        , extraAttrs = []
        , hLevel = h1 language
        , icon = icon
        }


subHeaderTemplate :
    Language
    -> Maybe (Element msg)
    -> { a | label : LanguageMap }
    -> Element msg
subHeaderTemplate language icon header =
    headerTmpl
        { body = header
        , extraAttrs = []
        , hLevel = h2s language
        , icon = icon
        }


headerTmpl :
    { body : { a | label : LanguageMap }
    , extraAttrs : List (Attribute msg)
    , hLevel : LanguageMap -> Element msg
    , icon : Maybe (Element msg)
    }
    -> Element msg
headerTmpl cfg =
    row
        (width fill
            :: spacingXY 10 5
            :: centerY
            --:: clip
            :: cfg.extraAttrs
        )
        [ viewMaybe identity cfg.icon
        , cfg.hLevel (.label cfg.body)
        ]


isExternalLink : String -> Bool
isExternalLink url =
    String.startsWith C.serverUrl url
        |> not


pageLinkTemplate : Language -> LanguageMap -> { a | id : String } -> Element msg
pageLinkTemplate language langMap body =
    let
        recordLink =
            if isExternalLink body.id then
                newTabLink

            else
                link
    in
    row
        [ width fill
        , alignLeft
        , spacing 5
        ]
        [ column
            [ width shrink ]
            [ row
                [ width fill ]
                [ el
                    [ headingLG
                    , Font.semiBold
                    ]
                    (text (extractLabelFromLanguageMap language langMap ++ ": "))
                , recordLink
                    [ linkColour ]
                    { label =
                        el
                            [ headingLG ]
                            (text body.id)
                    , url = body.id
                    }
                ]
            ]
        , externalLinkTemplate body.id
        ]


externalLinkTemplate : String -> Element msg
externalLinkTemplate url =
    let
        externalImg =
            el
                [ width (px 12)
                , height (px 12)
                , tooltip above
                    -- TODO: Translate
                    (el tooltipStyle (text "External link"))
                ]
                (externalLinkSvg colourScheme.midGrey)
    in
    isExternalLink url
        |> viewIf externalImg


pageFullRecordTemplate : Language -> { a | id : String } -> Element msg
pageFullRecordTemplate language body =
    pageLinkTemplate language localTranslations.fullRecord body


pageUriTemplate : Language -> { a | id : String } -> Element msg
pageUriTemplate language body =
    pageLinkTemplate language localTranslations.recordURI body


viewMuscatLinks : Session -> Element msg
viewMuscatLinks session =
    let
        linkTmpl muscatUrl =
            column
                [ alignLeft
                , spacing lineSpacing
                ]
                [ row
                    []
                    [ text "Muscat: "
                    , newTabLink
                        [ linkColour ]
                        { label = text (extractLabelFromLanguageMap session.language localTranslations.muscatView)
                        , url = muscatUrl
                        }
                    , text " | "
                    , newTabLink
                        [ linkColour ]
                        { label = text (extractLabelFromLanguageMap session.language localTranslations.muscatEdit)
                        , url = muscatUrl ++ "/edit"
                        }
                    ]
                ]
    in
    case session.route of
        SourcePageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "sources/" ++ String.fromInt id)

        SourceContentsPageRoute id _ ->
            linkTmpl (C.muscatLinkBase ++ "sources/" ++ String.fromInt id)

        PersonPageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "people/" ++ String.fromInt id)

        PersonSourcePageRoute id _ ->
            linkTmpl (C.muscatLinkBase ++ "people/" ++ String.fromInt id)

        InstitutionPageRoute id ->
            linkTmpl (C.muscatLinkBase ++ "institutions/" ++ String.fromInt id)

        InstitutionSourcePageRoute id _ ->
            linkTmpl (C.muscatLinkBase ++ "institutions/" ++ String.fromInt id)

        _ ->
            none
