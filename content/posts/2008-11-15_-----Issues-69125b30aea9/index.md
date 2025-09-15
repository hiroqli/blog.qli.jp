---
title: 移行に伴うIssues
description: ''
date: '2008-11-15T09:56:44.000Z'
categories: []
keywords: []
slug: "%E7%A7%BB%E8%A1%8C%E3%81%AB%E4%BC%B4%E3%81%86Issues"
---
ブログの移行からいろいろ分かったことがあるのでまとめておきます。何かの参考になれば。

**一部の記事にURL変更が発生しています**

Movable Typeもそうなのですが、TypepadではタイトルからURLを生成するのが基本です。URLを移行時に再生成していて、タイトルに変更がなかったものはいいのですが、変更があったものはURLが変更されデッドリンクとなっているようです。URLはリソースを表す重要な文字列だと思っていますので、本来、URLをオリジナルにあわせるべきだと思います。これについては、分かる範囲で対処していきます。(という問題があってこのブログがWordpress系に移行することはきっとないでしょう)

**はてなブックマークへのリンクがなくなりました**

日本語のブログにとって致命的だと思っているのですが、はてなブックマークへのリンクがなくなりました。以前はTypepad.jpが提供してくれていたのですが、Typepad.comでは当然のことながら提供してくれていません。テンプレート(HTML)を触らずにはてなスターみたいにつけられる方法を探したいと思います。

**FeedBurnerの購読者数が500から100に減りました**

このブログでは以前からフィードにFeedburner.jpを利用しています。たとえば、Google ReaderなんかでフィードのURLを直接購読するのではなく、 [http://blog.qli.jp/](http://blog.qli.jp/) を購読するようにしてしまうと、オートディスカバリー機能で、ブログのオリジナルのフィードを購読することになってしまいます。

Typepad.jpではFeedburner.jpとの連携機能により、オリジナルフィードへのリクエストをfeedburnerに転送する機能を利用していたのですが、Typepad.comの方では Feedburner.comとの連携機能はあるものの、Feedburner.jpとの連携はできませんでした（Feedbuner.jpとFeedburner.comは同じサービスを提供していますがアカウント体系が異なります)。ですので、現在連携できていない状態です。一応要望は出しておきましたが、もし差し支えなければ一度確認いただきfeedburner側のURLの方を購読し直していただけると、非常にありがたいです。feedburner.jp側のURLは [http://feeds.feedburner.jp/qli](http://feeds.feedburner.jp/qli) です。

Google Readerで購読者数を調べたところ以下のようになっていました：

*   feedburner.jp : 52人
*   Atom : 105人
*   RSS 1.0 : 6人
*   RSS 2.0 : 6人

ちなみにこのブログで次に利用者数が多いのはLivedoor Readerですが、そちらでは確認していません。