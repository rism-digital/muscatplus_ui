module Page.QueryBuilder.Msg exposing (..)


type QueryBuilderMsg
    = NothingHappenedWithTheQueryBuilder
    | UserEnteredTextInQueryBuilder String
    | UserClickedOnFieldName String
