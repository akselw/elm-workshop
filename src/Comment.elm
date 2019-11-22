module Comment exposing (Comment, decode, subcomments, text, username)

import CommentId exposing (CommentId)
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)


type Comment
    = Comment BackendData



--- CONTENTS ---


text : Comment -> String
text (Comment info) =
    info.text


username : Comment -> String
username (Comment info) =
    info.username


subcomments : Comment -> List Comment
subcomments (Comment info) =
    info.subcomments



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
        |> required "username" Json.Decode.string
        |> optional "comments" (Json.Decode.list (Json.Decode.lazy (\_ -> decode))) []


type alias BackendData =
    { text : String
    , id : CommentId
    , username : String
    , subcomments : List Comment
    }
