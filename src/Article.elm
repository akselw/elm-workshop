module Article exposing (Article, body, decode, id, lead, title)

import ArticleId exposing (ArticleId)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import MarkdownString exposing (Markdown)


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
        |> required "title" MarkdownString.decode
        |> required "lead" (nullable MarkdownString.decode)
        |> required "body" MarkdownString.decode


type alias BackendData =
    { id : ArticleId
    , title : Markdown
    , lead : Maybe Markdown
    , body : Markdown
    }
