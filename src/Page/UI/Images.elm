module Page.UI.Images exposing (..)

import Element exposing (Element, html)
import Svg exposing (Svg, defs, g, metadata, svg)
import Svg.Attributes exposing (d, fill, height, id, style, transform, version, viewBox, width)


{-|

    The logo is square, so the same value is used for width and height.

    The colour is, for now, simply a hex string value (including the leading "#")

-}
rismLogo : String -> Int -> Element msg
rismLogo colour size =
    html
        (svg
            [ width (String.fromInt size)
            , height (String.fromInt size)
            , viewBox "0 0 84.666663 84.66667"
            , version "1.1"
            , id "svg869"
            ]
            [ defs
                [ id "defs863" ]
                []
            , metadata
                [ id "metadata866" ]
                []
            , g
                [ id "layer1" ]
                [ g
                    [ transform "matrix(0.26458333,0,0,0.26458333,0.37478274,10.687235)"
                    , id "g20"
                    ]
                    [ Svg.path
                        [ style ("fill:" ++ colour ++ ";fill-opacity:1")
                        , id "path10"
                        , d "m 245.48,169.456 c -75.086,123.436 -138.273,33.89 -162.733,-3.441 -0.183,-0.47 -0.484,-0.933 -0.889,-1.363 -5.5,-8.523 -7.298,-11.24 -7.298,-11.24 -0.591,-0.661 -3.041,-5.026 -3.489,-5.698 -1.329,-2.16 -2.537,-3.987 -4.023,-6.193 -2.82,-4.188 -6.111,-9.359 -9.871,-15.513 -2.479,-4.103 -4.189,-6.836 -5.128,-8.204 2.051,-0.597 4.058,-1.538 6.025,-2.82 3.846,-2.648 6.879,-6.174 9.102,-10.577 2.222,-4.401 3.334,-9.08 3.334,-14.038 0,-4.615 -1.048,-9.122 -3.141,-13.525 -2.095,-4.4 -5.192,-7.84 -9.295,-10.32 -2.564,-1.538 -5.727,-2.734 -9.486,-3.589 -3.762,-0.853 -7.137,-1.282 -10.128,-1.282 -2.48,0 -6.198,0.172 -11.153,0.513 -5.557,0.428 -9.788,0.641 -12.692,0.641 -2.051,0 -4.317,-0.064 -6.795,-0.193 -2.48,-0.128 -4.957,-0.32 -7.435,-0.577 v 1.154 c 2.99,1.625 5.021,3.506 6.089,5.641 1.068,2.137 1.687,4.743 1.859,7.82 0.341,6.41 0.597,13.034 0.769,19.871 0.171,6.839 0.257,13.547 0.257,20.127 0,17.264 -0.086,30.212 -0.257,38.844 -0.086,2.394 -1.005,4.551 -2.756,6.474 -1.753,1.924 -3.868,3.525 -6.346,4.808 v 1.154 c 1.965,-0.171 4.359,-0.321 7.179,-0.449 2.821,-0.128 5.385,-0.192 7.692,-0.192 4.103,0 8.93,0.214 14.487,0.642 v -1.026 c -2.65,-1.196 -4.531,-2.648 -5.641,-4.359 -1.112,-1.708 -1.795,-4.313 -2.051,-7.819 -0.685,-10.169 -1.026,-21.621 -1.026,-34.357 1.11,0 2.734,-0.128 4.872,-0.385 2.307,-0.17 3.888,-0.256 4.743,-0.256 h 6.795 c 2.307,2.563 4.443,5.235 6.41,8.012 1.965,2.779 4.529,6.603 7.692,11.474 2.277,3.501 4.325,6.542 6.188,9.212 109.779,187.675 188.815,26.188 188.815,26.188 1.792,-2.692 -0.675,-5.159 -0.675,-5.159 z M 32.691,113.957 c -0.685,0 -2.394,0 -5.128,0 -3.163,0.086 -5.471,0.128 -6.923,0.128 0,-12.391 0.042,-20.468 0.128,-24.229 0,-3.161 0.042,-5.641 0.129,-7.436 0.084,-1.795 0.17,-3.545 0.256,-5.256 0,-0.427 0.042,-1.324 0.128,-2.692 0.084,-3.077 0.427,-5.256 1.026,-6.538 0.513,-0.085 1.324,-0.171 2.436,-0.257 2.82,-0.256 5.041,-0.384 6.666,-0.384 3.503,0 6.644,0.214 9.423,0.641 2.776,0.428 5.192,1.326 7.243,2.692 2.99,2.051 5.34,4.807 7.051,8.269 1.708,3.461 2.564,6.986 2.564,10.576 0,8.547 -1.839,14.765 -5.513,18.653 -3.676,3.89 -10.172,5.833 -19.486,5.833 z"
                        , fill colour
                        ]
                        []
                    , Svg.path
                        [ style ("fill:" ++ colour ++ ";fill-opacity:1")
                        , id "path12"
                        , d "m 87.253,167.8 v -1.025 c 2.135,-1.11 3.888,-2.648 5.256,-4.615 1.366,-1.965 2.093,-4.23 2.18,-6.795 0.17,-8.631 0.256,-21.579 0.256,-38.843 0,-6.58 -0.086,-13.289 -0.256,-20.127 C 94.516,89.558 94.26,82.934 93.919,76.524 93.747,73.447 93.17,70.735 92.189,68.383 91.205,66.034 89.304,63.918 86.484,62.037 V 61.14 c 5.641,0.513 10.212,0.769 13.717,0.769 2.051,0 5,-0.17 8.846,-0.513 2.051,-0.084 3.632,-0.17 4.743,-0.256 v 0.897 c -2.393,1.198 -4.102,3.141 -5.128,5.833 -1.025,2.693 -1.666,5.749 -1.923,9.167 -0.086,1.794 -0.172,3.633 -0.256,5.512 -0.086,1.881 -0.128,4.531 -0.128,7.949 -0.086,4.018 -0.128,12.563 -0.128,25.639 0,11.967 0.34,24.786 1.025,38.46 0.17,2.819 0.875,5.277 2.115,7.37 1.238,2.097 3.097,3.698 5.577,4.809 v 1.025 c -5.557,-0.427 -10.384,-0.641 -14.486,-0.641 -4.103,-0.001 -8.506,0.213 -13.205,0.64 z"
                        , fill colour
                        ]
                        []
                    , Svg.path
                        [ style ("fill:" ++ colour ++ ";fill-opacity:1")
                        , id "path14"
                        , d "m 141.407,167.929 c -2.48,-0.514 -5.556,-1.324 -9.23,-2.437 -2.137,-0.597 -3.249,-0.896 -3.333,-0.896 -1.539,-0.428 -2.563,-1.282 -3.077,-2.564 -0.514,-1.282 -0.769,-3.077 -0.769,-5.385 l -0.128,-1.025 c -0.257,-1.623 -0.471,-3.183 -0.641,-4.68 -0.173,-1.494 -0.257,-2.926 -0.257,-4.294 0,-1.026 0.193,-2.029 0.577,-3.014 0.385,-0.98 0.918,-1.474 1.603,-1.474 0.17,0 0.512,0.728 1.025,2.179 0.597,1.796 1.238,3.442 1.923,4.937 0.683,1.496 1.581,2.928 2.692,4.294 2.052,2.479 5.148,4.638 9.295,6.475 4.144,1.838 7.712,2.756 10.704,2.756 2.222,0 4.529,-0.404 6.923,-1.218 2.393,-0.811 4.593,-2.007 6.603,-3.59 2.008,-1.58 3.632,-3.545 4.872,-5.896 1.237,-2.35 1.858,-5.021 1.858,-8.013 0,-2.904 -0.577,-5.597 -1.73,-8.077 -1.154,-2.478 -2.715,-4.784 -4.68,-6.923 -1.967,-2.135 -4.102,-4.08 -6.41,-5.833 -2.308,-1.75 -5.213,-3.822 -8.718,-6.216 -3.761,-2.564 -6.838,-4.764 -9.23,-6.602 -2.394,-1.837 -4.637,-3.889 -6.73,-6.154 -2.096,-2.264 -3.762,-4.763 -5,-7.5 -1.24,-2.734 -1.859,-5.725 -1.859,-8.974 0,-3.333 0.555,-6.58 1.667,-9.743 1.109,-3.161 2.798,-6.045 5.063,-8.653 2.264,-2.606 5.148,-4.679 8.654,-6.218 3.503,-1.538 7.52,-2.307 12.051,-2.307 1.794,0 4.571,0.342 8.333,1.025 3.673,0.769 6.409,1.154 8.204,1.154 0.769,0 1.709,-0.212 2.821,-0.641 1.281,-0.513 2.391,-0.769 3.333,-0.769 0.513,0 0.769,0.384 0.769,1.154 0,2.223 0.212,5.342 0.641,9.358 0.342,3.846 0.514,6.753 0.514,8.718 0,0.428 -0.108,0.897 -0.321,1.41 -0.214,0.513 -0.448,0.769 -0.705,0.769 -0.599,0 -1.624,-1.366 -3.077,-4.102 -0.769,-1.539 -1.496,-2.821 -2.179,-3.846 -0.685,-1.026 -1.41,-1.879 -2.179,-2.564 -2.309,-2.051 -5.108,-3.568 -8.397,-4.551 -3.291,-0.982 -6.39,-1.475 -9.295,-1.475 -1.881,0 -3.782,0.385 -5.705,1.154 -1.923,0.769 -3.653,1.839 -5.192,3.205 -1.538,1.368 -2.778,2.929 -3.718,4.679 -0.941,1.753 -1.41,3.57 -1.41,5.449 0,2.48 0.533,4.829 1.603,7.051 1.068,2.223 2.542,4.339 4.423,6.346 1.879,2.009 3.846,3.804 5.897,5.384 2.051,1.583 4.914,3.698 8.589,6.346 3.93,2.82 7.179,5.236 9.743,7.243 2.563,2.009 4.978,4.275 7.243,6.795 2.264,2.521 4.08,5.3 5.448,8.332 1.366,3.034 2.093,6.304 2.18,9.808 0,3.932 -0.686,7.714 -2.052,11.345 -1.368,3.634 -3.44,6.881 -6.217,9.744 -2.779,2.864 -6.262,5.128 -10.449,6.794 -4.188,1.667 -9.018,2.5 -14.486,2.5 v 0 c -2.907,-0.002 -5.599,-0.258 -8.077,-0.77 z"
                        , fill colour
                        ]
                        []
                    , Svg.path
                        [ style ("fill:" ++ colour ++ ";fill-opacity:1")
                        , id "path16"
                        , d "m 306.142,153.826 c 0.514,3.077 1.773,5.749 3.782,8.012 2.007,2.267 4.423,3.997 7.243,5.192 v 0.898 c -4.701,-0.77 -9.402,-1.154 -14.102,-1.154 -5.043,0 -10.085,0.385 -15.127,1.154 v -0.77 c 0,-0.597 0.641,-1.282 1.923,-2.052 1.109,-0.684 1.986,-1.41 2.628,-2.179 0.641,-0.77 0.961,-1.88 0.961,-3.333 0,-0.171 -0.044,-0.342 -0.128,-0.514 0,-0.256 0,-0.469 0,-0.641 l -8.845,-64.997 h -0.771 l -30.639,73.585 c -0.344,0.94 -0.728,1.411 -1.154,1.411 -0.343,0 -0.897,-0.6 -1.667,-1.795 -0.256,-0.428 -0.599,-1.026 -1.025,-1.795 -0.429,-0.77 -1.176,-2.309 -2.244,-4.615 -1.068,-2.308 -2.242,-4.808 -3.524,-7.5 -1.282,-2.692 -3.205,-6.687 -5.77,-11.986 -0.854,-1.795 -8.291,-17.263 -22.307,-46.407 l -1.154,0.384 -7.691,58.715 c -0.086,0.599 -0.128,1.497 -0.128,2.691 0,2.564 0.555,4.725 1.667,6.476 1.109,1.752 2.903,3.14 5.384,4.166 l 0.385,1.025 c -1.539,-0.257 -3.826,-0.448 -6.858,-0.576 -3.035,-0.13 -5.576,-0.193 -7.629,-0.193 -3.846,0 -7.649,0.257 -11.408,0.77 l 0.641,-0.77 c 2.904,-0.939 5.298,-2.926 7.179,-5.961 1.879,-3.033 3.077,-6.558 3.589,-10.576 L 209.61,74.725 c 0,-4.956 0,-13.204 4.614,-13.204 l 38.076,82.943 2.308,0.13 28.717,-68.074 6.281,-14.999 c 1.879,0 4.699,-0.129 8.461,-0.385 1.623,-0.084 2.99,-0.17 4.103,-0.256 v 0.897 c -2.223,1.112 -4.018,2.949 -5.384,5.513 -1.369,2.564 -2.052,5.086 -2.052,7.563 0,0.257 0,0.599 0,1.026 0.084,0.429 0.129,0.727 0.129,0.897 z"
                        , fill colour
                        ]
                        []
                    , Svg.path
                        [ style ("fill:" ++ colour ++ ";fill-opacity:1")
                        , id "path18"
                        , d "m 156.493,8.148 c 0,0 -56.505,7.765 -82.428,68.571 L 70.481,60.114 c 0,0 15.172,-61.523 114.802,-60.089 0,0 82.308,4.181 82.905,74.543 0,0 -6.928,-79.56 -111.695,-66.42 z"
                        , fill colour
                        ]
                        []
                    ]
                ]
            ]
        )


