module Device exposing (detectDevice, isMobileView, setDevice, setWindow)

import Element exposing (Device, DeviceClass(..), Orientation(..), classifyDevice)


detectDevice : Int -> Int -> Device
detectDevice width height =
    classifyDevice { height = height, width = width }


setDevice : Device -> { a | device : Device } -> { a | device : Device }
setDevice newDevice oldRecord =
    { oldRecord | device = newDevice }


setWindow : ( Int, Int ) -> { a | window : ( Int, Int ) } -> { a | window : ( Int, Int ) }
setWindow newWindow oldRecord =
    { oldRecord | window = newWindow }


isMobileView : Device -> Bool
isMobileView { class, orientation } =
    case ( class, orientation ) of
        ( Phone, _ ) ->
            True

        ( Tablet, Portrait ) ->
            True

        ( _, _ ) ->
            False
