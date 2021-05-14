module Device exposing (..)

import Element exposing (Device, classifyDevice)


detectDevice : Int -> Int -> Device
detectDevice width height =
    classifyDevice { height = height, width = width }
