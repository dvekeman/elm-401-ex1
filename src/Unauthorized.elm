module Unauthorized exposing (Model, Msg, init, update, view)

import Html exposing (Html, div, text)


type alias Model =
    {}


init : Model
init =
    {}


view : Model -> Html Msg
view _ =
    div [] [ text "You are not authorized to perform this action!" ]


type Msg
    = Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )
