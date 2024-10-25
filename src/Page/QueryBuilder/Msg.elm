module Page.QueryBuilder.Msg exposing (QueryBuilderMsg(..))


type QueryBuilderMsg
    = UserEnteredTextInQueryBuilder String
    | UserClickedOnFieldName String String
