module Markdown exposing (Markdown, decode, toHtml)

import Html exposing (Html)
import Json.Decode exposing (Decoder)


type Markdown
    = Markdown String


decode : Decoder Markdown
decode =
    Json.Decode.string
        |> Json.Decode.map Markdown


toHtml : Markdown -> Html msg
toHtml (Markdown string) =
    Html.text string
