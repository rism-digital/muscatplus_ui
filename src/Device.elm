module Device exposing (detectDevice, setDevice, setWindow)

import Element exposing (Device, classifyDevice)


detectDevice : Int -> Int -> Device
detectDevice width height =
    classifyDevice { height = height, width = width }


setDevice : Device -> { a | device : Device } -> { a | device : Device }
setDevice newDevice oldRecord =
    { oldRecord | device = newDevice }


setWindow : ( Int, Int ) -> { a | window : ( Int, Int ) } -> { a | window : ( Int, Int ) }
setWindow newWindow oldRecord =
    { oldRecord | window = newWindow }
