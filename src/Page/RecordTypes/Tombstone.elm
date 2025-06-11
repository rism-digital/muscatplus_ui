module Page.RecordTypes.Tombstone exposing (Tombstone, messageToTombstone)

import Json.Decode as Decode exposing (Decoder, Error, decodeString, map, string)
import Json.Decode.Extra exposing (datetime)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap)
import Page.RecordTypes exposing (RecordType, recordTypeFromJsonType)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)
import Time


type alias Tombstone =
    { id : String
    , recordType : RecordType
    , name : LanguageMap
    , deleted : Time.Posix
    }


messageToTombstone : String -> Result Error Tombstone
messageToTombstone msg =
    decodeString tombstoneDecoder msg


tombstoneDecoder : Decoder Tombstone
tombstoneDecoder =
    Decode.succeed Tombstone
        |> required "id" string
        |> required "recordType" (string |> map recordTypeFromJsonType)
        |> required "name" languageMapLabelDecoder
        |> required "deleted" datetime
