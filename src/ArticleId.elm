module ArticleId exposing (ArticleId, decode, toString, urlParser)

import Json.Decode exposing (Decoder)
import Url.Parser exposing (Parser)


type ArticleId
    = ArticleId String


toString : ArticleId -> String
toString (ArticleId id) =
    id


urlParser : Parser (ArticleId -> a) a
urlParser =
    Url.Parser.map ArticleId Url.Parser.string


decode : Decoder ArticleId
decode =
    Json.Decode.string
        |> Json.Decode.map ArticleId
