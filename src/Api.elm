module Api exposing
    ( createCommentOnArticle
    , createSubcommentOnArticle
    , getArticle
    , getArticles
    , getComments
    , getNestedComments
    , writeToServerLog
    )

import Article exposing (Article)
import ArticleId exposing (ArticleId)
import ArticleSummary exposing (ArticleSummary)
import Comment exposing (Comment)
import CommentForm exposing (ValidatedCommentForm)
import CommentId exposing (CommentId)
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


getComments : (Result Http.Error (List Comment) -> msg) -> ArticleId -> Cmd msg
getComments msg articleId =
    Http.get
        { url = "/api/article/" ++ ArticleId.toString articleId ++ "/comments"
        , expect = Http.expectJson msg (Json.Decode.list Comment.decoder)
        }


getNestedComments : (Result Http.Error (List Comment) -> msg) -> ArticleId -> Cmd msg
getNestedComments msg articleId =
    Http.get
        { url = "/api/article/" ++ ArticleId.toString articleId ++ "/nestedComments"
        , expect = Http.expectJson msg (Json.Decode.list Comment.decoder)
        }


createCommentOnArticle : (Result Http.Error (List Comment) -> msg) -> ArticleId -> ValidatedCommentForm -> Cmd msg
createCommentOnArticle msg articleId form =
    Http.post
        { url = "/api/article/" ++ ArticleId.toString articleId ++ "/comments"
        , body = Http.jsonBody (CommentForm.encode form)
        , expect = Http.expectJson msg (Json.Decode.list Comment.decoder)
        }


createSubcommentOnArticle : (Result Http.Error (List Comment) -> msg) -> ArticleId -> CommentId -> ValidatedCommentForm -> Cmd msg
createSubcommentOnArticle msg articleId commentId form =
    Http.post
        { url = "/api/article/" ++ ArticleId.toString articleId ++ "/comments/" ++ CommentId.toString commentId ++ "/comments"
        , body = Http.jsonBody (CommentForm.encode form)
        , expect = Http.expectJson msg (Json.Decode.list Comment.decoder)
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