type alias SvgDetails =
    { viewBox : String
    , path : String
    }


makeSvgIcon : SvgDetails -> Element msg
makeSvgIcon details =
    html
        (svg
            [ viewBox details.viewBox ]
            [ Svg.path
                [ d details.path
                , fill "LightSlateGray"
                ]
                []
            ]
        )


{-|

    The string variant is useful if the SVG is needed for embedding in a
    CSS string.

-}
makeStringIcon : SvgDetails -> String
makeStringIcon details =
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"" ++ details.viewBox ++ "\"><path d=\"" ++ details.path ++ "\" fill=\"LightSlateGray\"/></svg>"


chevronDown : SvgDetails
chevronDown =
    { viewBox = "0 0 448 512"
    , path = "M207.029 381.476L12.686 187.132c-9.373-9.373-9.373-24.569 0-33.941l22.667-22.667c9.357-9.357 24.522-9.375 33.901-.04L224 284.505l154.745-154.021c9.379-9.335 24.544-9.317 33.901.04l22.667 22.667c9.373 9.373 9.373 24.569 0 33.941L240.971 381.476c-9.373 9.372-24.569 9.372-33.942 0z"
    }


chevronDownSvg : Element msg
chevronDownSvg =
    makeSvgIcon chevronDown


chevronDownString : String
chevronDownString =
    makeStringIcon chevronDown


