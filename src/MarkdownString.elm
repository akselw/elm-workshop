module MarkdownString exposing (Markdown, decode, toHtml)

import Html exposing (Html)
import Json.Decode exposing (Decoder)
import Markdown


type Markdown
    = Markdown String


decode : Decoder Markdown
decode =
    Json.Decode.string
        |> Json.Decode.map Markdown


toHtml : Markdown -> Html msg
toHtml (Markdown string) =
    Markdown.toHtml [] string
