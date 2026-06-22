module Page.UI.Search.MobileResults exposing
    ( viewMobilePagedResults
    , viewMobileScrollableResults
    )

import Element exposing (Attribute, Element, alignTop, clipX, column, fill, height, htmlAttribute, row, scrollbarY, width)
import Html.Attributes as HA


viewMobileScrollableResults : List (Attribute msg) -> List (Element msg) -> Element msg
viewMobileScrollableResults attrs content =
    row
        [ width fill
        , height fill
        , alignTop
        , clipX
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            (width fill
                :: alignTop
                :: attrs
            )
            content
        ]


viewMobilePagedResults :
    { bodyAttributes : List (Attribute msg)
    , cards : List (Element msg)
    , pagination : Element msg
    }
    -> Element msg
viewMobilePagedResults { bodyAttributes, cards, pagination } =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ viewMobileScrollableResults bodyAttributes cards
            , pagination
            ]
        ]
