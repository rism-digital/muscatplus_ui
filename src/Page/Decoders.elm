module Page.Decoders exposing (recordResponseDecoder)

import Json.Decode exposing (Decoder, andThen, fail, field, map, string)
import Page.RecordTypes
    exposing
        ( RecordType(..)
        , recordTypeFromJsonType
        )
import Page.RecordTypes.ExternalRecord exposing (externalRecordBodyDecoder)
import Page.RecordTypes.Front exposing (frontBodyDecoder)
import Page.RecordTypes.Holding exposing (holdingBodyDecoder)
import Page.RecordTypes.Incipit exposing (incipitBodyDecoder)
import Page.RecordTypes.Institution exposing (institutionBodyDecoder)
import Page.RecordTypes.Person exposing (personBodyDecoder)
import Page.RecordTypes.Publication exposing (publicationBodyDecoder)
import Page.RecordTypes.PublicationList exposing (publicationListBodyDecoder)
import Page.RecordTypes.Search exposing (searchBodyDecoder)
import Page.RecordTypes.Source exposing (sourceBodyDecoder)
import Page.RecordTypes.Work exposing (workBodyDecoder)
import Response exposing (ServerData(..))


recordResponseDecoder : Decoder ServerData
recordResponseDecoder =
    field "type" string
        |> andThen recordResponseConverter


recordResponseConverter : String -> Decoder ServerData
recordResponseConverter typeValue =
    case recordTypeFromJsonType typeValue of
        Source ->
            map SourceData sourceBodyDecoder

        Person ->
            map PersonData personBodyDecoder

        Institution ->
            map InstitutionData institutionBodyDecoder

        Holding ->
            map HoldingData holdingBodyDecoder

        Incipit ->
            map IncipitData incipitBodyDecoder

        CollectionSearchResult ->
            map SearchData searchBodyDecoder

        Front ->
            map FrontData frontBodyDecoder

        ExternalRecord ->
            map ExternalData externalRecordBodyDecoder

        Publication ->
            map PublicationData publicationBodyDecoder

        PublicationList ->
            map PublicationListData publicationListBodyDecoder

        Work ->
            map WorkData workBodyDecoder

        _ ->
            fail "Could not decode record body response"
