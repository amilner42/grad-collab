module TaskRequest exposing (TaskRequest, TaskRequestData, TaskRequestWithOwner, decoder, empty, encode, taskRequestWithOwnerDecoder)

import Api.Errors.Form as FormError
import EncodeUtil
import Field
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import User exposing (User)


type alias TaskRequest =
    { id : String
    , researchField : Field.Field
    , researchSubject : String
    , projectImpactSummary : String
    , expectedTasksAndSkills : String
    , fieldRequestingHelpFrom : Field.Field
    , reward : String
    , additionalInfo : String
    , userId : String
    }


type alias TaskRequestData =
    { researchField : Maybe Field.Field
    , researchSubject : String
    , projectImpactSummary : String
    , expectedTasksAndSkills : String
    , fieldRequestingHelpFrom : Maybe Field.Field
    , reward : String
    , additionalInfo : String
    }


type alias TaskRequestWithOwner =
    { owner : User
    , taskRequest : TaskRequest
    }


empty : TaskRequestData
empty =
    { researchField = Nothing
    , researchSubject = ""
    , projectImpactSummary = ""
    , expectedTasksAndSkills = ""
    , fieldRequestingHelpFrom = Nothing
    , reward = ""
    , additionalInfo = ""
    }


dataGoodForSubmission : TaskRequestData -> FormError.Error
dataGoodForSubmission taskRequest =
    FormError.fromFieldErrors <|
        FormError.fieldErrorsFromList
            [ ( "field", Nothing )
            , ( "subject", Nothing )
            ]


encode : TaskRequestData -> Encode.Value
encode taskRequest =
    Encode.object
        [ ( "researchField", EncodeUtil.nullable Field.encoder taskRequest.researchField )
        , ( "researchSubject", Encode.string taskRequest.researchSubject )
        , ( "projectImpactSummary", Encode.string taskRequest.projectImpactSummary )
        , ( "expectedTasksAndSkills", Encode.string taskRequest.expectedTasksAndSkills )
        , ( "fieldRequestingHelpFrom", EncodeUtil.nullable Field.encoder taskRequest.fieldRequestingHelpFrom )
        , ( "reward", Encode.string taskRequest.reward )
        , ( "additionalInfo", Encode.string taskRequest.additionalInfo )
        ]


decoder : Decode.Decoder TaskRequest
decoder =
    Decode.succeed TaskRequest
        |> required "_id" Decode.string
        |> required "researchField" Field.decoder
        |> required "researchSubject" Decode.string
        |> required "projectImpactSummary" Decode.string
        |> required "expectedTasksAndSkills" Decode.string
        |> required "fieldRequestingHelpFrom" Field.decoder
        |> required "reward" Decode.string
        |> required "additionalInfo" Decode.string
        |> required "userId" Decode.string


taskRequestWithOwnerDecoder : Decode.Decoder TaskRequestWithOwner
taskRequestWithOwnerDecoder =
    Decode.succeed TaskRequestWithOwner
        |> required "user" User.decoder
        |> required "taskRequest" decoder
