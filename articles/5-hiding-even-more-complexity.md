# 5-hiding-even-more-complexity

title: Hiding Even More Complexity lead: With one-constructor opaque types author: Aksel Wester image: [https://images.unsplash.com/photo-1480732149909-d4e710a0f81c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1500&q=80](https://images.unsplash.com/photo-1480732149909-d4e710a0f81c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1500&q=80) links:

* title: Elm 0.19 release note

  link: [https://github.com/elm/compiler/blob/master/upgrade-docs/0.19.md\#--optimize](https://github.com/elm/compiler/blob/master/upgrade-docs/0.19.md#--optimize)

* title: Hiding complexity with opaque types

  link: [https://elm.christmas/2018/17](https://elm.christmas/2018/17)

When Elm 0.19 was released, I remember reading the following sentence in [the release notes](https://github.com/elm/compiler/blob/master/upgrade-docs/0.19.md#--optimize) and being really confused:

> Unbox things like `type Height = Height Float` to just be a float at runtime

`Height` in this example is clearly a custom type with only one constructor, which is also called `Height`. I didn't even know that was possible before reading the release notes! And why would you want to do that?

## Hiding complexity

As we saw in the article from yesterday about [hiding complexity with opaque types](https://elm.christmas/2018/17), we can create modules that expose a custom type, but not its constructors, to make types where the users of the type can't know or rely on the implementation details of that type. This allows us to later change the implementation of our type, without having to work through compiler errors throughout our application afterwards.

But what if the type we are trying to hide the implementation of is best modelled as a record, or even an `Int` or a `String`? In this case we can use a custom type with only one constructor, where that one constructor takes the actual representation of our type as an argument. Then we can make that custom type opaque, to hide the implementation.

Let's look at an example of this. Say we have a type `ArticleId` in our application, which is the ID of an article. On the server, this ID is simply a string like "ab10-b42c". We could make this type by simply creating a type alias like this: `type alias ArticleId = String`. This, however, would only give us a new name to refer to `String`, and in our application, we don't actually want IDs to be treated like strings. Because strings have functions like concatination and `toUpper`, and if we were to use those on an ID, it would probably make it stop being an ID.

What we can do instead is to create an opaque `ArticleId` type, which is just a wrapper around `String`, like this:

```text
module ArticleId exposing (ArticleId)

type ArticleId = ArticleId String
```

Note that there is no `(..)` after `ArticleId` in the exposing list, making `ArticleId` opaque to any users of this module. Note also that we name the one option of our type the same as the type itself. This is common to do in custom types with only one option.

If we wanted users of the module to still get access to the `String` inside the type, we could achieve that by writing a helper function, for instance named `toString`. But note that by doing this, we still haven't allowed for the creation of new `ArticleId`s, which we would probably only want with a decoder.

To get access to the `String` inside the type, we could do this the same way we would with any other custom type, and use a `case` expression like this:

```text
module ArticleId exposing (ArticleId, toString)

type ArticleId = ArticleId String

toString : ArticleId -> String
toString id =
    case id of
        ArticleId string ->
            string
```

In the function above we use a `case` expression to check which option of `ArticleId` our `ArticleId` is. But since our `ArticleId` custom type only has _one_ option, this results in a couple of lines of unnecessary code each time we want to access the value inside `ArticleId`. Which, in turn, would result in a lot of boilerplate code if we have a lot of functions in our `ArticleId` module. Luckily there is an even easier way to get access to the value inside our one-constructor custom type!

To get access to the value we can use destructuring on the function argument directly, like this:

```text
module ArticleId exposing (ArticleId, toString)

type ArticleId = ArticleId String

toString : ArticleId -> String
toString (ArticleId string) =
    string
```

This destructuring only works with custom types with one constructor, but is a great convenience when writing helper functions for such types. The method does, however, work with however many arguments that one constructor takes. We can even combine custom type destructuring with record destructuring if we have a custom type which contains a record!

## The final module

The final module we end up with is this following file, which is everything we need from this module:

```text
module ArticleId exposing (ArticleId, toString, decoder)

import Json.Decode exposing (Decoder)

type ArticleId = ArticleId String

toString : ArticleId -> String
toString (ArticleId string) =
    string

decoder : Decoder ArticleId
decoder =
    -- Decoder code here
```

In addition to exposing the `ArticleId` type, and the `toString` function, we also expose a `decoder`, which we won’t go into implementing in this article. The module is not long at all, and that’s okay, because it separates the structure of an `ArticleId` from the places where it is used.

## Summary

In this article we have seen how to hide the implementation of types other than custom types, by wrapping those type in opaque, one-constructor custom types. This, combined with the opaque types we looked at yesterday, makes us able to hide the implementation of any type we want, which is great for containing complexity and making even more maintainable code!

And as a bonus, Elm 0.19 even unwraps our one-constructor custom types at compile time, so there is no downside in bundle size in creating custom types like this!

