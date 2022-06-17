module Page.Keyboard exposing
    ( Model
    , buildNotationRequestQuery
    , buildNotationValidationQuery
    , buildUpdateQuery
    , defaultKeyboardQuery
    , init
    , initModel
    , setNotation
    , setQuery
    , toNotation
    , update
    , updateDebouncerPAESearchConfig
    , view
    )

import Config
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Element exposing (Element)
import Flip exposing (flip)
import Language exposing (Language)
import Page.Keyboard.Model exposing (Clef(..), KeySignature(..), Keyboard(..), KeyboardModel, KeyboardQuery, QueryMode(..), TimeSignature(..), setClef, setKeySignature, setKeyboardQuery, setNoteData, setQueryMode, setTimeSignature, toKeyboardQuery)
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (createPAENote)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Keyboard.Views as KeyboardViews
import Page.RecordTypes.Incipit exposing (incipitValidationBodyDecoder)
import Page.RecordTypes.Search exposing (NotationFacet)
import Request exposing (createRequest, createSvgRequest, serverUrl)
import Utlities exposing (choose)


type alias Model msg =
    KeyboardModel msg


buildNotationRequestQuery : KeyboardQuery -> Cmd KeyboardMsg
buildNotationRequestQuery keyboardQuery =
    buildNotationQueryParameters keyboardQuery
        |> serverUrl [ "incipits/render" ]
        |> createSvgRequest ServerRespondedWithRenderedNotation


buildNotationValidationQuery : KeyboardQuery -> Cmd KeyboardMsg
buildNotationValidationQuery keyboardQuery =
    buildNotationQueryParameters keyboardQuery
        |> serverUrl [ "incipits/render" ]
        |> createRequest ServerRespondedWithNotationValidation incipitValidationBodyDecoder


buildUpdateQuery : Maybe String -> KeyboardModel KeyboardMsg -> ( KeyboardModel KeyboardMsg, Cmd KeyboardMsg )
buildUpdateQuery newNoteData model =
    let
        debounceMsg =
            provideInput DebouncerSettledToSendPAEText
                |> DebouncerCapturedPAEText

        newModel =
            { model
                | query = newQuery
            }

        newQuery =
            setNoteData newNoteData model.query

        url =
            buildNotationQueryParameters newQuery
                |> serverUrl [ "incipits/render" ]
    in
    ( newModel
    , Cmd.batch
        [ createSvgRequest ServerRespondedWithRenderedNotation url
        , update debounceMsg newModel |> Tuple.second
        ]
    )


defaultKeyboardQuery : KeyboardQuery
defaultKeyboardQuery =
    { clef = G2
    , timeSignature = TNone
    , keySignature = KS_N
    , noteData = Nothing
    , queryMode = IntervalQueryMode
    }


init : Int -> ( Keyboard KeyboardMsg, Cmd KeyboardMsg )
init numOctaves =
    let
        -- needs a config and a model instance
        config =
            { numOctaves = numOctaves }

        model =
            initModel
    in
    ( Keyboard model config, Cmd.none )


initModel : Model msg
initModel =
    { query = defaultKeyboardQuery
    , notation = Nothing
    , needsProbe = False
    , inputIsValid = True
    , paeInputSearchDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    }


setNotation : Maybe String -> { a | notation : Maybe String } -> { a | notation : Maybe String }
setNotation newNotation oldRecord =
    { oldRecord | notation = newNotation }


setQuery : KeyboardQuery -> { a | query : KeyboardQuery } -> { a | query : KeyboardQuery }
setQuery newQuery oldModel =
    { oldModel | query = newQuery }


toNotation : { a | notation : Maybe String } -> Maybe String
toNotation model =
    model.notation


update : KeyboardMsg -> KeyboardModel KeyboardMsg -> ( KeyboardModel KeyboardMsg, Cmd KeyboardMsg )
update msg model =
    case msg of
        ServerRespondedWithRenderedNotation (Ok ( _, response )) ->
            ( { model
                | notation = Just response
                , needsProbe = False
              }
            , Cmd.none
            )

        ServerRespondedWithRenderedNotation (Err _) ->
            ( model, Cmd.none )

        ServerRespondedWithNotationValidation (Ok ( _, response )) ->
            ( { model
                | inputIsValid = response.isValid
              }
            , Cmd.none
            )

        ServerRespondedWithNotationValidation (Err _) ->
            ( model, Cmd.none )

        UserClickedPianoKeyboardKey noteName octave ->
            let
                needsProbing =
                    choose (String.length noteData > Config.minimumQueryLength) True False

                newModel =
                    { model | needsProbe = needsProbing }

                note =
                    createPAENote noteName octave

                noteData =
                    case query.noteData of
                        Just n ->
                            n ++ note

                        Nothing ->
                            note

                query =
                    model.query
            in
            buildUpdateQuery (Just noteData) newModel

        UserClickedPianoKeyboardChangeClef clef ->
            let
                newModel =
                    toKeyboardQuery model
                        |> setClef clef
                        |> flip setKeyboardQuery model
            in
            ( newModel
            , buildNotationRequestQuery newModel.query
            )

        UserInteractedWithPAEText text ->
            let
                -- Drop any characters that exceed the 1024 limit.
                checkedLengthText =
                    if String.length text > 1024 then
                        String.left 1024 text

                    else
                        text

                -- Ensure that any pitches letters that are entered are upper-cased
                -- skips "b" since that can also be a flat!
                newText =
                    String.map
                        (\c ->
                            if List.member c [ 'a', 'c', 'd', 'e', 'f', 'g' ] then
                                Char.toUpper c

                            else
                                c
                        )
                        checkedLengthText
            in
            buildUpdateQuery (Just newText) model

        DebouncerCapturedPAEText textMsg ->
            Debouncer.update update updateDebouncerPAESearchConfig textMsg model

        DebouncerSettledToSendPAEText ->
            ( { model | needsProbe = True }, Cmd.none )

        UserClickedPianoKeyboardChangeTimeSignature tsig ->
            let
                newModel =
                    toKeyboardQuery model
                        |> setTimeSignature tsig
                        |> flip setKeyboardQuery model
            in
            ( newModel
            , buildNotationRequestQuery newModel.query
            )

        UserClickedPianoKeyboardChangeKeySignature ksig ->
            let
                newModel =
                    toKeyboardQuery model
                        |> setKeySignature ksig
                        |> flip setKeyboardQuery model
            in
            ( newModel
            , buildNotationRequestQuery newModel.query
            )

        UserChangedQueryMode qMode ->
            let
                newModel =
                    toKeyboardQuery model
                        |> setQueryMode qMode
                        |> flip setKeyboardQuery model
            in
            ( { newModel | needsProbe = True }
            , Cmd.none
            )

        NothingHappenedWithTheKeyboard ->
            ( model, Cmd.none )


updateDebouncerPAESearchConfig : Debouncer.UpdateConfig KeyboardMsg (KeyboardModel KeyboardMsg)
updateDebouncerPAESearchConfig =
    { mapMsg = DebouncerCapturedPAEText
    , getDebouncer = .paeInputSearchDebouncer
    , setDebouncer = \debouncer model -> { model | paeInputSearchDebouncer = debouncer }
    }


{-|

    Exposes only the top level view

-}
view : NotationFacet -> Language -> Keyboard KeyboardMsg -> Element KeyboardMsg
view notationFacet lang keyboardConfig =
    KeyboardViews.view notationFacet lang keyboardConfig
