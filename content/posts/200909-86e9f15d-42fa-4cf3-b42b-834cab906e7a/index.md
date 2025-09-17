---
title: iTunes MusicからiTunes Mediaへ
description: ''
date: '2009-09-26T11:59:03.000Z'
categories: []
keywords: []
slug: "200909-86e9f15d-42fa-4cf3-b42b-834cab906e7a"
---
どうやらiTunes9では、メディアの管理方法が変更されたそうです。とはいっても、自動で変更されるのではなく、アップデートの場合はとくに変更しない限り従来のスタイルで管理しているとか。というわけで、詳細はAppleのヘルプページ[”iTunes 9：iTunes Media 方式によるファイルの整理方法について](http://support.apple.com/kb/HT3847?viewlocale=ja_JP)”を読んでください。

ちなみに自分の環境では、”iTunes Music”のフォルダ名が”iTunes Media”に変更されませんでした。1度でも変更したことがあるとかだとダメなのかもしれません。

で、ここで注目したいのが「iTunesに自動的に追加」というフォルダ。不思議なフォルダだなと思ったら、こういうことみたいです。

> iTunes 9 以降には、「iTunes Music」または「iTunes Media」\* フォルダの下に「iTunes に自動的に追加」フォルダがあります。このフォルダに iTunes 互換コンテンツが読み込まれ、iTunes で互換性があるかどうか解析されて、iTunes ライブラリに追加されます。ファイルに互換性がない場合は、「追加なし」フォルダに置かれます。

> \[From [iTunes 9：「iTunes に自動的に追加」フォルダについて](http://support.apple.com/kb/HT3832?viewlocale=ja_JP)\]

つまり、Apple Scriptやシェルスクリプトなどで作業しやすくなりましたよ、ということなんじゃないかと思います。これが何を意味することになるのかは分かりませんが、こういうインターフェイスの拡張は注目してあげるべきではないでしょうか。