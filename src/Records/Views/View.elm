module Records.Views.View exposing (..)

import Api.Records exposing (ApiResponse(..), RecordResponse(..))
import Browser
import Element exposing (DeviceClass(..), Element, alignLeft, centerX, column, fill, fillPortion, height, row, width)
import Html
import Language exposing (languageOptions, languageOptionsForDisplay)
import Records.DataTypes exposing (Model, Msg(..))
import Records.Views.Institution exposing (viewInstitutionRecord)
import Records.Views.Person exposing (viewPersonRecord)
import Records.Views.Shared exposing (viewErrorMessage, viewLoadingSpinner)
import Records.Views.Source exposing (viewSourceRecord)
import UI.Layout exposing (layoutBody)
import UI.Style exposing (minMaxFillDesktop)


view : Model -> Browser.Document Msg
view model =
    { title = "Hello Records!"
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
    in
    layoutBody message langOptions (deviceView model) device


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
