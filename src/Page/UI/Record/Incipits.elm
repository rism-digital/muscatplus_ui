module Page.UI.Record.Incipits exposing (IncipitDisplayConfig, IncipitSectionConfig, viewIncipit, viewIncipitsSection, viewRenderedIncipits)

import Element exposing (Element, alignLeft, alignTop, centerY, column, el, fill, fillPortion, height, htmlAttribute, link, maximum, minimum, none, padding, paddingXY, paragraph, pointer, px, row, spacing, spacingXY, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Page.RecordTypes.Incipit exposing (EncodedIncipit(..), IncipitBody, IncipitFormat(..), PAEEncodedData, RenderedIncipit(..))
import Page.RecordTypes.Source exposing (IncipitsSectionBody)
import Page.UI.Attributes exposing (bodyRegular, headingLG, lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (h2, h3, viewSummaryField)
import Page.UI.Helpers exposing (viewIf, viewMaybe, viewSVGRenderedIncipit)
import Page.UI.Images exposing (caretCircleDownSvg, caretCircleRightSvg, fileDownloadSvg, searchSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Request exposing (serverUrl)
import Set exposing (Set)
import Url.Builder


type alias IncipitDisplayConfig msg =
    { suppressTitle : Bool
    , language : Language
    , infoIsExpanded : Bool
    , infoToggleMsg : String -> msg
    }


type alias IncipitSectionConfig msg =
    { language : Language
    , infoToggleMsg : String -> msg
    , expandedIncipits : Set String
    }


splitWorkNumFromId : String -> String
splitWorkNumFromId incipitId =
    String.split "/" incipitId
        |> LE.last
        |> Maybe.withDefault "1.1.1"


viewIncipit : IncipitDisplayConfig msg -> IncipitBody -> Element msg
viewIncipit cfg incipit =
    let
        title =
            viewIf
                (row
                    [ width fill
                    , spacing 5
                    ]
                    [ h2 cfg.language incipit.label
                    ]
                )
                (not cfg.suppressTitle)
    in
    row
        (width fill :: sectionBorderStyles)
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            , alignTop
            ]
            [ title
            , row
                [ width fill
                , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.lightGrey
                , paddingXY 0 10
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , HA.id ("incipit-" ++ splitWorkNumFromId incipit.id) |> htmlAttribute
                    ]
                    [ row
                        [ width fill ]
                        [ column
                            [ width fill
                            , spacing 0
                            ]
                            [ viewMaybe viewRenderedIncipits incipit.rendered ]
                        ]
                    , viewMaybe (viewSummaryField cfg.language) incipit.summary
                    , row
                        [ width fill
                        , paddingXY 0 10
                        ]
                        [ column
                            [ width fill
                            , spacing 0
                            ]
                            [ viewMaybe
                                (viewIncipitExtraInfo
                                    { ident = incipit.id
                                    , infoToggleMsg = cfg.infoToggleMsg
                                    , isExpanded = cfg.infoIsExpanded
                                    , language = cfg.language
                                    , renderings = incipit.rendered
                                    }
                                )
                                incipit.encodings

                            --, viewMaybe (viewLaunchNewIncipitSearch cfg.language) incipit.encodings
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewIncipitExtraInfo :
    { ident : String
    , infoToggleMsg : String -> msg
    , isExpanded : Bool
    , language : Language
    , renderings : Maybe (List RenderedIncipit)
    }
    -> List EncodedIncipit
    -> Element msg
viewIncipitExtraInfo cfg encodings =
    let
        toggleIcon =
            if cfg.isExpanded then
                caretCircleDownSvg colourScheme.lightBlue

            else
                caretCircleRightSvg colourScheme.lightBlue

        panelBody =
            if cfg.isExpanded then
                viewAdditionalIncipitInfoAndTools cfg.language cfg.renderings encodings

            else
                none
    in
    row
        [ width fill
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , Font.color colourScheme.black
                , Border.dotted
                , paddingXY 0 8
                , spacing 5
                , Font.medium
                , headingLG
                ]
                [ el
                    [ width (px 16)
                    , height (px 16)
                    , centerY
                    , pointer
                    , onClick (cfg.infoToggleMsg cfg.ident)
                    ]
                    toggleIcon
                , el
                    [ centerY
                    , pointer
                    , onClick (cfg.infoToggleMsg cfg.ident)
                    ]
                    (text "Incipit options")
                ]
            , panelBody
            ]
        ]


viewIncipitsSection : IncipitSectionConfig msg -> IncipitsSectionBody -> Element msg
viewIncipitsSection sectionCfg sectionBody =
    List.map
        (\body ->
            viewIncipit
                { suppressTitle = False
                , language = sectionCfg.language
                , infoIsExpanded = Set.member body.id sectionCfg.expandedIncipits
                , infoToggleMsg = sectionCfg.infoToggleMsg
                }
                body
        )
        sectionBody.items
        |> sectionTemplate sectionCfg.language sectionBody


viewAdditionalIncipitInfoAndTools : Language -> Maybe (List RenderedIncipit) -> List EncodedIncipit -> Element msg
viewAdditionalIncipitInfoAndTools language renderings incipits =
    row
        [ width fill
        , spacing 10
        ]
        [ column
            [ width (fillPortion 1)
            , alignTop
            , spacing 5
            ]
            (viewIncipitToolLinks language renderings incipits)
        , column
            [ width (fillPortion 3)
            , alignTop
            ]
            (viewPAECodeBlock language incipits)
        ]


viewIncipitToolLinks : Language -> Maybe (List RenderedIncipit) -> List EncodedIncipit -> List (Element msg)
viewIncipitToolLinks language rendered incipits =
    let
        encodingLinks =
            List.map
                (\encoded ->
                    case encoded of
                        PAEEncoding label paeData ->
                            viewPAESearchLink language label paeData

                        MEIEncoding label meiUrl ->
                            viewMEIDownloadLink language label meiUrl
                )
                incipits

        renderingLinks =
            viewRenderedIncipitToolLinks language rendered
    in
    List.concat [ encodingLinks, renderingLinks ]


viewRenderedIncipitToolLinks : Language -> Maybe (List RenderedIncipit) -> List (Element msg)
viewRenderedIncipitToolLinks language renderings =
    case renderings of
        Just renderedList ->
            List.map
                (\r ->
                    case r of
                        RenderedIncipit RenderedPNG url ->
                            linkTmpl
                                { icon = fileDownloadSvg colourScheme.lightBlue
                                , label = localTranslations.downloadPNG
                                , language = language
                                , url = url
                                }

                        _ ->
                            none
                )
                renderedList

        Nothing ->
            []


viewPAECodeBlock : Language -> List EncodedIncipit -> List (Element msg)
viewPAECodeBlock language incipits =
    List.map
        (\encoded ->
            case encoded of
                PAEEncoding label paeData ->
                    viewPAEData language label paeData

                MEIEncoding _ _ ->
                    none
        )
        incipits


linkTmpl :
    { icon : Element msg
    , label : LanguageMap
    , language : Language
    , url : String
    }
    -> Element msg
linkTmpl cfg =
    link
        [ centerY
        , alignLeft
        , linkColour
        , padding 4
        , bodyRegular
        ]
        { label =
            row
                [ spacing 5
                ]
                [ el
                    [ width (px 15)
                    , height (px 15)
                    , centerY
                    ]
                    cfg.icon
                , text (extractLabelFromLanguageMap cfg.language cfg.label)
                ]
        , url = cfg.url
        }


viewMEIDownloadLink : Language -> LanguageMap -> String -> Element msg
viewMEIDownloadLink language label url =
    linkTmpl
        { icon = fileDownloadSvg colourScheme.lightBlue
        , label = localTranslations.downloadMEI
        , language = language
        , url = url
        }


viewPAESearchLink : Language -> LanguageMap -> PAEEncodedData -> Element msg
viewPAESearchLink language label data =
    let
        clefQueryParam =
            case data.clef of
                Just cl ->
                    [ Url.Builder.string "ic" cl ]

                Nothing ->
                    []

        keySigQueryParam =
            case data.keysig of
                Just ks ->
                    [ Url.Builder.string "ik" ks ]

                Nothing ->
                    []

        modeQueryParam =
            Url.Builder.string "mode" "incipits"

        noteQueryParam =
            Url.Builder.string "n" data.data

        timeSigQueryParam =
            case data.timesig of
                Just ts ->
                    [ Url.Builder.string "it" ts ]

                Nothing ->
                    []

        searchUrl =
            serverUrl
                [ "search" ]
                (noteQueryParam :: modeQueryParam :: keySigQueryParam ++ clefQueryParam ++ timeSigQueryParam)
    in
    linkTmpl
        { icon = searchSvg colourScheme.lightBlue
        , label = localTranslations.newSearchWithIncipit
        , language = language
        , url = searchUrl
        }


{-|

    An incipit can be 'rendered' in at least two ways: SVG or MIDI. This function
    takes a mixed list of binary incipit data and chooses the function for rendering
    the data.

    At present, only SVG incipits are rendered. TODO: Add MIDI rendering.

-}
viewRenderedIncipits : List RenderedIncipit -> Element msg
viewRenderedIncipits incipits =
    row
        [ width (fill |> minimum 500 |> maximum 1000)
        , htmlAttribute (HA.class "search-results-rendered-incipit")
        , Background.color colourScheme.white
        ]
        (List.map
            (\rendered ->
                case rendered of
                    RenderedIncipit RenderedSVG svgdata ->
                        viewSVGRenderedIncipit svgdata

                    _ ->
                        none
            )
            incipits
        )


viewPAEData : Language -> LanguageMap -> PAEEncodedData -> Element msg
viewPAEData language label pae =
    let
        clefRow =
            viewMaybe (viewPAERow "@clef") pae.clef

        dataRow =
            viewPAERow "@data" pae.data

        keyModeRow =
            viewMaybe (viewPAERow "@key") pae.key

        keysigRow =
            viewMaybe (viewPAERow "@keysig") pae.keysig

        timesigRow =
            viewMaybe (viewPAERow "@timesig") pae.timesig
    in
    row
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , alignTop
                ]
                [ h3 language label ]
            , row
                (width (px 600)
                    :: height fill
                    :: alignTop
                    :: sectionBorderStyles
                )
                [ column
                    [ width fill
                    , alignTop
                    , Font.family [ Font.monospace ]
                    , bodyRegular
                    , spacing 5
                    ]
                    [ clefRow
                    , keysigRow
                    , timesigRow
                    , keyModeRow
                    , dataRow
                    ]
                ]
            ]
        ]


viewPAERow : String -> String -> Element msg
viewPAERow key value =
    wrappedRow
        [ width fill
        , spacingXY 5 0
        , alignTop
        ]
        [ el
            [ Font.semiBold
            , alignTop
            ]
            (text (key ++ ":"))
        , paragraph [ alignTop ] [ text value ]
        ]
