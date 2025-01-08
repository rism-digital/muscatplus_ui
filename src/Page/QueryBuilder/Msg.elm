module Page.QueryBuilder.Msg exposing (QueryBuilderMsg(..))

import Page.QueryBuilder.Model exposing (QueryBuilderOperator)


type QueryBuilderMsg
    = UserEnteredTextInQueryBuilder String
    | UserClickedOnFieldName String String
    | UserClickedOnOperator QueryBuilderOperator String
    | UserClickedSearchButton
    | NothingHappenedWithTheQueryBuilder
