module Page.Request exposing
    ( createCountryCodeRequestWithDecoder
    , createProbeRequestWithDecoder
    , createRequestWithDecoder
    , createSuggestRequestWithDecoder
    )

import Dict exposing (Dict)
import Http
import Http.Detailed
import Language exposing (LanguageMap)
import Page.Decoders exposing (recordResponseDecoder)
import Page.RecordTypes.Countries exposing (CountryCode, countryCodeDecoder)
import Page.RecordTypes.Probe exposing (ProbeData, probeResponseDecoder)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion, suggestionResponseDecoder)
import Request exposing (createRequest)
import Response exposing (ServerData)


createCountryCodeRequestWithDecoder : (Result (Http.Detailed.Error String) ( Http.Metadata, Dict CountryCode LanguageMap ) -> msg) -> Cmd msg
createCountryCodeRequestWithDecoder msg =
    createRequest msg countryCodeDecoder "/countries/list/"


createProbeRequestWithDecoder : (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ) -> msg) -> String -> Cmd msg
createProbeRequestWithDecoder msg url =
    createRequest msg probeResponseDecoder url


createRequestWithDecoder : (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ) -> msg) -> String -> Cmd msg
createRequestWithDecoder msg url =
    createRequest msg recordResponseDecoder url


createSuggestRequestWithDecoder : (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ) -> msg) -> String -> Cmd msg
createSuggestRequestWithDecoder msg url =
    createRequest msg suggestionResponseDecoder url
