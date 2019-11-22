module Article exposing (Article, decode, id, title)

import ArticleId exposing (ArticleId)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Markdown exposing (Markdown)


type Article
    = Article BackendData



--- CONTENTS


title : Article -> Markdown
title (Article info) =
    info.title


id : Article -> ArticleId
id (Article info) =
    info.id


lead : Article -> Maybe Markdown
lead (Article info) =
    info.lead


body : Article -> Markdown
body (Article info) =
    info.body



--- DECODING ---


decode : Decoder Article
decode =
    decodeBackendData
        |> map Article


decodeBackendData : Decoder BackendData
decodeBackendData =
    Json.Decode.succeed BackendData
        |> required "id" ArticleId.decode
        |> required "title" Markdown.decode
        |> required "lead" (nullable Markdown.decode)
        |> required "body" Markdown.decode


type alias BackendData =
    { id : ArticleId
    , title : Markdown
    , lead : Maybe Markdown
    , body : Markdown
    }
