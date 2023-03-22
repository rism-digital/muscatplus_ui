module Page.RecordTypes.DigitalObjects exposing (DigitalObject, DigitalObjectBody(..), DigitalObjectsSectionBody, digitalObjectsSectionBodyDecoder)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias DigitalObjectsSectionBody =
    { sectionToc : String
    , label : LanguageMap
    , items : List DigitalObject
    }


type alias DigitalObject =
    { label : LanguageMap
    , body : DigitalObjectBody
    }


type DigitalObjectBody
    = ImageObject { thumb : String, medium : String, original : String }
    | EncodingObject { encoding : String, rendering : String }


digitalObjectsSectionBodyDecoder : Decoder DigitalObjectsSectionBody
digitalObjectsSectionBodyDecoder =
    Decode.succeed DigitalObjectsSectionBody
        |> hardcoded "record-digital-objects-section"
        |> required "sectionLabel" languageMapLabelDecoder
        |> required "items" (list digitalObjectDecoder)


digitalObjectDecoder : Decoder DigitalObject
digitalObjectDecoder =
    Decode.succeed DigitalObject
        |> required "label" languageMapLabelDecoder
        |> required "body" digitalObjectBodyDecoder


digitalObjectBodyDecoder : Decoder DigitalObjectBody
digitalObjectBodyDecoder =
    Decode.oneOf
        [ digitalObjectImageUrlsDecoder
        , digitalObjectEncodingDecoder
        ]


digitalObjectImageUrlsDecoder : Decoder DigitalObjectBody
digitalObjectImageUrlsDecoder =
    Decode.map3
        (\thumb med orig ->
            { medium = med
            , original = orig
            , thumb = thumb
            }
        )
        (Decode.at [ "thumb", "url" ] string)
        (Decode.at [ "medium", "url" ] string)
        (Decode.at [ "original", "url" ] string)
        |> Decode.map ImageObject


digitalObjectEncodingDecoder : Decoder DigitalObjectBody
digitalObjectEncodingDecoder =
    Decode.map2
        (\enc rend ->
            { encoding = enc
            , rendering = rend
            }
        )
        (Decode.at [ "encoding", "url" ] string)
        (Decode.at [ "rendered", "data" ] string)
        |> Decode.map EncodingObject
