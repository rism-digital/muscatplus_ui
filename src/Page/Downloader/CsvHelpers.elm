module Page.Downloader.CsvHelpers exposing (..)

import Csv.Encode
import Language exposing (Language(..), extractLabelFromLanguageMap)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (IncipitResultBody, InstitutionResultBody, PersonResultBody, ResultsBody, SearchResult(..), SourceResultBody)


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
    }


searchUrlRecord : ResultMode -> String -> String
searchUrlRecord resultMode url =
    case resultMode of
        SourcesMode ->
            url ++ ",\"Search Url\",,"

        PeopleMode ->
            url ++ ",\"Search URL\""

        InstitutionsMode ->
            url ++ ",\"Search URL\""

        IncipitsMode ->
            url ++ ",\"Search URL\""


sourceCsvEntryToFieldString : SourceCsvEntry -> List ( String, String )
sourceCsvEntryToFieldString entry =
    [ ( "url", entry.url )
    , ( "title", entry.title )
    , ( "source_type", entry.sourceType )
    , ( "content_type", entry.contentType )
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


convertSourceResultBody : SourceResultBody -> CsvRecordType
convertSourceResultBody body =
    SourceCsvRecordType
        { url = body.id
        , title = extractLabelFromLanguageMap English body.label
        , sourceType = ""
        , contentType = ""
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
