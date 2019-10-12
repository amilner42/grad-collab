module User exposing (User, decoder)

import Account
import Json.Decode as Decode


type alias User =
    { id : String
    , email : String
    , accountData : Account.AccountData
    }


decoder : Decode.Decoder User
decoder =
    Account.decoder
        |> Decode.andThen
            (\accountData ->
                Decode.map3 User
                    (Decode.field "_id" Decode.string)
                    (Decode.field "email" Decode.string)
                    (Decode.succeed accountData)
            )
