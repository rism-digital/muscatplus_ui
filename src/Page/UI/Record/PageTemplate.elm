module Page.UI.Record.PageTemplate exposing
    ( externalLinkTemplate
    , isExternalLink
    , pageFooterTemplate
    , pageFullRecordTemplate
    , pageHeaderTemplate
    , pageHeaderTemplateNoToc
    )

import Config as C
import Element exposing (Element, above, alignBottom, alignLeft, alignRight, column, el, fill, height, htmlAttribute, link, newTabLink, none, padding, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Shared exposing (RecordHistory)
import Page.Route exposing (Route(..))
import Page.UI.Attributes exposing (headingSM, lineSpacing, linkColour)
import Page.UI.Components exposing (h1, h2)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (externalLinkSvg)
import Page.UI.Record.RecordHistory exposing (viewRecordHistory)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
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
            link
                [ linkColour
                ]
                { label = text (extractLabelFromLanguageMap language localTranslations.reportAnIssue)
                , url = "https://docs.google.com/forms/d/e/1FAIpQLScZ5kDwgmraT3oMaiAA3_FYaEl_s_XpQ-t932SzUfKa63SpMg/viewform?usp=pp_url&entry.1082206543=" ++ currentUrl
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
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 2 }
        , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
        , Background.color (colourScheme.cream |> convertColorToElementColor)
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
                [ muscatLinks
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
    ->
        { a
            | label : LanguageMap
            , sectionToc : String
        }
    -> Element msg
pageHeaderTemplate language header =
    row
        [ width fill
        , htmlAttribute (HA.id header.sectionToc)
        ]
        [ h2 language header.label ]


pageHeaderTemplateNoToc :
    Language
    ->
        { a
            | label : LanguageMap
        }
    -> Element msg
pageHeaderTemplateNoToc language header =
    row
        [ width fill
        ]
        [ h2 language header.label ]


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
                    [ headingSM
                    , Font.semiBold
                    ]
                    (text (extractLabelFromLanguageMap language langMap ++ ": "))
                , recordLink
                    [ linkColour ]
                    { label =
                        el
                            [ headingSM ]
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
                (externalLinkSvg colourScheme.slateGrey)
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
                    , link
                        [ linkColour ]
                        { label = text (extractLabelFromLanguageMap session.language localTranslations.muscatView)
                        , url = muscatUrl
                        }
                    , text " | "
                    , link
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
