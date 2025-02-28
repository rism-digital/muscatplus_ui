module Page.RecordTypes.Probe exposing (ProbeData, ProbeStatus(..), QueryValidation(..), probeResponseDecoder)

import Http.Detailed
import Json.Decode as Decode exposing (Decoder, bool, int)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Search exposing (SearchPagination, searchPaginationDecoder)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias ProbeData =
    { totalItems : Int
    , queryStatus : QueryValidation
    , pagination : SearchPagination
    }


type ProbeStatus
    = Probing
    | ProbeSuccess ProbeData
    | ProbeError (Http.Detailed.Error String)
    | NotChecked


type QueryValidation
    = ValidQuery
    | InvalidQuery LanguageMap
    | EmptyQuery
    | CheckingQuery
    | NotCheckedQuery


probeResponseDecoder : Decoder ProbeData
probeResponseDecoder =
    Decode.succeed ProbeData
        |> required "totalItems" int
        |> required "queryValidation" queryValidationDecoder
        |> required "view" searchPaginationDecoder


queryValidationDecoder : Decoder QueryValidation
queryValidationDecoder =
    Decode.map2
        (\status message ->
            if status then
                ValidQuery

            else
                InvalidQuery message
        )
        (Decode.field "valid" bool)
        (Decode.field "message" languageMapLabelDecoder)
