module Page.UI.Record.Incipits exposing (IncipitDisplayConfig, IncipitSectionConfig, viewIncipit, viewIncipitsSection, viewRenderedIncipits)

import Element exposing (Element, alignLeft, alignTop, centerY, column, el, fill, fillPortion, height, htmlAttribute, link, maximum, minimum, none, padding, paddingEach, paddingXY, paragraph, pointer, px, row, spacing, spacingXY, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.RecordTypes.Incipit exposing (EncodedIncipit(..), IncipitBody, IncipitFormat(..), IncipitsSectionBody, PAEEncodedData, RenderedIncipit(..))
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (bodyRegular, headingMD, lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (h3, h3s)
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
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }


type alias IncipitSectionConfig msg =
    { language : Language
    , infoToggleMsg : String -> msg
    , expandedIncipits : Set String
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }


viewIncipitsSection : IncipitSectionConfig msg -> IncipitsSectionBody -> Element msg
viewIncipitsSection sectionCfg sectionBody =
    List.map
        (\body ->
            viewIncipit
                { suppressTitle = False
                , language = sectionCfg.language
                , infoIsExpanded = Set.member body.id sectionCfg.expandedIncipits
                , infoToggleMsg = sectionCfg.infoToggleMsg
                , summaryFormatter = sectionCfg.summaryFormatter
                }
                body
        )
        sectionBody.items
        |> sectionTemplate sectionCfg.language sectionBody


viewIncipit : IncipitDisplayConfig msg -> IncipitBody -> Element msg
viewIncipit cfg incipit =
    row
        (width fill :: sectionBorderStyles)
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ viewIf
                (row
                    [ width fill
                    , spacing 5
                    ]
                    [ h3s cfg.language incipit.label
                    ]
                )
                (not cfg.suppressTitle)
            , row
                [ width fill
                , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.lightGrey
                , paddingXY lineSpacing 10
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , HA.id incipit.sectionToc |> htmlAttribute
                    ]
                    [ viewMaybe viewRenderedIncipits incipit.rendered
                    , viewMaybe (cfg.summaryFormatter cfg.language) incipit.summary
                    , viewMaybe
                        (viewIncipitExtraInfo
                            { ident = incipit.id
                            , infoToggleMsg = cfg.infoToggleMsg
                            , isExpanded = cfg.infoIsExpanded
                            , language = cfg.language
                            , renderings = incipit.rendered
                            }
                        )
                        incipit.encodings
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
            viewIf (viewAdditionalIncipitInfoAndTools cfg.language cfg.renderings encodings) cfg.isExpanded
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
                , headingMD
                ]
                [ el
                    [ width (px 20)
                    , height (px 20)
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
    Maybe.map
        (\renderedList ->
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
        )
        renderings
        |> Maybe.withDefault []


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
viewMEIDownloadLink language _ url =
    linkTmpl
        { icon = fileDownloadSvg colourScheme.lightBlue
        , label = localTranslations.downloadMEI
        , language = language
        , url = url
        }


viewPAESearchLink : Language -> LanguageMap -> PAEEncodedData -> Element msg
viewPAESearchLink language _ data =
    let
        clefQueryParam =
            ME.unwrap [] (\cl -> [ Url.Builder.string "ic" cl ]) data.clef

        keySigQueryParam =
            ME.unwrap [] (\ks -> [ Url.Builder.string "ik" ks ]) data.keysig

        modeQueryParam =
            Url.Builder.string "mode" "incipits"

        noteQueryParam =
            Url.Builder.string "n" data.data

        timeSigQueryParam =
            ME.unwrap [] (\ts -> [ Url.Builder.string "it" ts ]) data.timesig

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
        [ width fill
        , paddingEach { bottom = 10, left = 0, right = 0, top = 0 }
        ]
        [ column
            [ width fill
            , spacing 0
            ]
            [ row
                [ width (fill |> minimum 500 |> maximum 800)
                , htmlAttribute (HA.class "svg-rendered-incipit")
                , Background.color colourScheme.transparent
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
            ]
        ]


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
