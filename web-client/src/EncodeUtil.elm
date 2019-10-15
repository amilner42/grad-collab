module EncodeUtil exposing (nullable)

import Json.Encode as Encode


nullable : (t -> Encode.Value) -> Maybe t -> Encode.Value
nullable encoderT =
    Maybe.map encoderT >> Maybe.withDefault Encode.null
