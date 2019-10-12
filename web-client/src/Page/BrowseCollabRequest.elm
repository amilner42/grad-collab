module Page.BrowseCollabRequest exposing (Model, Msg, init, update, view)

import Account
import Api.Api as Api
import Api.Core as Core
import Api.Errors.Form as FormError
import Api.Errors.Unknown as UnknownError
import Bulma
import CollabRequest
import FetchData
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Session exposing (Session)
import User exposing (User)


type alias Model =
    { session : Session
    , inviteCollabFormError : FormError.Error
    , inviteCollabFormEmail : String
    , collabRequestId : String
    , collabRequest : FetchData.FetchData (Core.HttpError UnknownError.Error) CollabRequest.CollabRequest
    , collabRequestOwner : FetchData.FetchData (Core.HttpError UnknownError.Error) Account.AccountData
    }


init : Session -> String -> ( Model, Cmd Msg )
init session collabRequestId =
    ( { session = session
      , inviteCollabFormError = FormError.empty
      , inviteCollabFormEmail = ""
      , collabRequestId = collabRequestId
      , collabRequest = FetchData.Loading
      , collabRequestOwner = FetchData.Loading
      }
    , Api.getCollabRequest collabRequestId CompletedGetCollabRequest
    )


view : Model -> { title : String, content : Html.Html Msg }
view model =
    { title = "Browse Collab Request"
    , content =
        renderFetchCollabRequest
            (Session.user model.session)
            model.inviteCollabFormError
            model.collabRequest
            model.inviteCollabFormEmail
    }


renderFetchCollabRequest :
    Maybe User
    -> FormError.Error
    -> FetchData.FetchData (Core.HttpError UnknownError.Error) CollabRequest.CollabRequest
    -> String
    -> Html.Html Msg
renderFetchCollabRequest maybeUser inviteCollabFormError collabRequestFetch inviteCollabFormEmail =
    case collabRequestFetch of
        FetchData.Loading ->
            -- Blank to avoid flashes
            div [] []

        FetchData.Failure _ ->
            div [] [ text "Failed to browse this collab request...sorry!" ]

        FetchData.Success collabRequest ->
            renderCollabRequest maybeUser inviteCollabFormError inviteCollabFormEmail collabRequest


renderCollabRequest : Maybe User -> FormError.Error -> String -> CollabRequest.CollabRequest -> Html.Html Msg
renderCollabRequest maybeUser inviteCollabFormError inviteCollabFormEmail collabRequest =
    let
        isOwner =
            maybeUser
                |> Maybe.map (.id >> (==) collabRequest.userId)
                |> Maybe.withDefault False

        sectionTitle title =
            div [ class "title is-4" ] [ text title ]

        singleFieldTitle title =
            div [ class "title is-5" ] [ text title ]

        singleFieldContent body =
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
        [ class "columns is-centered" ]
        [ div [ class "column is-half-desktop is-two-thirds-tablet has-text-centered" ] <|
            [ div
                [ classList [ ( "section is-small", True ), ( "is-hidden", not isOwner ) ]
                , style "padding-bottom" "0px"
                ]
                [ sectionTitle "Collaborator Outreach"
                , div
                    [ class "content" ]
                    [ if List.isEmpty collabRequest.invitedCollabs then
                        text "Invite a collaborator to join on your project."

                      else
                        table [ class "table is-bordered is-striped is-narrow is-hoverable is-fullwidth" ] <|
                            [ thead
                                []
                                [ tr
                                    []
                                    [ th
                                        []
                                        [ text "Invited Collabs" ]
                                    ]
                                ]
                            ]
                                ++ (collabRequest.invitedCollabs
                                        |> List.map
                                            (\collabEmail ->
                                                tr
                                                    []
                                                    [ td
                                                        []
                                                        [ text collabEmail ]
                                                    ]
                                            )
                                   )
                    ]
                , Bulma.formControl
                    (\hasError ->
                        input
                            [ classList
                                [ ( "input", True )
                                , ( "is-danger", hasError )
                                ]
                            , placeholder "Eg. gradstudentemail@uni.com"
                            , value inviteCollabFormEmail
                            , onInput EnteredInviteCollabEmail
                            ]
                            []
                    )
                    (FormError.getErrorForField "invitedCollabEmail" inviteCollabFormError)
                    Nothing
                , p
                    [ class "title is-size-7 has-text-danger has-text-centered" ]
                    (List.map text <| inviteCollabFormError.entire)
                , button
                    [ class "button is-success is-medium"
                    , onClick SubmittedForm
                    ]
                    [ text "invite" ]
                ]
            , div
                [ class "section is-small" ]
                [ div [ class "box" ] <|
                    [ sectionTitle "Collaboration Request Information"
                    , singleFieldTitle "Field"
                    , singleFieldContent collabRequest.field
                    , singleFieldTitle "Subject"
                    , singleFieldContent collabRequest.subject
                    , singleFieldTitle "Projct Impact Summary"
                    , singleFieldContent collabRequest.projectImpactSummary
                    , singleFieldTitle "Expected Tasks"
                    , singleFieldContent collabRequest.expectedTasks
                    , singleFieldTitle "Expected Time"
                    , singleFieldContent collabRequest.expectedTime
                    , singleFieldTitle "Offer"
                    , singleFieldContent collabRequest.offer
                    ]
                        ++ (if String.isEmpty collabRequest.additionalInfo then
                                []

                            else
                                [ singleFieldTitle "Additional Info"
                                , singleFieldContent collabRequest.additionalInfo
                                ]
                           )
                ]
            ]
        ]


type Msg
    = CompletedGetCollabRequest (Result.Result (Core.HttpError UnknownError.Error) CollabRequest.CollabRequest)
    | EnteredInviteCollabEmail String
    | SubmittedForm
    | CompletedInviteCollab String (Result.Result (Core.HttpError FormError.Error) ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CompletedGetCollabRequest (Ok collabRequest) ->
            ( { model | collabRequest = FetchData.Success collabRequest }, Cmd.none )

        CompletedGetCollabRequest (Err err) ->
            ( { model | collabRequest = FetchData.Failure err }, Cmd.none )

        EnteredInviteCollabEmail inviteCollabEmailInput ->
            ( { model | inviteCollabFormEmail = inviteCollabEmailInput }, Cmd.none )

        SubmittedForm ->
            ( model
            , Api.inviteCollab model.collabRequestId model.inviteCollabFormEmail (CompletedInviteCollab model.inviteCollabFormEmail)
            )

        CompletedInviteCollab invitedCollabEmail (Ok ()) ->
            ( { model
                | collabRequest =
                    model.collabRequest
                        |> FetchData.map
                            (\collabRequest ->
                                { collabRequest
                                    | invitedCollabs = invitedCollabEmail :: collabRequest.invitedCollabs
                                }
                            )
                , inviteCollabFormEmail = ""
              }
            , Cmd.none
            )

        CompletedInviteCollab _ (Err httpErr) ->
            ( { model | inviteCollabFormError = FormError.fromHttpError httpErr }, Cmd.none )
