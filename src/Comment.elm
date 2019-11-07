module Comment exposing (Comment, decode)

import CommentId exposing (CommentId)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


type Comment
    = Comment BackendData



--- DECODING ---


decode : Decoder Comment
decode =
    decodeBackendData
        |> Json.Decode.map Comment


decodeBackendData : Decoder BackendData
decodeBackendData =
    Json.Decode.succeed BackendData
        |> required "text" Json.Decode.string
        |> required "id" CommentId.decode


type alias BackendData =
    { text : String
    , id : CommentId
    }
