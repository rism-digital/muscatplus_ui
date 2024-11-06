module Page.QueryBuilder.Model exposing (QueryBuilderModel, QueryBuilderOperator(..), queryBuilderOperatorToLabel)


type alias QueryBuilderModel =
    {}


type QueryBuilderOperator
    = AndOperator
    | OrOperator
    | NotOperator
    | PlusOperator
    | MinusOperator
    | BoostOperator
    | FuzzyOperator


queryBuilderOperatorToLabel : QueryBuilderOperator -> String
queryBuilderOperatorToLabel op =
    case op of
        AndOperator ->
            "AND"

        OrOperator ->
            "OR"

        NotOperator ->
            "NOT"

        PlusOperator ->
            "+"

        MinusOperator ->
            "-"

        BoostOperator ->
            "^"

        FuzzyOperator ->
            "~"
