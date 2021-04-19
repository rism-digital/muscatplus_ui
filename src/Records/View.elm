module Records.View exposing (..)

import Browser
import DataTypes exposing (ApiResponse(..), Model, Msg(..), ServerResponse(..))
import Element exposing (DeviceClass(..), Element, alignLeft, centerX, column, fill, fillPortion, height, row, width)
import Html
import Language exposing (languageOptionsForDisplay)
import Records.Festival exposing (viewFestivalRecord)
import Records.Institution exposing (viewInstitutionRecord)
import Records.Loading exposing (viewRecordLoading)
import Records.Person exposing (viewPersonRecord)
import Records.Place exposing (viewPlaceRecord)
import Records.Shared exposing (viewErrorMessage, viewLoadingSpinner)
import Records.Source exposing (viewSourceRecord)
import UI.Layout exposing (layoutBody)
import UI.Style exposing (minMaxFillDesktop)


view : Model -> Browser.Document Msg
view model =
    { title = "Record View"
    , body = viewRecordBody model
    }


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

        message =
            LanguageSelectChanged

        langOptions =
            languageOptionsForDisplay

        currentLanguage =
            model.language
    in
    layoutBody message langOptions (deviceView model) device currentLanguage


viewRecordContentDesktop : Model -> Element Msg
viewRecordContentDesktop model =
    let
        content =
            case model.response of
                Loading ->
                    viewRecordLoading

                Response apiResponse ->
                    case apiResponse of
                        SourceResponse sourcebody ->
                            viewSourceRecord sourcebody model.language

                        PersonResponse personbody ->
                            viewPersonRecord personbody model.language

                        InstitutionResponse institutionbody ->
                            viewInstitutionRecord institutionbody model.language

                        PlaceResponse placebody ->
                            viewPlaceRecord placebody model.language

                        FestivalResponse festivalbody ->
                            viewFestivalRecord festivalbody model.language

                        SearchResponse _ ->
                            viewErrorMessage model

                _ ->
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
