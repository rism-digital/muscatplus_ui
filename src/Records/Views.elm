module Records.Views exposing (..)

import Api.Records exposing (ApiResponse(..), Incipit, IncipitFormat(..), IncipitList, InstitutionBody, PersonBody, RecordResponse(..), RenderedIncipit(..), SourceBody)
import Element exposing (..)
import Element.Background as Background exposing (color)
import Element.Border as Border
import Element.Font as Font
import Html
import Language exposing (Language, extractLabelFromLanguageMap)
import Records.DataTypes exposing (Model, Msg)
import SvgParser
import UI.Layout exposing (layoutBody)
import UI.Style exposing (headingLG, headingMD, headingSM, headingXL, headingXXL, minMaxFillDesktop)


viewRecordBody : Model -> List (Html.Html Msg)
viewRecordBody model =
    let
        device =
            model.viewingDevice

        deviceView =
            case device.class of
                Phone ->
                    viewRecordContentMobile

                _ ->
                    viewRecordContentDesktop
    in
    layoutBody (deviceView model) device


viewRecordContentDesktop : Model -> Element Msg
viewRecordContentDesktop model =
    let
        content =
            case model.response of
                Loading ->
                    viewLoadingSpinner model

                Response apiResponse ->
                    case apiResponse of
                        SourceResponse sourcebody ->
                            viewSourceRecord sourcebody model.language

                        PersonResponse personbody ->
                            viewPersonRecord personbody model.language

                        InstitutionResponse institutionbody ->
                            viewInstitutionRecord institutionbody model.language

                ApiError ->
                    viewErrorMessage model
    in
    row
        [ width minMaxFillDesktop
        , height (fillPortion 15)
        , centerX
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , height (fillPortion 15)
                , alignLeft
                ]
                [ content ]
            ]
        ]


viewRecordContentMobile : Model -> Element Msg
viewRecordContentMobile model =
    row [] []


viewLoadingSpinner : Model -> Element Msg
viewLoadingSpinner model =
    row
        []
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , height fill
                ]
                [ el
                    [ centerX
                    , centerY
                    ]
                    (text "Loading")
                ]
            ]
        ]


viewErrorMessage : Model -> Element Msg
viewErrorMessage model =
    el [ centerX, centerY ] (text model.errorMessage)


viewSourceRecord : SourceBody -> Language -> Element Msg
viewSourceRecord body language =
    row
        [ alignTop ]
        [ column
            []
            [ row
                [ width fill
                , height (px 120)
                ]
                [ el
                    [ headingLG ]
                    (text (extractLabelFromLanguageMap language body.label))
                ]
            , row
                [ width fill
                , height (fillPortion 10)
                ]
                [ column
                    []
                    [ viewIncipitSection body language ]
                ]
            ]
        ]


viewIncipitSection : SourceBody -> Language -> Element Msg
viewIncipitSection body language =
    let
        incipitSection =
            case body.incipits of
                Just _ ->
                    viewIncipits body language

                Nothing ->
                    Element.none
    in
    row
        []
        [ column
            []
            [ incipitSection ]
        ]


viewIncipits : SourceBody -> Language -> Element Msg
viewIncipits source language =
    let
        incipitDisplay =
            case source.incipits of
                Just incipitList ->
                    viewIncipitList incipitList language

                Nothing ->
                    column [] [ Element.none ]
    in
    row []
        [ incipitDisplay ]


viewIncipitList : IncipitList -> Language -> Element Msg
viewIncipitList incipitlist language =
    row
        []
        [ column
            []
            [ row
                []
                [ column
                    [ headingMD ]
                    [ text (extractLabelFromLanguageMap language incipitlist.label) ]
                ]
            , row
                []
                [ column
                    []
                    (List.map (viewSingleIncipit language) incipitlist.incipits)
                ]
            ]
        ]


viewSingleIncipit : Language -> Incipit -> Element Msg
viewSingleIncipit language incipit =
    let
        renderedIncipit =
            case incipit.rendered of
                Just renderedIncipitList ->
                    viewRenderedIncipits renderedIncipitList

                Nothing ->
                    Element.none
    in
    row [ width fill, paddingXY 0 10, Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 } ]
        [ column
            []
            [ row
                []
                [ text (extractLabelFromLanguageMap language incipit.label) ]
            , row
                []
                [ renderedIncipit ]
            ]
        ]


viewRenderedIncipits : List RenderedIncipit -> Element Msg
viewRenderedIncipits incipitlist =
    let
        els =
            List.map
                (\rendered ->
                    case rendered of
                        RenderedIncipit RenderedSVG svgdata ->
                            viewSVGRenderedIncipit svgdata

                        _ ->
                            Element.none
                )
                incipitlist
    in
    row [] els


viewSVGRenderedIncipit : String -> Element Msg
viewSVGRenderedIncipit incipitData =
    let
        svgData =
            SvgParser.parse incipitData

        _ =
            Debug.log "SVG output" svgData

        svgResponse =
            case svgData of
                Ok html ->
                    Element.html html

                Err error ->
                    text "Could not parse SVG"
    in
    svgResponse


viewInstitutionRecord : InstitutionBody -> Language -> Element Msg
viewInstitutionRecord body language =
    column [] [ el [] (text (extractLabelFromLanguageMap language body.label)) ]


viewPersonRecord : PersonBody -> Language -> Element Msg
viewPersonRecord body language =
    column [ alignTop, width fill, height fill ]
        [ row [ width fill, height (fillPortion 2), centerY, Border.color (rgb255 193 125 65), Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 } ]
            [ el [ centerY, Font.size 24, Font.semiBold ] (text (extractLabelFromLanguageMap language body.label))
            ]
        , row [ width fill, height (fillPortion 1), centerY, Border.color (rgb255 255 198 110), Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 } ]
            [ el [ Font.size 14, paddingXY 10 10, Font.color (rgb255 255 255 255), Background.color (rgb255 193 125 65), height fill, centerY ] (text "Biographical Details")
            , el [ Font.size 14, paddingXY 10 10, Font.color (rgb255 255 255 255), Background.color (rgb255 193 125 65), height fill, centerY ] (text "Sources")
            , el [ Font.size 14, paddingXY 10 10, Font.color (rgb255 255 255 255), Background.color (rgb255 193 125 65), height fill, centerY ] (text "Secondary Literature")
            ]
        , row [ width fill, height (fillPortion 13), alignTop, paddingEach { bottom = 0, left = 0, right = 0, top = 20 } ]
            [ column []
                [ row [] []
                , row [] []
                ]
            ]
        ]
