module Api exposing
    ( getArticle
    , getArticles
    , writeToServerLog
    )

import Article exposing (Article)
import ArticleId exposing (ArticleId)
import ArticleSummary exposing (ArticleSummary)
import Http
import Json.Decode
import LogElement exposing (LogElement)


getArticles : (Result Http.Error (List ArticleSummary) -> msg) -> Cmd msg
getArticles msg =
    Http.get
        { url = "/api/articles"
        , expect = Http.expectJson msg (Json.Decode.list ArticleSummary.decode)
        }


getArticle : (Result Http.Error Article -> msg) -> ArticleId -> Cmd msg
getArticle msg articleId =
    Http.get
        { url = "/api/article/" ++ ArticleId.toString articleId
        , expect = Http.expectJson msg Article.decode
        }


writeToServerLog : (Result Http.Error () -> msg) -> LogElement -> Cmd msg
writeToServerLog msg logElement =
    Http.post
        { url = "/log"
        , body =
            logElement
                |> LogElement.encode
                |> Http.jsonBody
        , expect = Http.expectWhatever msg
        }
