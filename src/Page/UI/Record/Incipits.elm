module Page.UI.Record.Incipits exposing (viewIncipit, viewIncipitsSection, viewRenderedIncipits)

import Element exposing (Attribute, Element, alignLeft, alignTop, centerY, column, el, fill, height, htmlAttribute, link, maximum, minimum, none, padding, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import List.Extra as LE
import Page.RecordTypes.Incipit exposing (EncodedIncipit(..), IncipitBody, IncipitFormat(..), PAEEncodedData, RenderedIncipit(..))
import Page.RecordTypes.Source exposing (IncipitsSectionBody)
import Page.UI.Attributes exposing (bodySM, headingLG, lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe, viewSVGRenderedIncipit)
import Page.UI.Images exposing (fileDownloadSvg, searchSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Request exposing (serverUrl)
import Url.Builder


splitWorkNumFromId : String -> String
splitWorkNumFromId incipitId =
    String.split "/" incipitId
        |> LE.last
        |> Maybe.withDefault "1.1.1"


viewIncipit : Bool -> Language -> IncipitBody -> Element msg
viewIncipit suppressTitle language incipit =
    let
        title =
            if suppressTitle then
                none

            else
                row
                    [ width fill
                    , spacing 5
                    ]
                    [ el
                        [ headingLG
                        , Font.medium
                        ]
                        (text (extractLabelFromLanguageMap language incipit.label))
                    ]
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
                [ width fill ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , HA.id ("incipit-" ++ splitWorkNumFromId incipit.id) |> htmlAttribute
                    ]
                    [ viewMaybe (viewSummaryField language) incipit.summary
                    , row
                        [ width fill ]
                        [ column
                            [ width fill
                            , spacing 0
                            ]
                            [ viewMaybe viewRenderedIncipits incipit.rendered
                            , viewMaybe (viewLaunchNewIncipitSearch language) incipit.encodings
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewIncipitsSection : Language -> IncipitsSectionBody -> Element msg
viewIncipitsSection language incipSection =
    List.map (viewIncipit False language) incipSection.items
        |> sectionTemplate language incipSection


viewLaunchNewIncipitSearch : Language -> List EncodedIncipit -> Element msg
viewLaunchNewIncipitSearch language incipits =
    row
        [ width fill
        , spacing 10
        ]
        (List.map
            (\encoded ->
                case encoded of
                    PAEEncoding label paeData ->
                        viewPAESearchLink language label paeData

                    MEIEncoding label url ->
                        viewMEIDownloadLink language label url
            )
            incipits
        )


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
        , Border.width 1
        , Border.color (colourScheme.white |> convertColorToElementColor)
        , padding 4
        , Background.color (colourScheme.lightBlue |> convertColorToElementColor)
        , bodySM
        , Font.color (colourScheme.white |> convertColorToElementColor)
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
        { icon = fileDownloadSvg colourScheme.white
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
        { icon = searchSvg colourScheme.white
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
        , Background.color (colourScheme.white |> convertColorToElementColor)
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