chevronUp : SvgDetails
chevronUp =
    { viewBox = "0 0 448 512"
    , path = "M240.971 130.524l194.343 194.343c9.373 9.373 9.373 24.569 0 33.941l-22.667 22.667c-9.357 9.357-24.522 9.375-33.901.04L224 227.495 69.255 381.516c-9.379 9.335-24.544 9.317-33.901-.04l-22.667-22.667c-9.373-9.373-9.373-24.569 0-33.941L207.03 130.525c9.372-9.373 24.568-9.373 33.941-.001z"
    }


chevronUpSvg : Element msg
chevronUpSvg =
    makeSvgIcon chevronUp


chevronUpString : String
chevronUpString =
    makeStringIcon chevronUp


chevronLeft : SvgDetails
chevronLeft =
    { viewBox = "0 0 320 512"
    , path = "M34.52 239.03L228.87 44.69c9.37-9.37 24.57-9.37 33.94 0l22.67 22.67c9.36 9.36 9.37 24.52.04 33.9L131.49 256l154.02 154.75c9.34 9.38 9.32 24.54-.04 33.9l-22.67 22.67c-9.37 9.37-24.57 9.37-33.94 0L34.52 272.97c-9.37-9.37-9.37-24.57 0-33.94z"
    }


chevronLeftSvg : Element msg
chevronLeftSvg =
    makeSvgIcon chevronLeft


