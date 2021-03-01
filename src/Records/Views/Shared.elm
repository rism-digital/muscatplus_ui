module Records.Views.Shared exposing (..)

import Api.Records exposing (ApiResponse(..), LabelValue, RecordResponse(..))
import Element exposing (DeviceClass(..), Element, alignLeft, alignTop, centerX, centerY, column, el, fill, fillPortion, height, padding, paddingXY, row, spacing, spacingXY, text, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Records.DataTypes exposing (Model, Msg)
import UI.Components exposing (label, value)
import UI.Style exposing (bodyRegular, bodySM)


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


viewSummaryField : List LabelValue -> Language -> Element msg
viewSummaryField field language =
    row
        [ width fill ]
        [ column
            [ width fill ]
            (List.map
                (\f ->
                    row
                        [ width fill, paddingXY 0 10 ]
                        [ el
                            [ width (fillPortion 4), alignTop ]
                            (label language f.label)
                        , el
                            [ width (fillPortion 8), alignTop ]
                            (value language f.value)
                        ]
                )
                field
            )
        ]
