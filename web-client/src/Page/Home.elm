module Page.Home exposing (Model, Msg, init, update, view)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Api.Api as Api
import Api.Core as Core
import Api.Errors.Form as FormError
import Api.Errors.Unknown as UnknownError
import Browser.Navigation as Nav
import Bulma
import Field
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (RemoteData)
import Route
import Session exposing (Session)
import TaskRequest exposing (TaskRequest)
import User exposing (User)



-- MODEL


type alias Model =
    { session : Session
    , taskRequests : RemoteData.RemoteData (Core.HttpError UnknownError.Error) (List TaskRequest)
    }


init : Session -> ( Model, Cmd Msg )
init session =
    case Session.user session of
        Nothing ->
            ( { session = session, taskRequests = RemoteData.NotAsked }
            , Cmd.none
            )

        Just user ->
            ( { session = session, taskRequests = RemoteData.Loading }
            , Api.getTaskRequests
                { forUserId = Just user.id, researchField = Nothing, fieldRequestingHelpFrom = Nothing }
                CompletedGetTaskRequests
            )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home"
    , content =
        case Session.user model.session of
            Nothing ->
                renderLandingPage

            Just _ ->
                renderHomePage model.taskRequests
    }


renderHomePage : RemoteData (Core.HttpError UnknownError.Error) (List TaskRequest) -> Html Msg
renderHomePage rdTaskRequests =
    case rdTaskRequests of
        RemoteData.NotAsked ->
            div [] []

        RemoteData.Loading ->
            div [] []

        RemoteData.Failure _ ->
            div
                [ class "section has-text-centered is-large" ]
                [ div
                    [ class "title" ]
                    [ text "Ooops, we're having troubles..." ]
                , div
                    [ class "subtitle" ]
                    [ text "We will be back online shortly." ]
                ]

        RemoteData.Success taskRequests ->
            if List.isEmpty taskRequests then
                div
                    [ class "section has-text-centered is-large" ]
                    [ div
                        [ class "title" ]
                        [ text "You have no open task requests." ]
                    , div
                        [ class "subtitle" ]
                        [ text "Create one easily to help find the perfect collaborator." ]
                    ]

            else
                renderHasTaskRequestsPage taskRequests


renderHasTaskRequestsPage : List TaskRequest -> Html.Html Msg
renderHasTaskRequestsPage taskRequests =
    div
        [ class "section" ]
        [ h1
            [ class "title is-4 has-text-centered" ]
            [ text "Your Task Requests" ]
        , div
            [ class "columns is-multiline"
            , style "margin" "0px"
            ]
            (List.map renderTaskRequestLink taskRequests)
        ]


renderTaskRequestLink : TaskRequest -> Html.Html Msg
renderTaskRequestLink taskRequest =
    div
        [ class "column is-one-third-desktop is-half-tablet"
        , onClick <| GoTo <| Route.BrowseTaskRequest taskRequest.id
        , style "cursor" "pointer"
        ]
        [ div
            [ class "box has-text-centered"
            , style "height" "250px"
            , style "padding" "10px"
            , style "border-radius" "0px"
            ]
            [ div
                [ class "level is-mobile"
                , style "width" "100%"
                , style "height" "20px"
                , style "margin-bottom" "5px"
                ]
                [ div
                    [ class "level-item level-left has-text-weight-bold" ]
                    [ text <| Field.toString taskRequest.researchField ]
                ]
            , div
                [ class "level is-mobile"
                , style "width" "100%"
                , style "height" "20px"
                , style "margin-bottom" "5px"
                ]
                [ div
                    [ class "level-item level-left has-text-grey-light" ]
                    [ text taskRequest.researchSubject ]
                ]
            , div
                [ style "margin-top" "15px"
                , style "overflow-y" "auto"
                , style "height" "160px"
                ]
                [ text taskRequest.projectImpactSummary ]
            ]
        ]


renderLandingPage : Html Msg
renderLandingPage =
    section
        [ class "section is-large" ]
        [ div
            [ class "container" ]
            [ div
                [ class "columns is-centered" ]
                [ div
                    [ class "column is-half" ]
                    [ h1
                        [ class "title has-text-centered" ]
                        [ text "Welcome" ]
                    , h2
                        [ class "subtitle has-text-centered" ]
                        [ text "collaborating easily and effectively" ]
                    ]
                ]
            ]
        ]



-- UPDATE


type Msg
    = GoTo Route.Route
    | CompletedGetTaskRequests (Result.Result (Core.HttpError UnknownError.Error) (List TaskRequest))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        navKey =
            Session.navKey model.session
    in
    case msg of
        GoTo route ->
            ( model, Route.pushUrl navKey route )

        CompletedGetTaskRequests (Ok taskRequests) ->
            ( { model | taskRequests = RemoteData.Success taskRequests }, Cmd.none )

        CompletedGetTaskRequests (Err httpGetTaskRequestsErr) ->
            ( { model | taskRequests = RemoteData.Failure httpGetTaskRequestsErr }, Cmd.none )
