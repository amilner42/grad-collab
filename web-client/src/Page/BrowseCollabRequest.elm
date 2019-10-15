module Page.BrowseCollabRequest exposing (Model, Msg, init, update, view)

import Account
import Api.Api as Api
import Api.Core as Core
import Api.Errors.Form as FormError
import Api.Errors.Unknown as UnknownError
import AppLinks
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
    , inviteCollabName : String
    , inviteCollabPersonalMessage : String
    , inviteCollabShortSubjectTopic : String
    , collabRequestId : String
    , collabRequestWithOwner : FetchData.FetchData (Core.HttpError UnknownError.Error) CollabRequest.CollabRequestWithOwner
    }


init : Session -> String -> ( Model, Cmd Msg )
init session collabRequestId =
    ( { session = session
      , inviteCollabName = ""
      , inviteCollabPersonalMessage = ""
      , inviteCollabShortSubjectTopic = ""
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
            model.collabRequestWithOwner
            model.inviteCollabName
            model.inviteCollabPersonalMessage
            model.inviteCollabShortSubjectTopic
    }


renderFetchCollabRequest :
    Maybe User
    -> FetchData.FetchData (Core.HttpError UnknownError.Error) CollabRequest.CollabRequestWithOwner
    -> String
    -> String
    -> String
    -> Html.Html Msg
renderFetchCollabRequest maybeUser collabRequestWithOwnerFetch inviteCollabName inviteCollabPersonalMessage inviteCollabShortSubjectTopic =
    case collabRequestWithOwnerFetch of
        FetchData.Loading ->
            -- Blank to avoid flashes
            div [] []

        FetchData.Failure _ ->
            div [] [ text "Failed to browse this collab request...sorry!" ]

        FetchData.Success collabRequestWithOwner ->
            renderCollabRequestPage
                { maybeUser = maybeUser
                , collabRequestWithOwner = collabRequestWithOwner
                , inviteCollabName = inviteCollabName
                , inviteCollabPersonalMessage = inviteCollabPersonalMessage
                , inviteCollabShortSubjectTopic = inviteCollabShortSubjectTopic
                }


type alias RenderCollabRequestPage =
    { maybeUser : Maybe User
    , collabRequestWithOwner : CollabRequest.CollabRequestWithOwner
    , inviteCollabName : String
    , inviteCollabPersonalMessage : String
    , inviteCollabShortSubjectTopic : String
    }


renderCollabRequestPage : RenderCollabRequestPage -> Html.Html Msg
renderCollabRequestPage config =
    let
        currentUserIsOwner =
            config.maybeUser
                |> Maybe.map (.id >> (==) config.collabRequestWithOwner.collabRequest.userId)
                |> Maybe.withDefault False
    in
    div [] <|
        ListUtil.filterByBool
            [ ( currentUserIsOwner
              , renderOwnerEmailHelpPanel
                    { inviteCollabName = config.inviteCollabName
                    , inviteCollabPersonalMessage = config.inviteCollabPersonalMessage
                    , inviteCollabShortSubjectTopic = config.inviteCollabShortSubjectTopic
                    , collabRequestId = config.collabRequestWithOwner.collabRequest.id
                    , ownerName = config.collabRequestWithOwner.owner.accountData.name
                    , ownerUniversity = config.collabRequestWithOwner.owner.accountData.university
                    }
              )
            , ( True
              , renderCollabRequestWithOwnerPanel
                    { collabRequestWithOwner = config.collabRequestWithOwner
                    , currentUserIsOwner = currentUserIsOwner
                    }
              )
            ]


type alias RenderOwnerEmailHelpSectionConfig =
    { inviteCollabName : String
    , inviteCollabPersonalMessage : String
    , inviteCollabShortSubjectTopic : String
    , collabRequestId : String
    , ownerName : String
    , ownerUniversity : String
    }


renderOwnerEmailHelpPanel : RenderOwnerEmailHelpSectionConfig -> Html Msg
renderOwnerEmailHelpPanel config =
    let
        personalMessageExample =
            "My name is Jane and I am a PhD student researching molecular genetics at UBC and am currently looking into <insert brief topic>. Based on your interests in researching <insert topics they have researched or want to research>, I would be interested in chatting with you for 15 minutes to see if there might be a good fit for collaboration on this project. Would you have time to talk this week?"
    in
    div
        [ class "columns", style "padding" "1.5rem 1.5rem" ]
        [ div
            [ class "column is-12" ]
            [ div
                []
                [ div
                    [ class "box" ]
                    [ div [ class "title has-text-centered" ] [ text "Collaborator Outreach Dashboard" ]
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
                                        , value config.inviteCollabShortSubjectTopic
                                        , onInput EnteredInviteCollabShortSubjectTopic
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
                                        , value config.inviteCollabName
                                        , onInput EnteredInviteCollabName
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
                                        , value config.inviteCollabPersonalMessage
                                        , onInput EnteredInviteCollabPersonalMessage
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
                                    config.inviteCollabShortSubjectTopic
                            , div [ class "label" ] [ text "Email Body" ]
                            , singleFieldContent <|
                                createRecommendedEmail
                                    config.ownerName
                                    config.inviteCollabName
                                    config.inviteCollabPersonalMessage
                                    config.collabRequestId
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
createRecommendedEmail fromName toName personalMessage collabRequestId =
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

If you're interested in collaborating with me, you can take a look at my bio and project expectations here: """ ++ AppLinks.linkToBrowseCollabRequest collabRequestId ++ """

Thanks for reading,
""" ++ inEmailFromNameText


type alias RenderCollabRequestWithOwnerPanelConfig =
    { collabRequestWithOwner : CollabRequest.CollabRequestWithOwner
    , currentUserIsOwner : Bool
    }


renderCollabRequestWithOwnerPanel : RenderCollabRequestWithOwnerPanelConfig -> Html Msg
renderCollabRequestWithOwnerPanel config =
    let
        { owner, collabRequest } =
            config.collabRequestWithOwner
    in
    div
        [ class "columns", style "padding" "1.5rem 1.5rem" ]
        [ div
            [ class "column is-6 has-text-centered" ]
            [ renderOwnerPanel { owner = owner, currentUserIsOwner = config.currentUserIsOwner } ]
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
                [ ( True, sectionTitle "Collaborator" )
                , ( currentUserIsOwner, ownerProfileCompletenessMessage )
                , ( True, singleFieldTitle "Email" )
                , ( True, singleFieldContent owner.email )
                , ( not <| String.isEmpty accountData.supervisorEmail, singleFieldTitle "Supervisor Email" )
                , ( not <| String.isEmpty accountData.supervisorEmail, singleFieldContent accountData.supervisorEmail )
                , ( not <| String.isEmpty accountData.name, singleFieldTitle "Name" )
                , ( not <| String.isEmpty accountData.name, singleFieldContent accountData.name )
                , ( not <| String.isEmpty accountData.linkedInUrl, singleFieldTitle "LinkedIn Profile" )
                , ( not <| String.isEmpty accountData.linkedInUrl, singleFieldContent accountData.linkedInUrl )
                , ( not <| String.isEmpty accountData.field, singleFieldTitle "Field" )
                , ( not <| String.isEmpty accountData.field, singleFieldContent accountData.field )
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
            , singleFieldTitle "Expected Tasks and Skills"
            , singleFieldContent collabRequest.expectedTasksAndSkills
            , singleFieldTitle "Reward"
            , singleFieldContent collabRequest.reward
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
    | EnteredInviteCollabName String
    | EnteredInviteCollabPersonalMessage String
    | EnteredInviteCollabShortSubjectTopic String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CompletedGetCollabRequestWithOwner (Ok collabRequestWithOwner) ->
            ( { model | collabRequestWithOwner = FetchData.Success collabRequestWithOwner }
            , Cmd.none
            )

        CompletedGetCollabRequestWithOwner (Err err) ->
            ( { model | collabRequestWithOwner = FetchData.Failure err }, Cmd.none )

        EnteredInviteCollabName inviteCollabNameInput ->
            ( { model | inviteCollabName = inviteCollabNameInput }, Cmd.none )

        EnteredInviteCollabPersonalMessage inviteCollabPersonalMessageInput ->
            ( { model | inviteCollabPersonalMessage = inviteCollabPersonalMessageInput }, Cmd.none )

        EnteredInviteCollabShortSubjectTopic inviteCollabShortSubjectTopicInput ->
            ( { model | inviteCollabShortSubjectTopic = inviteCollabShortSubjectTopicInput }, Cmd.none )
