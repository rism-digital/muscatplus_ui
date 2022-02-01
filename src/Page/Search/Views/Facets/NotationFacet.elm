module Page.Search.Views.Facets.NotationFacet exposing (..)

import Element exposing (Element, column, fill, height, htmlAttribute, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (headingSM)
import Page.UI.Keyboard as Keyboard
import Page.UI.Keyboard.Model exposing (Keyboard(..))
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


type alias NotationFacetConfig msg =
    { language : Language
    , keyboardFacet : Keyboard.Model
    , userInteractedWithKeyboardMsg : Keyboard.Msg -> msg
    , userClickedClearKeyboardQueryMsg : msg
    , userClickedPianoKeyboardSearchSubmitMsg : msg
    }


viewKeyboardControl : NotationFacetConfig msg -> Element msg
viewKeyboardControl config =
    let
        keyboardConfig =
            { numOctaves = 3 }

        keyboardQuery =
            .query config.keyboardFacet

        queryLen =
            Maybe.withDefault [] keyboardQuery.noteData
                |> List.length

        cursor =
            if queryLen < 4 then
                "not-allowed"

            else
                "pointer"

        ( buttonMsg, buttonColor, buttonBorder ) =
            if queryLen < 4 then
                ( Nothing
                , colourScheme.darkGrey |> convertColorToElementColor
                , colourScheme.slateGrey |> convertColorToElementColor
                )

            else
                ( Just config.userClickedPianoKeyboardSearchSubmitMsg
                , colourScheme.darkBlue |> convertColorToElementColor
                , colourScheme.darkBlue |> convertColorToElementColor
                )
    in
    row
        []
        [ column
            []
            [ row []
                [ Keyboard.view config.language (Keyboard config.keyboardFacet keyboardConfig)
                    |> Element.map config.userInteractedWithKeyboardMsg
                ]
            , row
                [ spacing 10 ]
                [ Input.button
                    [ Border.widthEach { bottom = 1, top = 1, left = 0, right = 1 }
                    , Border.rounded 5
                    , Border.color buttonBorder
                    , Background.color buttonColor
                    , paddingXY 10 10
                    , height (px 50)
                    , width fill
                    , Font.center
                    , Font.color (colourScheme.white |> convertColorToElementColor)
                    , headingSM
                    , htmlAttribute (HA.style "cursor" cursor)
                    ]
                    { onPress = buttonMsg
                    , label = text "Search"
                    }
                , Input.button
                    [ Border.widthEach { bottom = 1, top = 1, left = 0, right = 1 }
                    , Border.rounded 5
                    , Border.color (colourScheme.darkBlue |> convertColorToElementColor)
                    , Background.color (colourScheme.darkBlue |> convertColorToElementColor)
                    , paddingXY 10 10
                    , height (px 50)
                    , width fill
                    , Font.center
                    , Font.color (colourScheme.white |> convertColorToElementColor)
                    , headingSM
                    , htmlAttribute (HA.style "cursor" "pointer")
                    ]
                    { onPress = Just config.userClickedClearKeyboardQueryMsg
                    , label = text "Clear"
                    }
                ]
            ]
        ]
