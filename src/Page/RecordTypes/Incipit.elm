module Page.RecordTypes.Incipit exposing
    ( EncodedIncipit(..)
    , IncipitBody
    , IncipitFormat(..)
    , IncipitParentSourceBody
    , PAEEncodedData
    , RenderedIncipit(..)
    , incipitBodyDecoder
    , renderedIncipitDecoderOne
    , renderedIncipitDecoderTwo
    )

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (optional, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)


type EncodedIncipit
    = PAEEncoding LanguageMap PAEEncodedData
    | MEIEncoding LanguageMap String


type alias PAEEncodedData =
    { clef : Maybe String
    , keysig : Maybe String
    , timesig : Maybe String
    , key : Maybe String
    , data : String
    }


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
    | RenderedPNG
    | UnknownFormat


type alias IncipitParentSourceBody =
    { label : LanguageMap
    , source : BasicSourceBody
    }


type RenderedIncipit
    = RenderedIncipit IncipitFormat String


incipitBodyDecoder : Decoder IncipitBody
incipitBodyDecoder =
    Decode.succeed IncipitBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (Decode.maybe (list labelValueDecoder)) Nothing
        |> required "partOf" incipitParentSourceBodyDecoder
        |> optional "rendered" (Decode.maybe (list (Decode.oneOf [ renderedIncipitDecoderOne, renderedIncipitDecoderTwo ]))) Nothing
        |> optional "encodings" (Decode.maybe (list encodedIncipitDecoder)) Nothing


encodedIncipitDecoder : Decoder EncodedIncipit
encodedIncipitDecoder =
    Decode.oneOf
        [ paeEncodedIncipitDecoder
        , meiEncodedIncipitDecoder
        ]


paeEncodedIncipitDecoder : Decoder EncodedIncipit
paeEncodedIncipitDecoder =
    Decode.succeed PAEEncoding
        |> required "label" languageMapLabelDecoder
        |> required "data" incipitEncodingDataDecoder


meiEncodedIncipitDecoder : Decoder EncodedIncipit
meiEncodedIncipitDecoder =
    Decode.succeed MEIEncoding
        |> required "label" languageMapLabelDecoder
        |> required "url" string


incipitEncodingDataDecoder : Decoder PAEEncodedData
incipitEncodingDataDecoder =
    Decode.succeed PAEEncodedData
        |> optional "clef" (Decode.maybe string) Nothing
        |> optional "keysig" (Decode.maybe string) Nothing
        |> optional "timesig" (Decode.maybe string) Nothing
        |> optional "key" (Decode.maybe string) Nothing
        |> required "data" string


incipitFormatDecoder : Decoder IncipitFormat
incipitFormatDecoder =
    string
        |> Decode.map
            (\mimetype ->
                case mimetype of
                    "audio/midi" ->
                        RenderedMIDI

                    "image/png" ->
                        RenderedPNG

                    "image/svg+xml" ->
                        RenderedSVG

                    _ ->
                        UnknownFormat
            )


incipitParentSourceBodyDecoder : Decoder IncipitParentSourceBody
incipitParentSourceBodyDecoder =
    Decode.succeed IncipitParentSourceBody
        |> required "label" languageMapLabelDecoder
        |> required "source" basicSourceBodyDecoder


renderedIncipitDecoderOne : Decoder RenderedIncipit
renderedIncipitDecoderOne =
    Decode.succeed RenderedIncipit
        |> required "format" incipitFormatDecoder
        |> required "data" string


renderedIncipitDecoderTwo : Decoder RenderedIncipit
renderedIncipitDecoderTwo =
    Decode.succeed RenderedIncipit
        |> required "format" incipitFormatDecoder
        |> required "url" string
