module Page.RecordTypes.Incipit exposing (..)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)


type IncipitFormat
    = RenderedSVG
    | RenderedMIDI
    | UnknownFormat


type RenderedIncipit
    = RenderedIncipit IncipitFormat String


type alias IncipitBody =
    { id : String
    , label : LanguageMap
    , summary : Maybe (List LabelValue)
    , partOf : Maybe IncipitParentSourceBody
    , rendered : Maybe (List RenderedIncipit)
    }


type alias IncipitParentSourceBody =
    { label : LanguageMap
    , source : BasicSourceBody
    }


incipitBodyDecoder : Decoder IncipitBody
incipitBodyDecoder =
    Decode.succeed IncipitBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> optional "partOf" (Decode.maybe incipitParentSourceBodyDecoder) Nothing
        |> optional "rendered" (Decode.maybe (list renderedIncipitDecoder)) Nothing


incipitParentSourceBodyDecoder : Decoder IncipitParentSourceBody
incipitParentSourceBodyDecoder =
    Decode.succeed IncipitParentSourceBody
        |> required "label" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


incipitFormatDecoder : Decoder IncipitFormat
incipitFormatDecoder =
    Decode.string
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


renderedIncipitDecoder : Decoder RenderedIncipit
renderedIncipitDecoder =
    Decode.succeed RenderedIncipit
        |> required "format" incipitFormatDecoder
        |> required "data" string
