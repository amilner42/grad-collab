module Page.BrowseTaskRequest exposing (Model, Msg, init, update, view)

import Account
import Api.Api as Api
import Api.Core as Core
import Api.Errors.Form as FormError
import Api.Errors.Unknown as UnknownError
import AppLinks
import Bulma
import FetchData
import Field
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import ListUtil
import MaybeUtil
import Session exposing (Session)
import TaskRequest
import User exposing (User)


type alias Model =
    { session : Session
    , inviteeName : String
    , inviteePersonalMessage : String
    , inviteeShortSubjectTopic : String
    , taskRequestId : String
    , taskRequestWithOwner : FetchData.FetchData (Core.HttpError UnknownError.Error) TaskRequest.TaskRequestWithOwner
    }


init : Session -> String -> ( Model, Cmd Msg )
init session taskRequestId =
    ( { session = session
      , inviteeName = ""
      , inviteePersonalMessage = ""
      , inviteeShortSubjectTopic = ""
      , taskRequestId = taskRequestId
      , taskRequestWithOwner = FetchData.Loading
      }
    , Api.getTaskRequestWithOwner taskRequestId CompletedGetTaskRequestWithOwner
    )


view : Model -> { title : String, content : Html.Html Msg }
view model =
    { title = "Browse Task Request"
    , content =
        renderFetchTaskRequest
            (Session.user model.session)
            model.taskRequestWithOwner
            model.inviteeName
            model.inviteePersonalMessage
            model.inviteeShortSubjectTopic
    }


renderFetchTaskRequest :
    Maybe User
    -> FetchData.FetchData (Core.HttpError UnknownError.Error) TaskRequest.TaskRequestWithOwner
    -> String
    -> String
    -> String
    -> Html.Html Msg
renderFetchTaskRequest maybeUser taskRequestWithOwnerFetch inviteeName inviteePersonalMessage inviteeShortSubjectTopic =
    case taskRequestWithOwnerFetch of
        FetchData.Loading ->
            -- Blank to avoid flashes
            div [] []

        FetchData.Failure _ ->
            div [] [ text "Failed to browse this task request...sorry!" ]

        FetchData.Success taskRequestWithOwner ->
            renderTaskRequestPage
                { maybeUser = maybeUser
                , taskRequestWithOwner = taskRequestWithOwner
                , inviteeName = inviteeName
                , inviteePersonalMessage = inviteePersonalMessage
                , inviteeShortSubjectTopic = inviteeShortSubjectTopic
                }


type alias RenderTaskRequestPage =
    { maybeUser : Maybe User
    , taskRequestWithOwner : TaskRequest.TaskRequestWithOwner
    , inviteeName : String
    , inviteePersonalMessage : String
    , inviteeShortSubjectTopic : String
    }


renderTaskRequestPage : RenderTaskRequestPage -> Html.Html Msg
renderTaskRequestPage config =
    let
        currentUserIsOwner =
            config.maybeUser
                |> Maybe.map (.id >> (==) config.taskRequestWithOwner.taskRequest.userId)
                |> Maybe.withDefault False
    in
    div [] <|
        ListUtil.filterByBool
            [ ( currentUserIsOwner
              , renderOwnerEmailHelpPanel
                    { inviteeName = config.inviteeName
                    , inviteePersonalMessage = config.inviteePersonalMessage
                    , inviteeShortSubjectTopic = config.inviteeShortSubjectTopic
                    , taskRequestId = config.taskRequestWithOwner.taskRequest.id
                    , ownerName = config.taskRequestWithOwner.owner.accountData.name
                    , ownerUniversity = config.taskRequestWithOwner.owner.accountData.university
                    }
              )
            , ( True
              , renderTaskRequestWithOwnerPanel
                    { taskRequestWithOwner = config.taskRequestWithOwner
                    , currentUserIsOwner = currentUserIsOwner
                    }
              )
            ]


type alias RenderOwnerEmailHelpSectionConfig =
    { inviteeName : String
    , inviteePersonalMessage : String
    , inviteeShortSubjectTopic : String
    , taskRequestId : String
    , ownerName : String
    , ownerUniversity : String
    }


