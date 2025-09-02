module Page.RecordTypes.Incipit exposing
    ( EncodedIncipit(..)
    , IncipitBody
    , IncipitFormat(..)
    , IncipitParentSourceBody
    , IncipitParentWorkBody
    , IncipitsSectionBody
    , PAEEncodedData
    , RenderedIncipit(..)
    , incipitBodyDecoder
    , incipitsSectionBodyDecoder
    , renderedIncipitDecoderOne
    , renderedIncipitDecoderTwo
    )

import Json.Decode as Decode exposing (Decoder, list, map, maybe, oneOf, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Language exposing (LanguageMap)
import List.Extra as LE
import Page.RecordTypes.PartOf exposing (PartOfSectionBody, partOfSectionBodyDecoder)
import Page.RecordTypes.Shared exposing (LabelValue, labelValueDecoder, languageMapLabelDecoder)
import Page.RecordTypes.SourceBasic exposing (BasicSourceBody, basicSourceBodyDecoder)
import Page.RecordTypes.WorkBasic exposing (BasicWorkBody, basicWorkBodyDecoder)


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


type alias IncipitsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List IncipitBody
    }


type alias IncipitBody =
    { sectionToc : String
    , id : String
    , label : LanguageMap
    , summary : Maybe (List LabelValue)
    , partOf : Maybe PartOfSectionBody
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


type alias IncipitParentWorkBody =
    { label : LanguageMap
    , work : BasicWorkBody
    }


type RenderedIncipit
    = RenderedIncipit IncipitFormat String


incipitBodyDecoder : Decoder IncipitBody
incipitBodyDecoder =
    Decode.succeed IncipitBody
        -- nb: decodes the id into the sectionToc field.
        |> required "id" incipitTocDecoder
        |> required "id" string
        |> required "label" languageMapLabelDecoder
        |> optional "summary" (maybe (list labelValueDecoder)) Nothing
        |> optional "partOf" (maybe partOfSectionBodyDecoder) Nothing
        |> optional "rendered" (maybe (list renderedIncipitEncoder)) Nothing
        |> optional "encodings" (maybe (list encodedIncipitDecoder)) Nothing


incipitTocDecoder : Decoder String
incipitTocDecoder =
    string
        |> map
            (\incipitId ->
                String.split "/" incipitId
                    |> LE.last
                    |> Maybe.withDefault "1.1.1"
                    |> String.append "incipit-"
            )


encodedIncipitDecoder : Decoder EncodedIncipit
encodedIncipitDecoder =
    oneOf
        [ paeEncodedIncipitDecoder
        , meiEncodedIncipitDecoder
        ]


renderedIncipitEncoder : Decoder RenderedIncipit
renderedIncipitEncoder =
    oneOf
        [ renderedIncipitDecoderOne
        , renderedIncipitDecoderTwo
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
        |> optional "clef" (maybe string) Nothing
        |> optional "keysig" (maybe string) Nothing
        |> optional "timesig" (maybe string) Nothing
        |> optional "key" (maybe string) Nothing
        |> required "data" string


incipitFormatDecoder : Decoder IncipitFormat
incipitFormatDecoder =
    string
        |> map
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


incipitsSectionBodyDecoder : Decoder IncipitsSectionBody
incipitsSectionBodyDecoder =
    Decode.succeed IncipitsSectionBody
        |> hardcoded "record-incipits-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list incipitBodyDecoder)
