---
title: JaikuのAPI KEYがリセットされた
description: ''
date: '2008-01-25T07:55:00.000Z'
categories: []
keywords: []
slug: "200801-7812b2b1-4679-4726-9835-ed3287aea18d"
---
Jaikuから”API KEY をリセットしたよ”というお知らせがありました。API KEYとはサードパーティのクライアントを使うためのパスワードのようなもの。juhuやjaikurooで書き込みないと思っている方がいたら確認してみてください。

リセットした理由についてもブログで語られており、下記で引用しているとおり、iGoogle ガジェットとして開発されたクライアントに脆弱性が発見されたから、とのこと。このクライアントが修正されたかどうかは分かりませんが、気をつけましょう。

> Here’s why: a Jaiku user recently let us know about a security vulnerability in an iGoogle gadget developed by a third party.

> \[From [Jaikido Blog | API keys have been reset](http://www.jaiku.com/blog/2008/01/25/api-keys-have-been-reset/)\]

なお、API KEYはログインしていれば、[http://jaiku.com/api](http://jaiku.com/api) から取得することができます。