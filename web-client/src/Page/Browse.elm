module Page.Browse exposing (Model, Msg(..), init, update, view)

{-| A blank page.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Session exposing (Session)


type alias Model =
    { session : Session
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )


view : Model -> { title : String, content : Html.Html Msg }
view model =
    { title = "Browse"
    , content =
        div
            [ class "section is-large has-text-centered" ]
            [ div [ class "title" ] [ text "Page Under Construction" ]
            , div [ class "subtitle" ] [ text "Soon you'll be able to browse and search all open collab requests from all over the world." ]
            ]
    }


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