chevronLeftString : String
chevronLeftString =
    makeStringIcon chevronLeft


chevronRight : SvgDetails
chevronRight =
    { viewBox = "0 0 320 512"
    , path = "M285.476 272.971L91.132 467.314c-9.373 9.373-24.569 9.373-33.941 0l-22.667-22.667c-9.357-9.357-9.375-24.522-.04-33.901L188.505 256 34.484 101.255c-9.335-9.379-9.317-24.544.04-33.901l22.667-22.667c9.373-9.373 24.569-9.373 33.941 0L285.475 239.03c9.373 9.372 9.373 24.568.001 33.941z"
    }


chevronRightSvg : Element msg
chevronRightSvg =
    makeSvgIcon chevronRight


chevronRightString : String
chevronRightString =
    makeStringIcon chevronRight


chevronDoubleRight : SvgDetails
chevronDoubleRight =
    { viewBox = "0 0 512 512"
    , path = "M477.5 273L283.1 467.3c-9.4 9.4-24.6 9.4-33.9 0l-22.7-22.7c-9.4-9.4-9.4-24.5 0-33.9l154-154.7-154-154.7c-9.3-9.4-9.3-24.5 0-33.9l22.7-22.7c9.4-9.4 24.6-9.4 33.9 0L477.5 239c9.3 9.4 9.3 24.6 0 34zm-192-34L91.1 44.7c-9.4-9.4-24.6-9.4-33.9 0L34.5 67.4c-9.4 9.4-9.4 24.5 0 33.9l154 154.7-154 154.7c-9.3 9.4-9.3 24.5 0 33.9l22.7 22.7c9.4 9.4 24.6 9.4 33.9 0L285.5 273c9.3-9.4 9.3-24.6 0-34z"
    }


