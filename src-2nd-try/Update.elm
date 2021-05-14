module Update exposing (update)

import Language exposing (parseLocaleToLanguage)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Ports.LocalStorage exposing (saveLanguagePreference)
import Routes
import Search


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnWindowResize device ->
            ( model, Cmd.none )

        LanguageSelectChanged lang ->
            ( { model | language = parseLocaleToLanguage lang }
            , saveLanguagePreference lang
            )

        Routing routingMessage ->
            let
                ( routingModel, routingCmd ) =
                    Routes.update routingMessage model.route
            in
            ( { model | route = routingModel }
            , Cmd.map (\routingMsg -> Routing routingMsg) routingCmd
            )

        SearchInterface searchInterfaceMessage ->
            let
                ( searchModel, searchCmd ) =
                    Search.update searchInterfaceMessage model.search
            in
            ( { model | search = searchModel }
            , Cmd.map (\searchMsg -> SearchInterface searchMsg) searchCmd
            )

        NoOp ->
            ( model, Cmd.none )
