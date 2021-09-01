module Page.UI.Keyboard exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, el, fill, fillPortion, maximum, minimum, paddingXY, px, row, text, width)
import Element.Events exposing (onClick)
import Element.Input as Input
import List.Extra as LE
import Page.Query exposing (buildNotationQueryParameters)
import Page.UI.Images exposing (backspaceSvg)
import Page.UI.Keyboard.Keyboard exposing (blackKeyWidth, octaveConfig, renderKey, whiteKeyWidthScale)
import Page.UI.Keyboard.Model exposing (Clef(..), Keyboard(..), KeyboardConfig, KeyboardModel, clefStringMap)
import Page.UI.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.UI.Keyboard.PAE exposing (createPAENote)
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


initModel : Model
initModel =
    { query =
        { clef = G2
        , timeSignature = "4/4"
        , keySignature = ""
        , noteData = Nothing
        }
    , notation = Nothing
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ServerRespondedWithRenderedNotation (Ok response) ->
            ( { model | notation = Just response }, Cmd.none )

        ServerRespondedWithRenderedNotation (Err error) ->
            let
                _ =
                    Debug.log "Error in server notation response" ""
            in
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

                newKeyboardQuery =
                    { query | noteData = Just noteData }

                newModel =
                    { model | query = newKeyboardQuery }

                queryParameters =
                    buildNotationQueryParameters newKeyboardQuery

                url =
                    serverUrl [ "incipits/render" ] queryParameters

                _ =
                    Debug.log "Server url" url

                cmd =
                    createSvgRequest ServerRespondedWithRenderedNotation url
            in
            ( newModel, cmd )

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

                newQuery =
                    { query | noteData = noteData }

                newModel =
                    { model | query = newQuery }

                queryParameters =
                    buildNotationQueryParameters newQuery

                url =
                    serverUrl [ "incipits/render" ] queryParameters

                _ =
                    Debug.log "Server url" url

                cmd =
                    createSvgRequest ServerRespondedWithRenderedNotation url
            in
            ( newModel, cmd )

        _ ->
            ( model, Cmd.none )



--Msg.UserClickedPianoKeyboardKey noteName octave ->
--            let
--                activeSearch =
--                    model.activeSearch
--
--                activeQuery =
--                    activeSearch.query
--
--                note =
--                    createPAENote noteName octave
--
--                keyboardQuery =
--                    activeQuery.keyboardQuery
--
--                noteData =
--                    case keyboardQuery.noteData of
--                        Just n ->
--                            n ++ " " ++ note
--
--                        Nothing ->
--                            note
--
--                newKeyboardQuery =
--                    { keyboardQuery | noteData = Just noteData }
--
--                newQuery =
--                    { activeQuery | keyboardQuery = newKeyboardQuery }
--
--                newSearch =
--                    { activeSearch | query = newQuery }
--
--                newModel =
--                    { model | activeSearch = newSearch }
--
--                queryParameters =
--                    buildNotationQueryParameters newKeyboardQuery
--
--                url =
--                    serverUrl [ "incipits/render" ] queryParameters
--
--                _ =
--                    Debug.log "Server url" url
--
--                cmd =
--                    createSvgRequest Msg.ServerRespondedWithRenderedNotation url
--            in
--            ( newModel, cmd )
--
--        Msg.UserClickedPianoKeyboardDeleteNote ->
--            let
--                activeSearch =
--                    model.activeSearch
--
--                activeQuery =
--                    activeSearch.query
--
--                keyboardQuery =
--                    activeQuery.keyboardQuery
--
--                noteData =
--                    case keyboardQuery.noteData of
--                        Just n ->
--                            Just
--                                (String.split " " n
--                                    |> LE.init
--                                    |> Maybe.withDefault []
--                                    |> String.join " "
--                                )
--
--                        Nothing ->
--                            Nothing
--
--                newKeyboardQuery =
--                    { keyboardQuery | noteData = noteData }
--
--                newQuery =
--                    { activeQuery | keyboardQuery = newKeyboardQuery }
--
--                newSearch =
--                    { activeSearch | query = newQuery }
--            in
--            ( { model | activeSearch = newSearch }, Cmd.none )
--
--        Msg.UserClickedPianoKeyboardChangeClef ->
--            ( model, Cmd.none )
--
--        Msg.UserClickedPianoKeyboardChangeKeySignature ->
--            ( model, Cmd.none )
--
--        Msg.UserClickedPianoKeyboardChangeTimeSignature ->
--            ( model, Cmd.none )


view : Keyboard -> Element KeyboardMsg
view (Keyboard model config) =
    let
        numOctaves =
            config.numOctaves

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
            []
            [ row
                []
                [ column
                    []
                    [ row
                        [ width (px keyboardWidth)
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
                    , row
                        []
                        []
                    ]
                ]
            , row
                [ width (fill |> minimum 400 |> maximum 1000)
                , paddingXY 0 10
                ]
                [ el [ width fill ] (viewMaybe viewSVGRenderedIncipit model.notation)
                ]
            ]
        ]
