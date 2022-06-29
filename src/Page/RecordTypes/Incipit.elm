module Page.RecordTypes.Incipit exposing
    ( EncodedIncipit(..)
    , EncodingData
    , EncodingFormat(..)
    , IncipitBody
    , IncipitFormat(..)
    , IncipitParentSourceBody
    , IncipitValidationBody
    , RenderedIncipit(..)
    , incipitBodyDecoder
    , renderedIncipitDecoder
    )

import Json.Decode as Decode exposing (Decoder, bool, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)


type EncodedIncipit
    = EncodedIncipit LanguageMap EncodingFormat EncodingData


type alias EncodingData =
    { clef : Maybe String
    , keysig : Maybe String
    , timesig : Maybe String
    , key : Maybe String
    , data : String
    }


type EncodingFormat
    = PAEEncoding
    | MEIEncoding


type alias IncipitBody =
    { id : String
    , label : LanguageMap
    , summary : Maybe (List LabelValue)
    , partOf : IncipitParentSourceBody
    , rendered : Maybe (List RenderedIncipit)
    , encodings : Maybe (List EncodedIncipit)
    }


type IncipitFormat
    = RenderedSVG
    | RenderedMIDI
    | UnknownFormat


type alias IncipitParentSourceBody =
    { label : LanguageMap
    , source : BasicSourceBody
    }


type alias IncipitValidationBody =
    { isValid : Bool
    , messages : Maybe (List LanguageMap)
    }


type RenderedIncipit
    = RenderedIncipit IncipitFormat String


encodedIncipitDecoder : Decoder EncodedIncipit
encodedIncipitDecoder =
    Decode.succeed EncodedIncipit
        |> required "label" languageMapLabelDecoder
        |> required "format" incipitEncodingDecoder
        |> required "data" incipitEncodingDataDecoder


incipitBodyDecoder : Decoder IncipitBody
incipitBodyDecoder =
    Decode.succeed IncipitBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> required "partOf" incipitParentSourceBodyDecoder
        |> optional "rendered" (Decode.maybe (list renderedIncipitDecoder)) Nothing
        |> optional "encodings" (Decode.maybe (list encodedIncipitDecoder)) Nothing


incipitEncodingDataDecoder : Decoder EncodingData
incipitEncodingDataDecoder =
    Decode.succeed EncodingData
        |> optional "clef" (Decode.maybe string) Nothing
        |> optional "keysig" (Decode.maybe string) Nothing
        |> optional "timesig" (Decode.maybe string) Nothing
        |> optional "key" (Decode.maybe string) Nothing
        |> required "data" string


incipitEncodingDecoder : Decoder EncodingFormat
incipitEncodingDecoder =
    string
        |> Decode.andThen
            (\mimetype ->
                case mimetype of
                    "application/json" ->
                        Decode.succeed PAEEncoding

                    "application/xml+mei" ->
                        Decode.succeed MEIEncoding

                    _ ->
                        Decode.fail "Unknown encoding format"
            )


incipitFormatDecoder : Decoder IncipitFormat
incipitFormatDecoder =
    string
        |> Decode.andThen
            (\mimetype ->
                case mimetype of
                    "audio/midi" ->
                        Decode.succeed RenderedMIDI

                    "image/svg+xml" ->
                        Decode.succeed RenderedSVG

                    _ ->
                        Decode.succeed UnknownFormat
            )


incipitParentSourceBodyDecoder : Decoder IncipitParentSourceBody
incipitParentSourceBodyDecoder =
    Decode.succeed IncipitParentSourceBody
        |> required "label" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


incipitValidationBodyDecoder : Decoder IncipitValidationBody
incipitValidationBodyDecoder =
    Decode.succeed IncipitValidationBody
        |> required "valid" bool
        |> optional "messages" (Decode.maybe (list languageMapLabelDecoder)) Nothing


renderedIncipitDecoder : Decoder RenderedIncipit
renderedIncipitDecoder =
    Decode.succeed RenderedIncipit
        |> required "format" incipitFormatDecoder
        |> required "data" string
