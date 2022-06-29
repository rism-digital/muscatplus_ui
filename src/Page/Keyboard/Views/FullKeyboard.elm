module Page.Keyboard.Views.FullKeyboard exposing (..)

import Element exposing (Element)
import Page.Keyboard.Model exposing (KeyNoteName(..))
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Svg
import Svg.Events as SE
import VirtualDom exposing (Attribute, attribute)


keyMsg : KeyNoteName -> Int -> KeyboardMsg
keyMsg note octave =
    UserClickedPianoKeyboardKey note octave


fullKeyboard : List (Attribute KeyboardMsg) -> Element KeyboardMsg
fullKeyboard attrs =
    fullKeyboardImpl attrs
        |> Element.html


fullKeyboardImpl : List (Attribute KeyboardMsg) -> Svg.Svg KeyboardMsg
fullKeyboardImpl attrs =
    Svg.node "svg"
        ([ attribute "viewBox" "0 0 1894 404"
         , attribute "xmlns" "http://www.w3.org/2000/svg"
         , attribute "width" "800"
         ]
            ++ attrs
        )
        [ Svg.node "g"
            [ attribute "transform" "matrix(1, 0, 0, 1, -4.882425, 0.794207)"
            ]
            [ Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1645.85498, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "B5" ]
                , Svg.node "rect"
                    [ attribute "x" "172.763"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KB 5)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.310081, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KBn 5)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "fill: rgb(0, 0, 0);"
                    , attribute "d" "M 210.51 467.473 C 210.214 467.241 210.015 466.658 210.015 466.191 L 210.015 408.52 L 212.696 408.52 L 212.696 428.908 L 225.197 424.83 L 225.594 424.83 C 226.388 424.83 226.984 425.414 226.984 426.344 L 226.984 484.018 L 224.208 484.018 L 224.208 463.63 L 211.702 467.704 C 211.603 467.704 211.405 467.822 211.305 467.822 C 211.007 467.822 210.71 467.704 210.51 467.473 Z M 224.208 434.853 L 212.696 438.581 L 212.696 457.803 L 224.208 453.957 L 224.208 434.853 Z"
                    , SE.onClick (keyMsg KBn 5)
                    ]
                    []
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1555.85498, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "A5" ]
                , Svg.node "rect"
                    [ attribute "x" "172.76"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KA 5)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.310089, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KAn 5)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 1465.756958, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "G5" ]
                , Svg.node "rect"
                    [ attribute "x" "172.756"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.683"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KG 5)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.181049, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KGn 5)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.799 492.73 C 174.38 492.73 170.925 489.175 170.925 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1375.85498, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "F5" ]
                , Svg.node "rect"
                    [ attribute "x" "172.759"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KF 5)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.310089, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KF 5)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1285.85498, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "E5" ]
                , Svg.node "rect"
                    [ attribute "x" "172.756"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KE 5)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.310089, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KEn 5)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1195.85498, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "D5" ]
                , Svg.node "rect"
                    [ attribute "x" "172.753"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KD 5)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.310089, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KDn 5)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1105.85498, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "C5" ]
                , Svg.node "rect"
                    [ attribute "x" "172.75"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KC 5)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.310028, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KCn 5)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "d" "M -470.212 287.097 L -473.931 287.097 Q -474.09 286.182 -474.517 285.471 Q -474.945 284.76 -475.581 284.263 Q -476.218 283.766 -477.028 283.513 Q -477.839 283.259 -478.773 283.259 Q -480.434 283.259 -481.716 284.089 Q -482.999 284.92 -483.725 286.515 Q -484.451 288.111 -484.451 290.408 Q -484.451 292.745 -483.72 294.341 Q -482.989 295.937 -481.711 296.747 Q -480.434 297.557 -478.783 297.557 Q -477.868 297.557 -477.068 297.314 Q -476.267 297.07 -475.626 296.593 Q -474.985 296.116 -474.542 295.42 Q -474.1 294.724 -473.931 293.829 L -470.212 293.849 Q -470.421 295.3 -471.112 296.573 Q -471.803 297.846 -472.917 298.815 Q -474.03 299.785 -475.522 300.327 Q -477.013 300.868 -478.833 300.868 Q -481.517 300.868 -483.625 299.626 Q -485.733 298.383 -486.946 296.036 Q -488.16 293.689 -488.16 290.408 Q -488.16 287.117 -486.937 284.775 Q -485.714 282.434 -483.606 281.191 Q -481.498 279.948 -478.833 279.948 Q -477.133 279.948 -475.671 280.425 Q -474.209 280.903 -473.066 281.822 Q -471.922 282.742 -471.182 284.069 Q -470.441 285.397 -470.212 287.097 Z"
                    , attribute "transform" "matrix(1.055555, 0, 0, 1.240001, 692.847229, 0.51585)"
                    , attribute "style" "white-space: pre;"
                    , SE.onClick (keyMsg KC 5)
                    ]
                    []
                , Svg.node "path"
                    [ attribute "d" "M -459.954 300.868 Q -461.942 300.868 -463.513 300.118 Q -465.084 299.367 -466.004 298.055 Q -466.924 296.742 -466.984 295.052 L -463.404 295.052 Q -463.305 296.305 -462.32 297.095 Q -461.336 297.885 -459.954 297.885 Q -458.87 297.885 -458.025 297.388 Q -457.18 296.891 -456.692 296.006 Q -456.205 295.121 -456.215 293.988 Q -456.205 292.834 -456.702 291.939 Q -457.199 291.045 -458.064 290.532 Q -458.93 290.02 -460.053 290.02 Q -460.968 290.01 -461.853 290.358 Q -462.738 290.707 -463.255 291.273 L -466.586 290.726 L -465.522 280.226 L -453.709 280.226 L -453.709 283.309 L -462.469 283.309 L -463.056 288.708 L -462.937 288.708 Q -462.37 288.042 -461.336 287.599 Q -460.302 287.157 -459.069 287.157 Q -457.219 287.157 -455.768 288.027 Q -454.316 288.897 -453.481 290.418 Q -452.645 291.939 -452.645 293.898 Q -452.645 295.917 -453.575 297.493 Q -454.505 299.069 -456.15 299.969 Q -457.796 300.868 -459.954 300.868 Z"
                    , attribute "transform" "matrix(1.055555, 0, 0, 1.240001, 692.847229, 0.51585)"
                    , attribute "style" "white-space: pre;"
                    , SE.onClick (keyMsg KC 5)
                    ]
                    []
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 1015.756958, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "B4" ]
                , Svg.node "rect"
                    [ attribute "x" "172.746"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.683"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KB 4)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.180988, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KBn 4)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.799 492.73 C 174.38 492.73 170.925 489.175 170.925 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 925.854919, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "A4" ]
                , Svg.node "rect"
                    [ attribute "x" "172.749"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KA 4)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.309952, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KAn 4)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 835.854858, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "G4" ]
                , Svg.node "rect"
                    [ attribute "x" "172.746"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KG 4)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.309887, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KGn 4)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 745.854919, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "F4" ]
                , Svg.node "rect"
                    [ attribute "x" "172.743"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KF 4)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.309948, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KFn 4)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 655.756958, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "E4" ]
                , Svg.node "rect"
                    [ attribute "x" "172.744"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.683"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KE 4)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.180988, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KEn 4)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.799 492.73 C 174.38 492.73 170.925 489.175 170.925 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 565.854919, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "D4" ]
                , Svg.node "rect"
                    [ attribute "x" "172.745"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KD 4)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.309982, 0.211746)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KDn 4)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 475.756927, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "C4" ]
                , Svg.node "rect"
                    [ attribute "x" "172.741"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.683"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KC 4)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.180992, 0.211747)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KCn 4)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "d" "M -470.212 287.097 L -473.931 287.097 Q -474.09 286.182 -474.517 285.471 Q -474.945 284.76 -475.581 284.263 Q -476.218 283.766 -477.028 283.513 Q -477.838 283.259 -478.773 283.259 Q -480.434 283.259 -481.716 284.089 Q -482.999 284.92 -483.725 286.515 Q -484.451 288.111 -484.451 290.408 Q -484.451 292.745 -483.72 294.341 Q -482.989 295.937 -481.711 296.747 Q -480.434 297.557 -478.783 297.557 Q -477.868 297.557 -477.068 297.314 Q -476.267 297.07 -475.626 296.593 Q -474.985 296.116 -474.542 295.42 Q -474.1 294.724 -473.931 293.829 L -470.212 293.849 Q -470.421 295.3 -471.112 296.573 Q -471.803 297.846 -472.917 298.815 Q -474.03 299.785 -475.522 300.327 Q -477.013 300.868 -478.833 300.868 Q -481.517 300.868 -483.625 299.626 Q -485.733 298.383 -486.946 296.036 Q -488.159 293.689 -488.159 290.408 Q -488.159 287.117 -486.936 284.775 Q -485.713 282.434 -483.606 281.191 Q -481.498 279.948 -478.833 279.948 Q -477.133 279.948 -475.671 280.425 Q -474.209 280.902 -473.066 281.822 Q -471.922 282.742 -471.182 284.069 Q -470.441 285.397 -470.212 287.097 Z"
                    , attribute "transform" "matrix(1.055555, 0, 0, 1.240001, 692.355591, 0.51585)"
                    , attribute "style" "white-space: pre;"
                    , SE.onClick (keyMsg KC 4)
                    ]
                    []
                , Svg.node "path"
                    [ attribute "d" "M -467.407 296.812 L -467.407 293.878 L -458.767 280.226 L -456.321 280.226 L -456.321 284.402 L -457.812 284.402 L -463.629 293.62 L -463.629 293.779 L -451.568 293.779 L -451.568 296.812 Z M -457.693 300.59 L -457.693 295.917 L -457.653 294.604 L -457.653 280.226 L -454.173 280.226 L -454.173 300.59 Z"
                    , attribute "transform" "matrix(1.055555, 0, 0, 1.240001, 692.355591, 0.51585)"
                    , attribute "style" "white-space: pre;"
                    , SE.onClick (keyMsg KC 4)
                    ]
                    []
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 385.854919, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "B3" ]
                , Svg.node "rect"
                    [ attribute "x" "172.739"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KB 3)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.072239, -0.042368)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KBn 3)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 295.756927, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "A3" ]
                , Svg.node "rect"
                    [ attribute "x" "172.735"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.683"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KA 3)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.072254, -0.042368)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KAn 3)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.799 492.73 C 174.38 492.73 170.925 489.175 170.925 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 205.854904, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "G3" ]
                , Svg.node "rect"
                    [ attribute "x" "172.738"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KG 3)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.072254, -0.042368)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KGn 3)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 115.854912, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "F3" ]
                , Svg.node "rect"
                    [ attribute "x" "172.735"
                    , attribute "y" "-4.462"
                    , attribute "width" "91.739"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KF 3)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.072254, -0.042368)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KFn 3)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 25.756935, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "E3" ]
                , Svg.node "rect"
                    [ attribute "x" "172.947"
                    , attribute "y" "-4.617"
                    , attribute "width" "91.359"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KE 3)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.07225, -0.042368)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KEn 3)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.134 -5.194 L 266.134 484.73 C 266.134 489.148 262.554 492.73 258.139 492.73 L 178.61 492.73 C 174.194 492.73 170.741 489.175 170.741 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, -64.243065, 5.826072)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "D3" ]
                , Svg.node "rect"
                    [ attribute "x" "172.949"
                    , attribute "y" "-4.617"
                    , attribute "width" "91.359"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KD 3)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1.055555, 0, 0, 1, -41.072258, -0.042368)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KDn 3)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.799 492.73 C 174.38 492.73 170.925 489.175 170.925 484.757"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.99588, 0, 0, 0.803335, -192.993332, 5.792036)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "C3" ]
                , Svg.node "rect"
                    [ attribute "x" "203.763"
                    , attribute "y" "-4.575"
                    , attribute "width" "86.551"
                    , attribute "height" "403.887"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KC 3)
                    ]
                    []
                , Svg.node "path"
                    [ attribute "d" "M -470.212 287.097 L -473.931 287.097 Q -474.09 286.182 -474.517 285.471 Q -474.945 284.76 -475.581 284.263 Q -476.218 283.766 -477.028 283.513 Q -477.839 283.259 -478.773 283.259 Q -480.434 283.259 -481.716 284.089 Q -482.999 284.92 -483.725 286.515 Q -484.451 288.111 -484.451 290.408 Q -484.451 292.745 -483.72 294.341 Q -482.989 295.937 -481.711 296.747 Q -480.434 297.557 -478.783 297.557 Q -477.868 297.557 -477.068 297.314 Q -476.267 297.07 -475.626 296.593 Q -474.985 296.116 -474.542 295.42 Q -474.1 294.724 -473.931 293.829 L -470.212 293.849 Q -470.421 295.3 -471.112 296.573 Q -471.803 297.846 -472.917 298.815 Q -474.03 299.785 -475.522 300.327 Q -477.013 300.868 -478.833 300.868 Q -481.517 300.868 -483.625 299.626 Q -485.733 298.383 -486.946 296.036 Q -488.16 293.689 -488.16 290.408 Q -488.16 287.117 -486.937 284.775 Q -485.714 282.434 -483.606 281.191 Q -481.498 279.948 -478.833 279.948 Q -477.133 279.948 -475.671 280.425 Q -474.209 280.903 -473.066 281.822 Q -471.922 282.742 -471.182 284.069 Q -470.441 285.397 -470.212 287.097 Z"
                    , attribute "transform" "matrix(1, 0, 0, 1.240001, 694.940796, 1.246563)"
                    , attribute "style" "fill: rgb(51, 51, 51); white-space: pre;"
                    , SE.onClick (keyMsg KC 3)
                    ]
                    []
                , Svg.node "path"
                    [ attribute "d" "M -459.731 300.868 Q -461.879 300.868 -463.545 300.133 Q -465.21 299.397 -466.174 298.084 Q -467.139 296.772 -467.199 295.052 L -463.46 295.052 Q -463.41 295.877 -462.913 296.488 Q -462.416 297.1 -461.591 297.438 Q -460.765 297.776 -459.741 297.776 Q -458.648 297.776 -457.802 297.393 Q -456.957 297.01 -456.48 296.324 Q -456.003 295.638 -456.013 294.743 Q -456.003 293.819 -456.49 293.113 Q -456.977 292.407 -457.897 292.009 Q -458.817 291.611 -460.109 291.611 L -461.909 291.611 L -461.909 288.768 L -460.109 288.768 Q -459.045 288.768 -458.245 288.4 Q -457.444 288.032 -456.987 287.361 Q -456.53 286.689 -456.54 285.805 Q -456.53 284.939 -456.922 284.298 Q -457.315 283.657 -458.026 283.299 Q -458.737 282.941 -459.692 282.941 Q -460.626 282.941 -461.422 283.279 Q -462.217 283.617 -462.704 284.238 Q -463.192 284.86 -463.221 285.715 L -466.771 285.715 Q -466.731 284.005 -465.782 282.707 Q -464.832 281.41 -463.241 280.679 Q -461.65 279.948 -459.672 279.948 Q -457.633 279.948 -456.127 280.709 Q -454.621 281.469 -453.795 282.752 Q -452.97 284.035 -452.97 285.586 Q -452.96 287.306 -453.979 288.469 Q -454.998 289.633 -456.649 289.991 L -456.649 290.15 Q -454.501 290.448 -453.353 291.736 Q -452.204 293.023 -452.214 294.932 Q -452.214 296.643 -453.184 297.99 Q -454.153 299.337 -455.849 300.103 Q -457.544 300.868 -459.731 300.868 Z"
                    , attribute "transform" "matrix(1, 0, 0, 1.240001, 694.940796, 1.246563)"
                    , attribute "style" "fill: rgb(51, 51, 51); white-space: pre;"
                    , SE.onClick (keyMsg KC 3)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1, 0, 0, 1, 0.000007, 0)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , attribute "style" "fill: rgb(216, 216, 216); stroke-width: 1.1116px;"
                        , SE.onClick (keyMsg KCn 3)
                        ]
                        []
                    , Svg.node "line"
                        [ attribute "style" "fill: none; paint-order: fill; stroke: rgb(180, 180, 180); stroke-width: 3.05022px;"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "fill: rgb(0, 0, 0);"
                    , attribute "d" "M 241.5 469.375 C 241.219 469.143 241.031 468.56 241.031 468.093 L 241.031 410.422 L 243.569 410.422 L 243.569 430.81 L 255.405 426.732 L 255.781 426.732 C 256.533 426.732 257.097 427.316 257.097 428.246 L 257.097 485.92 L 254.469 485.92 L 254.469 465.532 L 242.628 469.606 C 242.534 469.606 242.347 469.724 242.252 469.724 C 241.97 469.724 241.689 469.606 241.5 469.375 Z M 254.469 436.755 L 243.569 440.483 L 243.569 459.705 L 254.469 455.859 L 254.469 436.755 Z"
                    , SE.onClick (keyMsg KCn 3)
                    ]
                    []
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 200.799 -5.094 L 291.171 -5.094 L 291.171 484.486 C 291.171 488.901 287.761 492.83 283.576 492.83 L 208.378 492.481 C 204.19 492.481 200.799 488.901 200.799 484.486 L 200.799 -5.094 Z"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, -266.321503, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "C#3" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.869"
                    , attribute "y" "35.05"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KCs 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.816"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "146.499"
                    , SE.onClick (keyMsg KDf 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "path"
                    [ attribute "d" "M 357.73 266.363 C 361.821 263.934 364.632 262.258 369.62 262.258 C 372.942 262.258 374.092 262.716 376.522 264.236 C 378.183 265.297 379.589 267.272 379.972 270.008 L 380.486 273.805 C 380.486 278.06 378.439 282.465 374.732 287.324 C 371.791 291.123 369.744 294.009 366.425 297.658 L 355.173 309.658 L 355.173 211.822 L 357.73 211.822 L 357.73 266.363 Z M 366.676 266.97 C 362.588 266.97 360.543 268.489 357.73 271.374 L 357.73 300.847 C 361.694 296.139 364.632 291.883 366.805 288.087 C 369.491 283.225 370.897 279.121 370.897 275.324 C 370.897 273.958 371.024 272.896 371.024 272.285 C 371.024 270.159 370.64 269.097 369.62 267.727 L 368.595 267.272 L 366.676 266.97 Z"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KDf 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Flat" ]
                    ]
                , Svg.node "path"
                    [ attribute "d" "M 372.647 80.883 L 372.647 55.321 L 374.829 55.321 L 374.829 80.128 L 380.486 78.011 L 380.486 91.775 L 374.829 93.892 L 374.829 118.85 L 380.486 117.037 L 380.486 130.801 L 374.829 132.768 L 374.829 156.213 L 372.647 156.213 L 372.647 133.523 L 362.881 136.852 L 362.881 160.295 L 360.7 160.295 L 360.7 137.759 L 355.173 139.725 L 355.173 126.113 L 360.7 123.993 L 360.7 98.733 L 355.173 100.848 L 355.173 86.934 L 360.7 84.97 L 360.7 59.404 L 362.881 59.404 L 362.881 84.059 L 372.647 80.883 Z M 362.881 97.976 L 362.881 123.238 L 372.647 119.909 L 372.647 94.494 L 362.881 97.976 Z"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KCs 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Sharp" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, -176.321503, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "D#3" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.861"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KDs 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.808"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KEf 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 3.678497, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "F#3" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.86"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KFs 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.807"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KGf 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 93.678497, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "G#3" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.857"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KGs 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.804"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KAf 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 183.678497, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "A#3" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.854"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KAs 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.801"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KBf 3)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 363.678497, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "C#4" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.848"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KCs 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.795"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KDf 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 453.678497, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "D#4" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.845"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KDs 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.792"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KEf 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 633.678467, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "F#4" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.839"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KFs 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.786"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KGf 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 723.678467, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "G#4" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.836"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KGs 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.783"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KAf 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 813.678467, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "A#4" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.833"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KAs 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.78"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KBf 4)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 993.678467, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "C#5" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.827"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KCs 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.774"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KDf 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 1083.678467, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "D#5" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.824"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KDs 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.771"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KEf 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 1263.678467, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "F#5" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.818"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KFs 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.765"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KGf 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 1353.678467, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "G#5" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.815"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KGs 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.762"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KAf 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 1443.678467, -28.770775)" ]
                [ Svg.node "title"
                    []
                    [ Svg.text "A#5" ]
                , Svg.node "path"
                    [ attribute "style" "stroke-width: 0px;"
                    , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
                    ]
                    []
                , Svg.node "rect"
                    [ attribute "x" "337.812"
                    , attribute "y" "34.797"
                    , attribute "width" "60.012"
                    , attribute "height" "151.347"
                    , SE.onClick (keyMsg KAs 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Upper" ]
                    ]
                , Svg.node "rect"
                    [ attribute "x" "337.759"
                    , attribute "y" "189.016"
                    , attribute "width" "60.012"
                    , attribute "height" "142.348"
                    , SE.onClick (keyMsg KBf 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Lower" ]
                    ]
                , Svg.node "line"
                    [ attribute "style" "stroke: rgb(120, 120, 120); stroke-width: 3px;"
                    , attribute "x1" "337.687"
                    , attribute "y1" "187.513"
                    , attribute "x2" "398.211"
                    , attribute "y2" "187.513"
                    ]
                    []
                , Svg.node "path"
                    [ attribute "d" "M 358.408 267.109 C 362.499 264.68 365.31 263.004 370.298 263.004 C 373.62 263.004 374.77 263.462 377.2 264.982 C 378.861 266.043 380.267 268.018 380.65 270.754 L 381.164 274.551 C 381.164 278.806 379.117 283.211 375.41 288.07 C 372.469 291.869 370.422 294.755 367.103 298.404 L 355.851 310.404 L 355.851 212.568 L 358.408 212.568 L 358.408 267.109 Z M 367.354 267.716 C 363.266 267.716 361.221 269.235 358.408 272.12 L 358.408 301.593 C 362.372 296.885 365.31 292.629 367.483 288.833 C 370.169 283.971 371.575 279.867 371.575 276.07 C 371.575 274.704 371.702 273.642 371.702 273.031 C 371.702 270.905 371.318 269.843 370.298 268.473 L 369.273 268.018 L 367.354 267.716 Z"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KBf 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Flat" ]
                    ]
                , Svg.node "path"
                    [ attribute "d" "M 373.325 81.629 L 373.325 56.067 L 375.507 56.067 L 375.507 80.874 L 381.164 78.757 L 381.164 92.521 L 375.507 94.638 L 375.507 119.596 L 381.164 117.783 L 381.164 131.547 L 375.507 133.514 L 375.507 156.959 L 373.325 156.959 L 373.325 134.269 L 363.559 137.598 L 363.559 161.041 L 361.378 161.041 L 361.378 138.505 L 355.851 140.471 L 355.851 126.859 L 361.378 124.739 L 361.378 99.479 L 355.851 101.594 L 355.851 87.68 L 361.378 85.716 L 361.378 60.15 L 363.559 60.15 L 363.559 84.805 L 373.325 81.629 Z M 363.559 98.722 L 363.559 123.984 L 373.325 120.655 L 373.325 95.24 L 363.559 98.722 Z"
                    , attribute "style" "fill: rgb(255, 255, 255);"
                    , SE.onClick (keyMsg KAs 5)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text "Sharp" ]
                    ]
                ]
            ]
        ]
