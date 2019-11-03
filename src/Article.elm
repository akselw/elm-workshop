module Article exposing (Article, decode, id, title)

import ArticleId exposing (ArticleId)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)


type Article
    = Article BackendData



--- CONTENTS


title : Article -> String
title (Article info) =
    info.title


id : Article -> ArticleId
id (Article info) =
    info.id



--- DECODING ---


decode : Decoder Article
decode =
    decodeBackendData
        |> map Article


decodeBackendData : Decoder BackendData
decodeBackendData =
    Json.Decode.succeed BackendData
        |> required "id" ArticleId.decode
        |> required "title" string


type alias BackendData =
    { id : ArticleId
    , title : String
    }
