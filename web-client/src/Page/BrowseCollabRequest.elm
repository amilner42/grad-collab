module Page.BrowseCollabRequest exposing (Model, Msg, init, update, view)

import Api.Api as Api
import Api.Core as Core
import Api.Errors.Unknown as UnknownError
import CollabRequest
import FetchData
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Session exposing (Session)


type alias Model =
    { session : Session
    , collabRequestId : String
    , collabRequest : FetchData.FetchData (Core.HttpError UnknownError.Error) CollabRequest.CollabRequest
    }


init : Session -> String -> ( Model, Cmd Msg )
init session collabRequestId =
    ( { session = session
      , collabRequestId = collabRequestId
      , collabRequest = FetchData.Loading
      }
    , Api.getCollabRequest collabRequestId CompletedGetCollabRequest
    )


view : Model -> { title : String, content : Html.Html Msg }
view model =
    { title = "Browse Collab Request"
    , content = renderFetchCollabRequest model.collabRequest
    }


renderFetchCollabRequest :
    FetchData.FetchData (Core.HttpError UnknownError.Error) CollabRequest.CollabRequest
    -> Html.Html Msg
renderFetchCollabRequest collabRequestFetch =
    case collabRequestFetch of
        FetchData.Loading ->
            -- Blank to avoid flashes
            div [] []

        FetchData.Failure _ ->
            div [] [ text "Failed to browse this collab request...sorry!" ]

        FetchData.Success collabRequest ->
            renderCollabRequest collabRequest


renderCollabRequest : CollabRequest.CollabRequest -> Html.Html Msg
renderCollabRequest collabRequest =
    let
        textTitle title =
            div [ class "title is-5" ] [ text title ]

        textBody body =
            div
                [ class "content"
                , style "background-color" "#F6F6F6"
                , style "border-radius" "5px"
                , style "padding" "5px"
                ]
            <|
                (String.split "\n" body
                    |> List.map (\line -> div [] [ text line ])
                )
    in
    div
        [ class "section" ]
        [ div
            [ class "columns is-centered" ]
            [ div [ class "column is-half has-text-centered" ] <|
                [ textTitle "Field"
                , textBody collabRequest.field
                , textTitle "Subject"
                , textBody collabRequest.subject
                , textTitle "Projct Impact Summary"
                , textBody collabRequest.projectImpactSummary
                , textTitle "Expected Tasks"
                , textBody collabRequest.expectedTasks
                , textTitle "Expected Time"
                , textBody collabRequest.expectedTime
                , textTitle "Offer"
                , textBody collabRequest.offer
                ]
                    ++ (if String.isEmpty collabRequest.additionalInfo then
                            []

                        else
                            [ textTitle "Additional Info"
                            , textBody collabRequest.additionalInfo
                            ]
                       )
            ]
        ]


type Msg
    = CompletedGetCollabRequest (Result.Result (Core.HttpError UnknownError.Error) CollabRequest.CollabRequest)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CompletedGetCollabRequest (Ok collabRequest) ->
            ( { model | collabRequest = FetchData.Success collabRequest }, Cmd.none )

        CompletedGetCollabRequest (Err err) ->
            ( { model | collabRequest = FetchData.Failure err }, Cmd.none )