renderOwnerEmailHelpPanel : RenderOwnerEmailHelpSectionConfig -> Html Msg
renderOwnerEmailHelpPanel config =
    let
        personalMessageExample =
            " My name is Jane and I am a PhD student researching molecular genetics at UBC and am currently looking into <insert brief topic>. We are looking for someone to help us with <insert task>. Would you be interested in chatting briefly this week to see if this is something you would be interested in?"
    in
    div
        [ class "columns", style "padding" "1.5rem 1.5rem" ]
        [ div
            [ class "column is-12" ]
            [ div
                []
                [ div
                    [ class "box" ]
                    [ div [ class "title has-text-centered" ] [ text "Task Outreach Dashboard" ]
                    , div
                        [ class "content", style "white-space" "pre-wrap", style "margin" "50px" ]
                        [ p [] [ text """Sending emails from your university email account is the recommended approach for finding collaborators.""" ]
                        , p [ class "title is-5", style "padding-top" "20px" ] [ text "Email Tips" ]
                        , ul
                            []
                            [ li []
                                [ text "Be clear and concise, three sentences max"
                                , li [] [ text "Research them, find out if and what will interest them about your proposal" ]
                                , li [] [ text "Have a call to action" ]
                                ]
                            ]
                        , p [ class "title is-5", style "padding-top" "20px" ] [ text "Example personal message" ]
                        , p [] [ text personalMessageExample ]
                        ]
                    , div
                        [ class "columns" ]
                        [ div
                            [ class "column is-6" ]
                            [ Bulma.formControl
                                (\hasError ->
                                    input
                                        [ classList
                                            [ ( "input", True )
                                            , ( "is-danger", hasError )
                                            ]
                                        , placeholder "Solving Dynamic Grid Flow Problems"
                                        , value config.inviteeShortSubjectTopic
                                        , onInput EnteredInviteeShortSubjectTopic
                                        ]
                                        []
                                )
                                []
                                (Just "Short Subject Topic")
                            , Bulma.formControl
                                (\hasError ->
                                    input
                                        [ classList
                                            [ ( "input", True )
                                            , ( "is-danger", hasError )
                                            ]
                                        , placeholder "John Doe"
                                        , value config.inviteeName
                                        , onInput EnteredInviteeName
                                        ]
                                        []
                                )
                                []
                                (Just "Name of Potential Collaborator")
                            , Bulma.formControl
                                (\hasError ->
                                    textarea
                                        [ classList
                                            [ ( "input", True )
                                            , ( "is-danger", hasError )
                                            ]
                                        , style "height" "150px"
                                        , placeholder <| "Your personal message"
                                        , value config.inviteePersonalMessage
                                        , onInput EnteredInviteePersonalMessage
                                        ]
                                        []
                                )
                                []
                                (Just "Personal Message")
                            ]
                        , div
                            [ class "column is-6" ]
                            [ div [ class "label" ] [ text "Email Subject" ]
                            , singleFieldContent <|
                                createRecommendedSubject
                                    config.ownerUniversity
                                    config.inviteeShortSubjectTopic
                            , div [ class "label" ] [ text "Email Body" ]
                            , singleFieldContent <|
                                createRecommendedEmail
                                    config.ownerName
                                    config.inviteeName
                                    config.inviteePersonalMessage
                                    config.taskRequestId
                            ]
                        ]
                    ]
                ]
            ]
        ]


createRecommendedSubject : String -> String -> String
createRecommendedSubject ownerUniversity shortSubjectTopic =
    let
        subjectTextPrefix =
            if String.isEmpty ownerUniversity then
                "YOUR-UNIVERSITY"

            else
                ownerUniversity

        subjectTextSuffix =
            if String.isEmpty shortSubjectTopic then
                "SHORT-SUBJECT-TOPIC"

            else
                shortSubjectTopic
    in
    subjectTextPrefix ++ " Team Investigating " ++ subjectTextSuffix


createRecommendedEmail : String -> String -> String -> String -> String
createRecommendedEmail fromName toName personalMessage taskRequestId =
    let
        inEmailNameText =
            if String.isEmpty toName then
                "POTENTIAL-COLLABORATOR-NAME"

            else
                toName

        inEmailFromNameText =
            if String.isEmpty fromName then
                "YOUR-NAME"

            else
                fromName

        inEmailPersonalMessageText =
            if String.isEmpty personalMessage then
                "PERSONAL-MESSAGE"

            else
                personalMessage
    in
    "Hello " ++ inEmailNameText ++ """,

""" ++ inEmailPersonalMessageText ++ """

If you are interest to learn more about the project you can see it at: """ ++ AppLinks.linkToBrowseTaskRequest taskRequestId ++ """

Thanks for reading,
""" ++ inEmailFromNameText


type alias RenderTaskRequestWithOwnerPanelConfig =
    { taskRequestWithOwner : TaskRequest.TaskRequestWithOwner
    , currentUserIsOwner : Bool
    }


renderTaskRequestWithOwnerPanel : RenderTaskRequestWithOwnerPanelConfig -> Html Msg
renderTaskRequestWithOwnerPanel config =
    let
        { owner, taskRequest } =
            config.taskRequestWithOwner
    in
    div
        [ class "columns", style "padding" "1.5rem 1.5rem" ]
        [ div
            [ class "column is-6 has-text-centered" ]
            [ renderOwnerPanel { owner = owner, currentUserIsOwner = config.currentUserIsOwner } ]
        , div
            [ class "column is-6 has-text-centered" ]
            [ renderTaskRequestPanel taskRequest ]
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
        , style "white-space" "pre-wrap"
        ]
    <|
        (String.split "\n" body
            |> List.map (\line -> div [] [ text line ])
        )


type alias RenderOwnerPanelConfig =
    { owner : User
    , currentUserIsOwner : Bool
    }