chevronDoubleRightSvg : Element msg
chevronDoubleRightSvg =
    makeSvgIcon chevronDoubleRight


chevronDoubleRightString : String
chevronDoubleRightString =
    makeStringIcon chevronDoubleRight


chevronDoubleLeft : SvgDetails
chevronDoubleLeft =
    { viewBox = "0 0 512 512"
    , path = "M34.5 239L228.9 44.7c9.4-9.4 24.6-9.4 33.9 0l22.7 22.7c9.4 9.4 9.4 24.5 0 33.9L131.5 256l154 154.7c9.3 9.4 9.3 24.5 0 33.9l-22.7 22.7c-9.4 9.4-24.6 9.4-33.9 0L34.5 273c-9.3-9.4-9.3-24.6 0-34zm192 34l194.3 194.3c9.4 9.4 24.6 9.4 33.9 0l22.7-22.7c9.4-9.4 9.4-24.5 0-33.9L323.5 256l154-154.7c9.3-9.4 9.3-24.5 0-33.9l-22.7-22.7c-9.4-9.4-24.6-9.4-33.9 0L226.5 239c-9.3 9.4-9.3 24.6 0 34z"
    }


chevronDoubleLeftSvg : Element msg
chevronDoubleLeftSvg =
    makeSvgIcon chevronDoubleLeft


chevronDoubleLeftString : String
chevronDoubleLeftString =
    makeStringIcon chevronDoubleLeft


bookOpen : SvgDetails
bookOpen =
    { viewBox = "0 0 640 512"
    , path = "M561.91 0C549.44 0 406.51 6.49 320 56.89 233.49 6.49 90.56 0 78.09 0 35.03 0 0 34.34 0 76.55v313.72c0 40.73 32.47 74.3 73.92 76.41 36.78 1.91 128.81 9.5 187.73 38.69 8.19 4.05 17.25 6.29 26.34 6.58v.05h64.02v-.05c9.09-.29 18.15-2.53 26.34-6.58 58.92-29.19 150.95-36.78 187.73-38.69C607.53 464.57 640 431 640 390.27V76.55C640 34.34 604.97 0 561.91 0zM296 438.15c0 11.09-10.96 18.91-21.33 14.96-64.53-24.54-153.96-32.07-198.31-34.38-15.9-.8-28.36-13.3-28.36-28.46V76.55C48 60.81 61.5 48 78.06 48c19.93.1 126.55 7.81 198.53 40.49 11.63 5.28 19.27 16.66 19.28 29.44L296 224v214.15zm296-47.88c0 15.16-12.46 27.66-28.36 28.47-44.35 2.3-133.78 9.83-198.31 34.38-10.37 3.94-21.33-3.87-21.33-14.96V224l.14-106.08c.02-12.78 7.65-24.15 19.28-29.44C435.4 55.81 542.02 48.1 561.94 48 578.5 48 592 60.81 592 76.55v313.72z"
    }


