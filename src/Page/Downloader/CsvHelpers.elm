module Page.Downloader.CsvHelpers exposing (..)

import Csv.Encode
import Dict exposing (Dict)
import Language exposing (Language(..), extractLabelFromLanguageMap)
import Maybe.Extra as ME
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (IncipitResultBody, InstitutionResultBody, PersonResultBody, ResultsBody, SearchResult(..), SourceResultBody)
import Page.RecordTypes.Shared exposing (LabelValue)


type CsvRecordType
    = SourceCsvRecordType SourceCsvEntry
    | PersonCsvRecordType CsvEntry
    | InstitutionCsvRecordType CsvEntry
    | IncipitCsvRecordType CsvEntry


type alias CsvEntry =
    { url : String
    , title : String
    }


type alias SourceCsvEntry =
    { url : String
    , title : String
    , sourceType : String
    , contentType : String
    , recordType : String
    , dateStatements : String
    , creatorAuthor : String
    , otherContributors : String
    }


createSearchUrlRecord : ResultMode -> String -> CsvRecordType
createSearchUrlRecord resultMode url =
    case resultMode of
        SourcesMode ->
            SourceCsvRecordType
                { url = url
                , title = "Search URL"
                , sourceType = ""
                , contentType = ""
                , recordType = ""
                , dateStatements = ""
                , creatorAuthor = ""
                , otherContributors = ""
                }

        PeopleMode ->
            PersonCsvRecordType { url = url, title = "Search URL" }

        InstitutionsMode ->
            InstitutionCsvRecordType { url = url, title = "Search URL" }

        IncipitsMode ->
            IncipitCsvRecordType { url = url, title = "Search URL" }


sourceCsvEntryToFieldString : SourceCsvEntry -> List ( String, String )
sourceCsvEntryToFieldString entry =
    [ ( "url", entry.url )
    , ( "title", entry.title )
    , ( "source_type", entry.sourceType )
    , ( "content_type", entry.contentType )
    , ( "record_type", entry.recordType )
    , ( "date_statements", entry.dateStatements )
    , ( "creator_author", entry.creatorAuthor )
    , ( "other_contributors", entry.otherContributors )
    ]


csvEntryToFieldString : CsvEntry -> List ( String, String )
csvEntryToFieldString { url, title } =
    [ ( "url", url )
    , ( "title", title )
    ]


csvEntriesConverter : CsvRecordType -> List ( String, String )
csvEntriesConverter record =
    case record of
        SourceCsvRecordType entry ->
            sourceCsvEntryToFieldString entry

        PersonCsvRecordType entry ->
            csvEntryToFieldString entry

        InstitutionCsvRecordType entry ->
            csvEntryToFieldString entry

        IncipitCsvRecordType entry ->
            csvEntryToFieldString entry


resultListToCsvString : List CsvRecordType -> String
resultListToCsvString searchResults =
    Csv.Encode.encode
        { encoder = Csv.Encode.withFieldNames csvEntriesConverter
        , fieldSeparator = ','
        }
        searchResults


convertResult : SearchResult -> CsvRecordType
convertResult res =
    case res of
        SourceResult body ->
            convertSourceResultBody body

        PersonResult body ->
            convertPersonResultBody body

        InstitutionResult body ->
            convertInstitutionResultBody body

        IncipitResult body ->
            convertIncipitResultBody body


extractFromSummaryDict : String -> Maybe (Dict String LabelValue) -> String
extractFromSummaryDict dictKey summaryDict =
    Maybe.map
        (\summary ->
            Dict.get dictKey summary
                |> Maybe.map (\composer -> extractLabelFromLanguageMap None composer.value)
        )
        summaryDict
        |> ME.join
        |> Maybe.withDefault ""


convertSourceResultBody : SourceResultBody -> CsvRecordType
convertSourceResultBody body =
    let
        sourceType =
            Maybe.map (\fs -> extractLabelFromLanguageMap English (.label fs.sourceType)) body.flags
                |> Maybe.withDefault ""

        recordType =
            Maybe.map (\fs -> extractLabelFromLanguageMap English (.label fs.recordType)) body.flags
                |> Maybe.withDefault ""

        contentTypes =
            Maybe.map
                (\fs ->
                    List.map (\l -> extractLabelFromLanguageMap English l.label) fs.contentTypes
                        |> String.join "; "
                )
                body.flags
                |> Maybe.withDefault ""

        dateStatements =
            extractFromSummaryDict "dateStatements" body.summary

        sourceComposer =
            extractFromSummaryDict "sourceComposer" body.summary

        resultComposers =
            extractFromSummaryDict "sourceComposers" body.summary
    in
    SourceCsvRecordType
        { url = body.id
        , title = extractLabelFromLanguageMap English body.label
        , sourceType = sourceType
        , contentType = contentTypes
        , recordType = recordType
        , dateStatements = dateStatements
        , creatorAuthor = sourceComposer
        , otherContributors = resultComposers
        }


convertPersonResultBody : PersonResultBody -> CsvRecordType
convertPersonResultBody body =
    PersonCsvRecordType
        { url = body.id
        , title = extractLabelFromLanguageMap English body.label
        }


convertInstitutionResultBody : InstitutionResultBody -> CsvRecordType
convertInstitutionResultBody body =
    InstitutionCsvRecordType
        { url = body.id
        , title = extractLabelFromLanguageMap English body.label
        }


convertIncipitResultBody : IncipitResultBody -> CsvRecordType
convertIncipitResultBody body =
    IncipitCsvRecordType
        { url = body.id
        , title = extractLabelFromLanguageMap English body.label
        }