renderOwnerPanel : RenderOwnerPanelConfig -> Html Msg
renderOwnerPanel { owner, currentUserIsOwner } =
    let
        accountData =
            owner.accountData

        blankAccountDataFields =
            Account.blankFields accountData

        ownerProfileCompletenessMessage =
            if List.isEmpty blankAccountDataFields then
                p
                    [ class "content has-text-success" ]
                    [ text "your profile is complete, this will help get good collaborators" ]

            else
                p
                    [ class "content has-text-danger" ]
                    [ text "your profile is incomplete, this will deter collaborators" ]
    in
    div
        []
        [ div [ class "box" ] <|
            ListUtil.filterByBool
                [ ( True, sectionTitle "Researcher" )
                , ( currentUserIsOwner, ownerProfileCompletenessMessage )
                , ( True, singleFieldTitle "Email" )
                , ( True, singleFieldContent owner.email )
                , ( not <| String.isEmpty accountData.supervisorEmail, singleFieldTitle "Supervisor Email" )
                , ( not <| String.isEmpty accountData.supervisorEmail, singleFieldContent accountData.supervisorEmail )
                , ( not <| String.isEmpty accountData.name, singleFieldTitle "Name" )
                , ( not <| String.isEmpty accountData.name, singleFieldContent accountData.name )
                , ( not <| String.isEmpty accountData.linkedInUrl, singleFieldTitle "LinkedIn Profile" )
                , ( not <| String.isEmpty accountData.linkedInUrl, singleFieldContent accountData.linkedInUrl )

                -- TODO fix gross code
                , ( MaybeUtil.isJust accountData.field, singleFieldTitle "Field" )
                , ( MaybeUtil.isJust accountData.field
                  , singleFieldContent <|
                        (accountData.field
                            |> Maybe.map Field.toString
                            |> Maybe.withDefault ""
                        )
                  )
                , ( not <| String.isEmpty accountData.specialization, singleFieldTitle "Specialization" )
                , ( not <| String.isEmpty accountData.specialization, singleFieldContent accountData.specialization )
                , ( not <| String.isEmpty accountData.university, singleFieldTitle "University" )
                , ( not <| String.isEmpty accountData.university, singleFieldContent accountData.university )
                , ( not <| String.isEmpty accountData.degreesHeld, singleFieldTitle "Degrees Held" )
                , ( not <| String.isEmpty accountData.degreesHeld, singleFieldContent accountData.degreesHeld )
                , ( not <| String.isEmpty accountData.currentAvailability, singleFieldTitle "Current Availibility" )
                , ( not <| String.isEmpty accountData.currentAvailability, singleFieldContent accountData.currentAvailability )
                , ( not <| String.isEmpty accountData.shortBio, singleFieldTitle "Short Bio" )
                , ( not <| String.isEmpty accountData.shortBio, singleFieldContent accountData.shortBio )
                , ( not <| String.isEmpty accountData.researchExperienceAndPapers, singleFieldTitle "Research Papers and Experience" )
                , ( not <| String.isEmpty accountData.researchExperienceAndPapers, singleFieldContent accountData.researchExperienceAndPapers )
                ]
        ]


renderTaskRequestPanel : TaskRequest.TaskRequest -> Html Msg
renderTaskRequestPanel taskRequest =
    div
        []
        [ div [ class "box" ] <|
            [ sectionTitle "Project"
            , singleFieldTitle "Research Field"
            , singleFieldContent <| Field.toString taskRequest.researchField
            , singleFieldTitle "Reserch Subject"
            , singleFieldContent taskRequest.researchSubject
            , singleFieldTitle "Projct Impact Summary"
            , singleFieldContent taskRequest.projectImpactSummary
            , singleFieldTitle "Field Requesting Help From"
            , singleFieldContent <| Field.toString taskRequest.fieldRequestingHelpFrom
            , singleFieldTitle "Expected Tasks and Skills"
            , singleFieldContent taskRequest.expectedTasksAndSkills
            , singleFieldTitle "Reward"
            , singleFieldContent taskRequest.reward
            ]
                ++ (if String.isEmpty taskRequest.additionalInfo then
                        []

                    else
                        [ singleFieldTitle "Additional Info"
                        , singleFieldContent taskRequest.additionalInfo
                        ]
                   )
        ]


type Msg
    = CompletedGetTaskRequestWithOwner (Result.Result (Core.HttpError UnknownError.Error) TaskRequest.TaskRequestWithOwner)
    | EnteredInviteeName String
    | EnteredInviteePersonalMessage String
    | EnteredInviteeShortSubjectTopic String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CompletedGetTaskRequestWithOwner (Ok taskRequestWithOwner) ->
            ( { model | taskRequestWithOwner = FetchData.Success taskRequestWithOwner }
            , Cmd.none
            )

        CompletedGetTaskRequestWithOwner (Err err) ->
            ( { model | taskRequestWithOwner = FetchData.Failure err }, Cmd.none )

        EnteredInviteeName inviteeNameInput ->
            ( { model | inviteeName = inviteeNameInput }, Cmd.none )

        EnteredInviteePersonalMessage inviteePersonalMessageInput ->
            ( { model | inviteePersonalMessage = inviteePersonalMessageInput }, Cmd.none )

        EnteredInviteeShortSubjectTopic inviteeShortSubjectTopicInput ->
            ( { model | inviteeShortSubjectTopic = inviteeShortSubjectTopicInput }, Cmd.none )
