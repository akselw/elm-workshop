module ArticleSummary exposing (ArticleSummary, decode, id, title)

import ArticleId exposing (ArticleId)
import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import MarkdownString exposing (Markdown)


type ArticleSummary
    = ArticleSummary BackendData



--- CONTENTS ---


title : ArticleSummary -> Markdown
title (ArticleSummary info) =
    info.title


id : ArticleSummary -> ArticleId
id (ArticleSummary info) =
    info.id



--- DECODING ---


decode : Decoder ArticleSummary
decode =
    decodeBackendData
        |> map ArticleSummary


decodeBackendData : Decoder BackendData
decodeBackendData =
    Json.Decode.succeed BackendData
        |> required "id" ArticleId.decode
        |> required "title" MarkdownString.decode


type alias BackendData =
    { id : ArticleId
    , title : Markdown
    }