bookOpenSvg : Element msg
bookOpenSvg =
    makeSvgIcon bookOpen


sources : SvgDetails
sources =
    { viewBox = "0 0 576 512"
    , path = "M575.46 454.59L458.55 11.86c-2.28-8.5-11.1-13.59-19.6-11.31L423.5 4.68c-7.54 2.02-12.37 9.11-11.83 16.53-11.47 7.42-64.22 21.55-77.85 20.86-3.24-6.69-10.97-10.42-18.5-8.4L304 36.7V32c0-17.67-14.33-32-40-32H24C14.33 0 0 14.33 0 32v448c0 17.67 14.33 32 24 32h240c25.67 0 40-14.33 40-32V115.94l101.45 384.2c2.28 8.5 11.1 13.59 19.6 11.31l15.46-4.14c7.54-2.02 12.37-9.11 11.83-16.52 11.47-7.42 64.21-21.55 77.85-20.86 3.24 6.69 10.97 10.42 18.5 8.4l15.46-4.14c8.49-2.28 13.58-11.1 11.31-19.6zM128 464H48v-48h80v48zm0-96H48V144h80v224zm0-272H48V48h80v48zm128 368h-80v-48h80v48zm0-96h-80V144h80v224zm0-272h-80V48h80v48zm185.98 355.01L344.74 81.69c16.76-1.8 60.74-13.39 77.28-20.71l97.24 369.32c-16.76 1.81-60.74 13.4-77.28 20.71z"
    }


sourcesSvg : Element msg
sourcesSvg =
    makeSvgIcon sources


people : SvgDetails
people =
    { viewBox = "0 0 640 512"
    , path = "M192 256c61.9 0 112-50.1 112-112S253.9 32 192 32 80 82.1 80 144s50.1 112 112 112zm76.8 32h-8.3c-20.8 10-43.9 16-68.5 16s-47.6-6-68.5-16h-8.3C51.6 288 0 339.6 0 403.2V432c0 26.5 21.5 48 48 48h288c26.5 0 48-21.5 48-48v-28.8c0-63.6-51.6-115.2-115.2-115.2zM480 256c53 0 96-43 96-96s-43-96-96-96-96 43-96 96 43 96 96 96zm48 32h-3.8c-13.9 4.8-28.6 8-44.2 8s-30.3-3.2-44.2-8H432c-20.4 0-39.2 5.9-55.7 15.4 24.4 26.3 39.7 61.2 39.7 99.8v38.4c0 2.2-.5 4.3-.6 6.4H592c26.5 0 48-21.5 48-48 0-61.9-50.1-112-112-112z"
    }


peopleSvg : Element msg
peopleSvg =
    makeSvgIcon people


institution : SvgDetails
institution =
    { viewBox = "0 0 512 512"
    , path = "M501.62 92.11L267.24 2.04a31.958 31.958 0 0 0-22.47 0L10.38 92.11A16.001 16.001 0 0 0 0 107.09V144c0 8.84 7.16 16 16 16h480c8.84 0 16-7.16 16-16v-36.91c0-6.67-4.14-12.64-10.38-14.98zM64 192v160H48c-8.84 0-16 7.16-16 16v48h448v-48c0-8.84-7.16-16-16-16h-16V192h-64v160h-96V192h-64v160h-96V192H64zm432 256H16c-8.84 0-16 7.16-16 16v32c0 8.84 7.16 16 16 16h480c8.84 0 16-7.16 16-16v-32c0-8.84-7.16-16-16-16z"
    }


institutionSvg : Element msg
institutionSvg =
    makeSvgIcon institution


