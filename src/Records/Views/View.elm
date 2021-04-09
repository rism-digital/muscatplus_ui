module Records.Views.View exposing (..)

import Browser
import Element exposing (DeviceClass(..), Element, alignLeft, centerX, column, fill, fillPortion, height, row, width)
import Html
import Records.DataTypes exposing (ApiResponse(..), Model, Msg(..), RecordResponse(..))
import Records.Views.Festival exposing (viewFestivalRecord)
import Records.Views.Institution exposing (viewInstitutionRecord)
import Records.Views.Loading exposing (viewRecordLoading)
import Records.Views.Person exposing (viewPersonRecord)
import Records.Views.Place exposing (viewPlaceRecord)
import Records.Views.Shared exposing (viewErrorMessage, viewLoadingSpinner)
import Records.Views.Source exposing (viewSourceRecord)
import Shared.Language exposing (languageOptionsForDisplay)
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
