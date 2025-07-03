module Page.Downloader.CsvHelpers exposing (CsvRecordType, convertResult, createSearchUrlRecord, resultListToCsvString)

import Csv.Encode
import Dict exposing (Dict)
import Language exposing (Language(..), extractLabelFromLanguageMap)
import Maybe.Extra as ME
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (IncipitResultBody, InstitutionResultBody, PersonResultBody, SearchResult(..), SourceResultBody)
import Page.RecordTypes.Shared exposing (LabelValue)


type CsvRecordType
    = SourceCsvRecordType SourceCsvEntry
    | PersonCsvRecordType PersonCsvEntry
    | InstitutionCsvRecordType InstitutionCsvEntry
    | IncipitCsvRecordType IncipitCsvEntry
    | UnsupportedRecordType


type alias InstitutionCsvEntry =
    { url : String
    , title : String
    , country : String
    , numberOfSources : String
    , catalogSource : String
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
    , catalogSource : String
    }


type alias PersonCsvEntry =
    { url : String
    , title : String
    , gender : String
    , numberOfSources : String
    , catalogSource : String
    }


type alias IncipitCsvEntry =
    { url : String
    , title : String
    , sourceUrl : String
    , paeCode : String
    , composer : String
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
                , catalogSource = ""
                }

        PeopleMode ->
            PersonCsvRecordType
                { url = url
                , title = "Search URL"
                , gender = ""
                , numberOfSources = ""
                , catalogSource = ""
                }

        InstitutionsMode ->
            InstitutionCsvRecordType
                { url = url
                , title = "Search URL"
                , country = ""
                , numberOfSources = ""
                , catalogSource = ""
                }

        IncipitsMode ->
            IncipitCsvRecordType
                { url = url
                , title = "Search URL"
                , sourceUrl = ""
                , paeCode = ""
                , composer = ""
                }

        WorkCatalogueMode ->
            UnsupportedRecordType

        NoMode ->
            UnsupportedRecordType


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
    , ( "catalogue_source", entry.catalogSource )
    ]


personCsvEntryToFieldString : PersonCsvEntry -> List ( String, String )
personCsvEntryToFieldString entry =
    [ ( "url", entry.url )
    , ( "title", entry.title )
    , ( "gender", entry.gender )
    , ( "number_of_sources", entry.numberOfSources )
    , ( "catalogue_source", entry.catalogSource )
    ]


incipitCsvEntryToFieldString : IncipitCsvEntry -> List ( String, String )
incipitCsvEntryToFieldString entry =
    [ ( "url", entry.url )
    , ( "title", entry.title )
    , ( "source_url", entry.sourceUrl )
    , ( "pae_code", entry.paeCode )
    , ( "composer", entry.composer )
    ]


institutionCsvEntryToFieldString : InstitutionCsvEntry -> List ( String, String )
institutionCsvEntryToFieldString entry =
    [ ( "url", entry.url )
    , ( "title", entry.title )
    , ( "country", entry.country )
    , ( "number_of_source", entry.numberOfSources )
    , ( "catalogue_source", entry.catalogSource )
    ]


csvEntriesConverter : CsvRecordType -> List ( String, String )
csvEntriesConverter record =
    case record of
        SourceCsvRecordType entry ->
            sourceCsvEntryToFieldString entry

        PersonCsvRecordType entry ->
            personCsvEntryToFieldString entry

        InstitutionCsvRecordType entry ->
            institutionCsvEntryToFieldString entry

        IncipitCsvRecordType entry ->
            incipitCsvEntryToFieldString entry

        UnsupportedRecordType ->
            []


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

        WorkResult _ ->
            UnsupportedRecordType


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
        isDIAMMRecord =
            Maybe.map .isDIAMMRecord body.flags
                |> Maybe.withDefault False

        isCantusRecord =
            Maybe.map .isCantusRecord body.flags
                |> Maybe.withDefault False

        sourceType =
            Maybe.map (\fs -> extractLabelFromLanguageMap English (.label fs.sourceType)) body.flags
                |> Maybe.withDefault ""

        recordType =
            Maybe.map (\fs -> extractLabelFromLanguageMap English (.label fs.recordType)) body.flags
                |> Maybe.withDefault ""

        catalogSource =
            if isDIAMMRecord then
                "DIAMM"

            else if isCantusRecord then
                "Cantus"

            else
                "RISM"

        csvRecordUrl =
            if isDIAMMRecord || isCantusRecord then
                Maybe.map .externalProjectURL body.flags
                    |> Maybe.andThen identity
                    |> Maybe.withDefault ""

            else
                body.id

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
        { url = csvRecordUrl
        , title = extractLabelFromLanguageMap English body.label
        , sourceType = sourceType
        , contentType = contentTypes
        , recordType = recordType
        , dateStatements = dateStatements
        , creatorAuthor = sourceComposer
        , otherContributors = resultComposers
        , catalogSource = catalogSource
        }


convertPersonResultBody : PersonResultBody -> CsvRecordType
convertPersonResultBody body =
    let
        isDIAMMRecord =
            Maybe.map .isDIAMMRecord body.flags
                |> Maybe.withDefault False

        gender =
            extractFromSummaryDict "gender" body.summary

        numberOfSources =
            extractFromSummaryDict "numSources" body.summary

        catalogSource =
            if isDIAMMRecord then
                "DIAMM"

            else
                "RISM"

        csvRecordUrl =
            if isDIAMMRecord then
                Maybe.map .externalProjectURL body.flags
                    |> Maybe.andThen identity
                    |> Maybe.withDefault ""

            else
                body.id
    in
    PersonCsvRecordType
        { url = csvRecordUrl
        , title = extractLabelFromLanguageMap English body.label
        , gender = gender
        , numberOfSources = numberOfSources
        , catalogSource = catalogSource
        }


convertInstitutionResultBody : InstitutionResultBody -> CsvRecordType
convertInstitutionResultBody body =
    let
        isDIAMMRecord =
            Maybe.map .isDIAMMRecord body.flags
                |> Maybe.withDefault False

        isCantusRecord =
            Maybe.map .isCantusRecord body.flags
                |> Maybe.withDefault False

        country =
            extractFromSummaryDict "country" body.summary

        numberOfSources =
            extractFromSummaryDict "totalSources" body.summary

        catalogSource =
            if isDIAMMRecord then
                "DIAMM"

            else if isCantusRecord then
                "Cantus"

            else
                "RISM"

        csvRecordUrl =
            if isDIAMMRecord || isCantusRecord then
                Maybe.map .externalProjectURL body.flags
                    |> Maybe.andThen identity
                    |> Maybe.withDefault ""

            else
                body.id
    in
    InstitutionCsvRecordType
        { url = csvRecordUrl
        , title = extractLabelFromLanguageMap English body.label
        , country = country
        , numberOfSources = numberOfSources
        , catalogSource = catalogSource
        }


convertIncipitResultBody : IncipitResultBody -> CsvRecordType
convertIncipitResultBody body =
    let
        paeCode =
            extractFromSummaryDict "paeCode" body.summary

        composer =
            extractFromSummaryDict "incipitComposer" body.summary

        sourceUrl =
            body.partOf
                |> .source
                |> .id
    in
    IncipitCsvRecordType
        { url = body.id
        , title = extractLabelFromLanguageMap English body.label
        , sourceUrl = sourceUrl
        , paeCode = paeCode
        , composer = composer
        }
