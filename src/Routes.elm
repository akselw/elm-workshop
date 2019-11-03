module Routes exposing (Route(..), fromUrl)

import ArticleId exposing (ArticleId)
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, s, string)


type Route
    = Articles
    | Article ArticleId


fromUrl : Url -> Maybe Route
fromUrl url =
    Url.Parser.parse routeParser url


routeParser : Parser (Route -> a) a
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map Articles Url.Parser.top
        , Url.Parser.map Articles (s "articles")
        , Url.Parser.map Article (s "article" </> ArticleId.urlParser)
        ]
