module Page.BrowseCollabRequest exposing (Model, Msg, init, update, view)

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
import ListUtil
import Session exposing (Session)
import User exposing (User)


type alias Model =
    { session : Session
    , inviteCollabFormError : FormError.Error
    , inviteCollabFormEmail : String
    , collabRequestId : String
    , collabRequestWithOwner : FetchData.FetchData (Core.HttpError UnknownError.Error) CollabRequest.CollabRequestWithOwner
    }


init : Session -> String -> ( Model, Cmd Msg )
init session collabRequestId =
    ( { session = session
      , inviteCollabFormError = FormError.empty
      , inviteCollabFormEmail = ""
      , collabRequestId = collabRequestId
      , collabRequestWithOwner = FetchData.Loading
      }
    , Api.getCollabRequestWithOwner collabRequestId CompletedGetCollabRequestWithOwner
    )


view : Model -> { title : String, content : Html.Html Msg }
view model =
    { title = "Browse Collab Request"
    , content =
        renderFetchCollabRequest
            (Session.user model.session)
            model.inviteCollabFormError
            model.collabRequestWithOwner
            model.inviteCollabFormEmail
    }


renderFetchCollabRequest :
    Maybe User
    -> FormError.Error
    -> FetchData.FetchData (Core.HttpError UnknownError.Error) CollabRequest.CollabRequestWithOwner
    -> String
    -> Html.Html Msg
renderFetchCollabRequest maybeUser inviteCollabFormError collabRequestWithOwnerFetch inviteCollabFormEmail =
    case collabRequestWithOwnerFetch of
        FetchData.Loading ->
            -- Blank to avoid flashes
            div [] []

        FetchData.Failure _ ->
            div [] [ text "Failed to browse this collab request...sorry!" ]

        FetchData.Success collabRequestWithOwner ->
            renderCollabRequestPage maybeUser inviteCollabFormError inviteCollabFormEmail collabRequestWithOwner


renderCollabRequestPage : Maybe User -> FormError.Error -> String -> CollabRequest.CollabRequestWithOwner -> Html.Html Msg
renderCollabRequestPage maybeUser inviteCollabFormError inviteCollabFormEmail collabRequestWithOwner =
    let
        isOwner =
            maybeUser
                |> Maybe.map (.id >> (==) collabRequestWithOwner.collabRequest.userId)
                |> Maybe.withDefault False
    in
    div [] <|
        ListUtil.filterByBool
            [ ( isOwner
              , renderOwnerEmailHelpPanel
                    { invitedCollabs = collabRequestWithOwner.collabRequest.invitedCollabs
                    , inviteCollabFormEmail = inviteCollabFormEmail
                    , inviteCollabFormError = inviteCollabFormError
                    }
              )
            , ( True, renderCollabRequestWithOwnerPanel collabRequestWithOwner )
            ]


type alias RenderOwnerEmailHelpSectionConfig =
    { invitedCollabs : List String
    , inviteCollabFormEmail : String
    , inviteCollabFormError : FormError.Error
    }


renderOwnerEmailHelpPanel : RenderOwnerEmailHelpSectionConfig -> Html Msg
renderOwnerEmailHelpPanel config =
    div
        [ class "columns is-centered" ]
        [ div [ class "column is-half-desktop is-two-thirds-tablet has-text-centered" ] <|
            [ div
                [ class "section is-small"
                , style "padding-bottom" "0px"
                ]
                [ div
                    [ class "box" ]
                    [ div [ class "title" ] [ text "Collaborator Outreach" ]
                    , div
                        [ class "content" ]
                        [ if List.isEmpty config.invitedCollabs then
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
                                    ++ (config.invitedCollabs
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
                                , value config.inviteCollabFormEmail
                                , onInput EnteredInviteCollabEmail
                                ]
                                []
                        )
                        (FormError.getErrorForField "invitedCollabEmail" config.inviteCollabFormError)
                        Nothing
                    , p
                        [ class "title is-size-7 has-text-danger has-text-centered" ]
                        (List.map text <| config.inviteCollabFormError.entire)
                    , button
                        [ class "button is-success is-medium"
                        , onClick SubmittedForm
                        ]
                        [ text "invite" ]
                    ]
                ]
            ]
        ]


