module Page.UI.Keyboard exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, maximum, minimum, paddingXY, px, row, text, width)
import Element.Events exposing (onClick)
import Element.Input as Input
import Language exposing (Language)
import List.Extra as LE
import Page.UI.Images exposing (backspaceSvg)
import Page.UI.Keyboard.Keyboard exposing (blackKeyWidth, octaveConfig, renderKey, whiteKeyWidthScale)
import Page.UI.Keyboard.Model exposing (Clef(..), Keyboard(..), KeyboardConfig, KeyboardModel, KeyboardQuery)
import Page.UI.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.UI.Keyboard.PAE exposing (createPAENote)
import Page.UI.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.UI.Style exposing (colourScheme)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Incipits exposing (viewSVGRenderedIncipit)
import Request exposing (createSvgRequest, serverUrl)


type alias Model =
    KeyboardModel


type alias Msg =
    KeyboardMsg


init : Int -> ( Keyboard, Cmd Msg )
init numOctaves =
    let
        -- needs a config and a model instance
        model =
            initModel

        config =
            { numOctaves = numOctaves }
    in
    ( Keyboard model config, Cmd.none )


defaultKeyboardQuery : KeyboardQuery
defaultKeyboardQuery =
    { clef = G2
    , timeSignature = ""
    , keySignature = ""
    , noteData = Nothing
    }


initModel : Model
initModel =
    { query = defaultKeyboardQuery
    , notation = Nothing
    }


buildUpdateQuery : Maybe String -> Model -> ( Model, Cmd Msg )
buildUpdateQuery newNoteData model =
    let
        query =
            model.query

        newQuery =
            { query | noteData = newNoteData }

        newModel =
            { model | query = newQuery }

        queryParameters =
            buildNotationQueryParameters newQuery

        url =
            serverUrl [ "incipits/render" ] queryParameters

        cmd =
            createSvgRequest ServerRespondedWithRenderedNotation url
    in
    ( newModel, cmd )


buildNotationRequestQuery : KeyboardQuery -> Cmd Msg
buildNotationRequestQuery keyboardQuery =
    let
        keyboardQp =
            buildNotationQueryParameters keyboardQuery

        url =
            serverUrl [ "incipits/render" ] keyboardQp
    in
    createSvgRequest ServerRespondedWithRenderedNotation url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ServerRespondedWithRenderedNotation (Ok ( metadata, response )) ->
            ( { model | notation = Just response }, Cmd.none )

        ServerRespondedWithRenderedNotation (Err error) ->
            ( model, Cmd.none )

        UserClickedPianoKeyboardKey noteName octave ->
            let
                query =
                    model.query

                note =
                    createPAENote noteName octave

                noteData =
                    case query.noteData of
                        Just n ->
                            n ++ " " ++ note

                        Nothing ->
                            note
            in
            buildUpdateQuery (Just noteData) model

        UserClickedPianoKeyboardDeleteNote ->
            let
                query =
                    model.query

                noteData =
                    Maybe.map
                        (\n ->
                            String.split " " n
                                |> LE.init
                                |> Maybe.withDefault []
                                |> String.join " "
                        )
                        query.noteData
            in
            buildUpdateQuery noteData model

        ClientRequestedRenderedNotation ->
            let
                query =
                    model.query

                noteData =
                    query.noteData
            in
            buildUpdateQuery noteData model

        _ ->
            ( model, Cmd.none )


view : Language -> Keyboard -> Element KeyboardMsg
view language (Keyboard model config) =
    let
        numOctaves =
            config.numOctaves

        -- calculate the size of the div for the keyboard
        -- subtract 1 to account for the border overlap
        -- multiply by 7 for each white key
        octaveWidth =
            ((toFloat blackKeyWidth - 1) * whiteKeyWidthScale) * 7

        keyboardWidth =
            ceiling (octaveWidth * toFloat numOctaves)
    in
    row
        [ alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , height fill
                ]
                [ column
                    [ width fill
                    , height fill
                    ]
                    [ row
                        [ width (px keyboardWidth)
                        , height fill
                        ]
                        (List.repeat numOctaves octaveConfig
                            |> List.concat
                            |> List.indexedMap (renderKey UserClickedPianoKeyboardKey)
                        )
                    ]
                , column
                    [ alignTop
                    ]
                    [ row
                        [ width fill
                        , alignTop
                        ]
                        [ el
                            [ width (px 30)
                            , onClick UserClickedPianoKeyboardDeleteNote
                            ]
                            (backspaceSvg colourScheme.black)
                        ]
                    ]
                ]
            , row
                [ width (fill |> minimum 400 |> maximum 1000)
                , height (px 120)
                , paddingXY 0 10
                ]
                [ el
                    [ width fill
                    , height fill
                    ]
                    (viewMaybe viewSVGRenderedIncipit model.notation)
                ]
            ]
        ]
