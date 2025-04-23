module Page.About exposing (Model, Msg, init, initialCmd, update)

import Json.Decode as Decode
import Page.About.Model exposing (AboutPageModel)
import Page.About.Msg exposing (AboutMsg(..))
import Page.Decoders exposing (aboutResponseDecoder)
import Page.RecordTypes.About exposing (aboutBodyDecoder)
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Request exposing (createRequest)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Url exposing (Url)


type alias Model =
    AboutPageModel


type alias Msg =
    AboutMsg


init : Session -> Model
init session =
    { response = Loading Nothing
    , linksEnabled = session.showMuscatLinks
    }


initialCmd : Url -> Cmd Msg
initialCmd initialUrl =
    createRequest ServerRespondedWithAboutData (Decode.map AboutData aboutBodyDecoder) (Url.toString initialUrl)


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update _ msg model =
    case msg of
        ServerRespondedWithAboutData (Ok ( _, response )) ->
            ( { model
                | response = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithAboutData (Err error) ->
            ( { model
                | response = Error error
              }
            , Cmd.none
            )

        UserToggledEnableMuscatLinks ->
            ( { model
                | linksEnabled = not model.linksEnabled
              }
            , PortSendEnableMuscatLinks (not model.linksEnabled)
                |> encodeMessageForPortSend
                |> sendOutgoingMessageOnPort
            )