renderCollabRequestWithOwnerPanel : CollabRequest.CollabRequestWithOwner -> Html Msg
renderCollabRequestWithOwnerPanel { collabRequest, owner } =
    div
        [ class "columns", style "padding" "1.5rem 1.5rem" ]
        [ div
            [ class "column is-6 has-text-centered" ]
            [ renderOwnerPanel owner ]
        , div
            [ class "column is-6 has-text-centered" ]
            [ renderCollabRequestPanel collabRequest ]
        ]


sectionTitle : String -> Html msg
sectionTitle title =
    div [ class "title is-4" ] [ text title ]


singleFieldTitle : String -> Html msg
singleFieldTitle title =
    div [ class "title is-5" ] [ text title ]


singleFieldContent : String -> Html msg
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


renderOwnerPanel : User -> Html Msg
renderOwnerPanel { accountData, email } =
    -- TODO handle rendering when they have blank fields
    div
        []
        [ div [ class "box" ] <|
            [ sectionTitle "Collaborator"
            , singleFieldTitle "Email"
            , singleFieldContent email
            , singleFieldTitle "Supervisor Email"
            , singleFieldContent accountData.supervisorEmail
            , singleFieldTitle "Name"
            , singleFieldContent accountData.name
            , singleFieldTitle "LinkedIn Profile"
            , singleFieldContent accountData.linkedInUrl
            , singleFieldTitle "Field"
            , singleFieldContent accountData.field
            , singleFieldTitle "Specialization"
            , singleFieldContent accountData.specialization
            , singleFieldTitle "University"
            , singleFieldContent accountData.university
            , singleFieldTitle "Degrees Held"
            , singleFieldContent accountData.degreesHeld
            , singleFieldTitle "Current Availibility"
            , singleFieldContent accountData.currentAvailability
            , singleFieldTitle "Short Bio"
            , singleFieldContent accountData.shortBio
            , singleFieldTitle "Research Papers"
            , singleFieldContent accountData.researchPapers
            , singleFieldTitle "Research Experience"
            , singleFieldContent accountData.researchExperience
            ]
        ]


renderCollabRequestPanel : CollabRequest.CollabRequest -> Html Msg
renderCollabRequestPanel collabRequest =
    div
        []
        [ div [ class "box" ] <|
            [ sectionTitle "Project Info"
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


type Msg
    = CompletedGetCollabRequestWithOwner (Result.Result (Core.HttpError UnknownError.Error) CollabRequest.CollabRequestWithOwner)
    | EnteredInviteCollabEmail String
    | SubmittedForm
    | CompletedInviteCollab String (Result.Result (Core.HttpError FormError.Error) ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CompletedGetCollabRequestWithOwner (Ok collabRequestWithOwner) ->
            ( { model | collabRequestWithOwner = FetchData.Success collabRequestWithOwner }
            , Cmd.none
            )

        CompletedGetCollabRequestWithOwner (Err err) ->
            ( { model | collabRequestWithOwner = FetchData.Failure err }, Cmd.none )

        EnteredInviteCollabEmail inviteCollabEmailInput ->
            ( { model | inviteCollabFormEmail = inviteCollabEmailInput }, Cmd.none )

        SubmittedForm ->
            ( model
            , Api.inviteCollab model.collabRequestId model.inviteCollabFormEmail (CompletedInviteCollab model.inviteCollabFormEmail)
            )

        CompletedInviteCollab invitedCollabEmail (Ok ()) ->
            ( { model
                | collabRequestWithOwner =
                    model.collabRequestWithOwner
                        |> FetchData.map
                            (\({ collabRequest } as collabRequestWithOwner) ->
                                { collabRequestWithOwner
                                    | collabRequest =
                                        { collabRequest
                                            | invitedCollabs = invitedCollabEmail :: collabRequest.invitedCollabs
                                        }
                                }
                            )
                , inviteCollabFormEmail = ""
              }
            , Cmd.none
            )

        CompletedInviteCollab _ (Err httpErr) ->
            ( { model | inviteCollabFormError = FormError.fromHttpError httpErr }, Cmd.none )
