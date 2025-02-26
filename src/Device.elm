module Device exposing (DeviceView(..), detectDevice, detectView, isMobileView, setDevice, setWindow)

import Element exposing (Device, DeviceClass(..), Orientation(..), classifyDevice)


type DeviceView
    = MobileView
    | DesktopView


detectDevice : Int -> Int -> Device
detectDevice width height =
    classifyDevice { height = height, width = width }


setDevice : Device -> { a | device : Device } -> { a | device : Device }
setDevice newDevice oldRecord =
    { oldRecord | device = newDevice }


setWindow : ( Int, Int ) -> { a | window : ( Int, Int ) } -> { a | window : ( Int, Int ) }
setWindow newWindow oldRecord =
    { oldRecord | window = newWindow }


detectView : Bool -> Device -> DeviceView
detectView isFramed device =
    if isMobileView isFramed device then
        MobileView

    else
        DesktopView


isMobileView : Bool -> Device -> Bool
isMobileView isFramed { class, orientation } =
    if isFramed then
        False

    else
        case ( class, orientation ) of
            ( Phone, _ ) ->
                True

            ( Tablet, Portrait ) ->
                True

            _ ->
                False
