module Page.Downloader.CsvHelpers exposing (..)

import Csv.Encode
import Language exposing (Language(..), extractLabelFromLanguageMap)
import Maybe.Extra as ME
import Page.RecordTypes.Search exposing (IncipitResultBody, InstitutionResultBody, PersonResultBody, ResultsBody, SearchResult(..), SourceResultBody)


type alias CsvEntry =
    { url : String
    , title : String
    }


csvEntryToFieldString : CsvEntry -> List ( String, String )
csvEntryToFieldString { url, title } =
    [ ( "url", url )
    , ( "title", title )
    ]


resultListToCsvString : Maybe String -> List ResultsBody -> String
resultListToCsvString originalUrl searchResults =
    let
        converted =
            List.concatMap .items searchResults
                |> List.map convertResult

        allRecords =
            ME.unpack (\() -> converted)
                (\u -> { url = u, title = "Search URL" } :: converted)
                originalUrl
    in
    Csv.Encode.encode
        { encoder = Csv.Encode.withFieldNames csvEntryToFieldString
        , fieldSeparator = ','
        }
        allRecords


convertResult : SearchResult -> CsvEntry
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


convertSourceResultBody : SourceResultBody -> CsvEntry
convertSourceResultBody body =
    { url = body.id
    , title = extractLabelFromLanguageMap English body.label
    }


convertPersonResultBody : PersonResultBody -> CsvEntry
convertPersonResultBody body =
    { url = body.id
    , title = extractLabelFromLanguageMap English body.label
    }


convertInstitutionResultBody : InstitutionResultBody -> CsvEntry
convertInstitutionResultBody body =
    { url = body.id
    , title = extractLabelFromLanguageMap English body.label
    }


convertIncipitResultBody : IncipitResultBody -> CsvEntry
convertIncipitResultBody body =
    { url = body.id
    , title = extractLabelFromLanguageMap English body.label
    }
