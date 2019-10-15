module CollabRequest exposing (CollabRequest, CollabRequestData, CollabRequestWithOwner, collabRequestWithOwnerDecoder, decoder, empty, encode)

import Api.Errors.Form as FormError
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import User exposing (User)


type alias CollabRequest =
    { id : String
    , field : String
    , subject : String
    , projectImpactSummary : String
    , expectedTasksAndSkills : String
    , reward : String
    , additionalInfo : String
    , userId : String
    , invitedCollabs : List String
    }


type alias CollabRequestData =
    { field : String
    , subject : String
    , projectImpactSummary : String
    , expectedTasksAndSkills : String
    , reward : String
    , additionalInfo : String
    }


type alias CollabRequestWithOwner =
    { owner : User
    , collabRequest : CollabRequest
    }


empty : CollabRequestData
empty =
    { field = ""
    , subject = ""
    , projectImpactSummary = ""
    , expectedTasksAndSkills = ""
    , reward = ""
    , additionalInfo = ""
    }


dataGoodForSubmission : CollabRequestData -> FormError.Error
dataGoodForSubmission collabRequest =
    FormError.fromFieldErrors <|
        FormError.fieldErrorsFromList
            [ ( "field", Nothing )
            , ( "subject", Nothing )
            ]


encode : CollabRequestData -> Encode.Value
encode collabRequest =
    Encode.object
        [ ( "field", Encode.string collabRequest.field )
        , ( "subject", Encode.string collabRequest.subject )
        , ( "projectImpactSummary", Encode.string collabRequest.projectImpactSummary )
        , ( "expectedTasksAndSkills", Encode.string collabRequest.expectedTasksAndSkills )
        , ( "reward", Encode.string collabRequest.reward )
        , ( "additionalInfo", Encode.string collabRequest.additionalInfo )
        ]


decoder : Decode.Decoder CollabRequest
decoder =
    Decode.succeed CollabRequest
        |> required "_id" Decode.string
        |> required "field" Decode.string
        |> required "subject" Decode.string
        |> required "projectImpactSummary" Decode.string
        |> required "expectedTasksAndSkills" Decode.string
        |> required "reward" Decode.string
        |> required "additionalInfo" Decode.string
        |> required "userId" Decode.string
        |> required "invitedCollabs" (Decode.list Decode.string)


collabRequestWithOwnerDecoder : Decode.Decoder CollabRequestWithOwner
collabRequestWithOwnerDecoder =
    Decode.succeed CollabRequestWithOwner
        |> required "user" User.decoder
        |> required "collabRequest" decoder
