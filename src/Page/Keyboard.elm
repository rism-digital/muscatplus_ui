module Page.Keyboard exposing (..)

import Array
import Config
import Element exposing (Element)
import Language exposing (Language)
import List.Extra as LE
import Page.Keyboard.Model exposing (Clef(..), Keyboard(..), KeyboardModel, KeyboardQuery, setNoteData)
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (createPAENote)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Keyboard.Views as KeyboardViews
import Request exposing (createSvgRequest, serverUrl)
import SearchPreferences exposing (saveSearchPreference)
import SearchPreferences.SetPreferences exposing (SearchPreferenceVariant(..))


type alias Model =
    KeyboardModel


init : Int -> ( Keyboard, Cmd KeyboardMsg )
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
    , needsProbe = False
    }


toNotation : { a | notation : Maybe String } -> Maybe String
toNotation model =
    model.notation


setNotation : Maybe String -> { a | notation : Maybe String } -> { a | notation : Maybe String }
setNotation newNotation oldRecord =
    { oldRecord | notation = newNotation }


setQuery : KeyboardQuery -> { a | query : KeyboardQuery } -> { a | query : KeyboardQuery }
setQuery newQuery oldModel =
    { oldModel | query = newQuery }


buildUpdateQuery : Maybe (List String) -> Model -> ( Model, Cmd KeyboardMsg )
buildUpdateQuery newNoteData model =
    let
        newQuery =
            setNoteData newNoteData model.query

        url =
            buildNotationQueryParameters newQuery
                |> serverUrl [ "incipits/render" ]
    in
    ( { model | query = newQuery }
    , createSvgRequest ServerRespondedWithRenderedNotation url
    )


buildNotationRequestQuery : KeyboardQuery -> Cmd KeyboardMsg
buildNotationRequestQuery keyboardQuery =
    let
        keyboardQp =
            buildNotationQueryParameters keyboardQuery

        url =
            serverUrl [ "incipits/render" ] keyboardQp
    in
    createSvgRequest ServerRespondedWithRenderedNotation url


update : KeyboardMsg -> KeyboardModel -> ( KeyboardModel, Cmd KeyboardMsg )
update msg model =
    case msg of
        ServerRespondedWithRenderedNotation (Ok ( _, response )) ->
            ( { model
                | notation = Just response
                , needsProbe = False
              }
            , Cmd.none
            )

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
                            Array.fromList n
                                |> Array.push note
                                |> Array.toList

                        Nothing ->
                            [ note ]

                needsProbing =
                    if List.length noteData > Config.minimumQueryLength then
                        True

                    else
                        False

                newModel =
                    { model | needsProbe = needsProbing }
            in
            buildUpdateQuery (Just noteData) newModel

        UserClickedPianoKeyboardDeleteNote ->
            let
                query =
                    model.query

                noteData =
                    Maybe.withDefault [] query.noteData
                        |> LE.init
            in
            buildUpdateQuery noteData model

        ClientRequestedRenderedNotation ->
            let
                noteData =
                    .noteData model.query
            in
            buildUpdateQuery noteData model

        UserEnteredPAEText text ->
            let
                _ =
                    Debug.log "Query text" text
            in
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


{-|

    Exposes only the top level view

-}
view : Language -> Keyboard -> Element KeyboardMsg
view lang keyboardConfig =
    KeyboardViews.view lang keyboardConfig