musicNotation : SvgDetails
musicNotation =
    { viewBox = "0 0 512 512"
    , path = "M470.38 1.51L150.41 96A32 32 0 0 0 128 126.51v261.41A139 139 0 0 0 96 384c-53 0-96 28.66-96 64s43 64 96 64 96-28.66 96-64V214.32l256-75v184.61a138.4 138.4 0 0 0-32-3.93c-53 0-96 28.66-96 64s43 64 96 64 96-28.65 96-64V32a32 32 0 0 0-41.62-30.49z"
    }


musicNotationSvg : Element msg
musicNotationSvg =
    makeSvgIcon musicNotation


unknown : SvgDetails
unknown =
    { viewBox = "0 0 384 512"
    , path = "M202.021 0C122.202 0 70.503 32.703 29.914 91.026c-7.363 10.58-5.093 25.086 5.178 32.874l43.138 32.709c10.373 7.865 25.132 6.026 33.253-4.148 25.049-31.381 43.63-49.449 82.757-49.449 30.764 0 68.816 19.799 68.816 49.631 0 22.552-18.617 34.134-48.993 51.164-35.423 19.86-82.299 44.576-82.299 106.405V320c0 13.255 10.745 24 24 24h72.471c13.255 0 24-10.745 24-24v-5.773c0-42.86 125.268-44.645 125.268-160.627C377.504 66.256 286.902 0 202.021 0zM192 373.459c-38.196 0-69.271 31.075-69.271 69.271 0 38.195 31.075 69.27 69.271 69.27s69.271-31.075 69.271-69.271-31.075-69.27-69.271-69.27z"
    }


unknownSvg : Element msg
unknownSvg =
    makeSvgIcon unknown


liturgicalFestival : SvgDetails
liturgicalFestival =
    { viewBox = "0 0 512 512"
    , path = "M288 167.2v-28.1c-28.2-36.3-47.1-79.3-54.1-125.2-2.1-13.5-19-18.8-27.8-8.3-21.1 24.9-37.7 54.1-48.9 86.5 34.2 38.3 80 64.6 130.8 75.1zM400 64c-44.2 0-80 35.9-80 80.1v59.4C215.6 197.3 127 133 87 41.8c-5.5-12.5-23.2-13.2-29-.9C41.4 76 32 115.2 32 156.6c0 70.8 34.1 136.9 85.1 185.9 13.2 12.7 26.1 23.2 38.9 32.8l-143.9 36C1.4 414-3.4 426.4 2.6 435.7 20 462.6 63 508.2 155.8 512c8 .3 16-2.6 22.1-7.9l65.2-56.1H320c88.4 0 160-71.5 160-159.9V128l32-64H400zm0 96.1c-8.8 0-16-7.2-16-16s7.2-16 16-16 16 7.2 16 16-7.2 16-16 16z"
    }


liturgicalFestivalSvg : Element msg
liturgicalFestivalSvg =
    makeSvgIcon liturgicalFestival


digitizedImages : SvgDetails
digitizedImages =
    { viewBox = "0 0 576 512"
    , path = "M480 416v16c0 26.51-21.49 48-48 48H48c-26.51 0-48-21.49-48-48V176c0-26.51 21.49-48 48-48h16v48H54a6 6 0 0 0-6 6v244a6 6 0 0 0 6 6h372a6 6 0 0 0 6-6v-10h48zm42-336H150a6 6 0 0 0-6 6v244a6 6 0 0 0 6 6h372a6 6 0 0 0 6-6V86a6 6 0 0 0-6-6zm6-48c26.51 0 48 21.49 48 48v256c0 26.51-21.49 48-48 48H144c-26.51 0-48-21.49-48-48V80c0-26.51 21.49-48 48-48h384zM264 144c0 22.091-17.909 40-40 40s-40-17.909-40-40 17.909-40 40-40 40 17.909 40 40zm-72 96l39.515-39.515c4.686-4.686 12.284-4.686 16.971 0L288 240l103.515-103.515c4.686-4.686 12.284-4.686 16.971 0L480 208v80H192v-48z"
    }


digitizedImagesSvg : Element msg
digitizedImagesSvg =
    makeSvgIcon digitizedImages
