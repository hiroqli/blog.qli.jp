---
title: "Things.appのINBOXを整理する"
date: "2025-10-04T03:01:53"
slug: "16a2a50d-647d-473a-8c09-6aab322657c7"
source: "medium"
original_url: "https://medium.com/@hiro/things-app%E3%81%AEinbox%E3%82%92%E6%95%B4%E7%90%86%E3%81%99%E3%82%8B-2e831224db25?source=rss-21bfda6f823e------2"
draft: false
---

本題に入る前に。これからThingsという名前のアプリの話をします。Thingsってアプリ名は一般用語なので、Things.app と表現しようと思います。ちなみに Things.app は公式Blueskyアカウントのアカウント名でもあります（[@things.app](https://bsky.app/profile/things.app)）。

最近はThings.appを使っています。Things.appってアプリ、あまり知られているアプリではないですが、Appleが時折出すアプリのアイコンがたくさん載っている現場によく出てきてたりします。Apple StoreのiPhone 17シリーズのデモ機にもインストールされているのを見つけました。[Things.appの同期のために作られたサーバー群Things Cloudが、Swiftで動いているようで](https://www.swift.org/blog/how-swifts-server-support-powers-things-cloud/)、サーバーサイドSwift系のイベントでエンジニアが登壇していることが多いようです。

macOS26 Tahoeを使い始めて以降、刷新されたSpotlightでShortcutを使う機会が増えてきました。Things.appが用意している[公式Shortcutのページ](https://culturedcode.com/things/support/articles/2955145/)を見てみたところ、いくつかApple Intelligenceを使ったShortcutが用意されているのを見つけました。このうち「Actionize Inbox」というタイトルのものをよく使っています。

こういう「タスク管理アプリ」を使うときに、一番よく使うのが、Webやメールからのタスクの追加です。仕事ではなくプライベートでも、「気になってたバンドの新曲をチェックする」とか「ライブのチケットの予約抽選に申し込む」というリマインダーを設定したいなという場面が日々発生します。Macだとキーボードショートカットからクイック入力を呼び出してタイトルを書いたり、Webに載っている文章をコピーしたりするのですが、iPhoneやiPadだと意外と面倒だったりします。

そこで、「Things.appに追加」Shortcutを自作しました。Things.appのインボックスに、メモ欄に構造化してmarkdownフォーマットにしたto-doを追加できるようにしました。Things.appはmarkdownフォーマットに対応しているのと、長いメモでも操作に支障が出ないUIを持っているので、こういうときとても楽です。

その次に登場するのが[公式Shortcutページ](https://culturedcode.com/things/support/articles/2955145/)にあった「Actionize Inbox」です。このShortcutは、インボックスにあるto-doを確認して、そのメモ欄からタイトルを考え出してくれます。プロンプトがいいのかもしれないですが、とても適切にタイトルを考えてくれるのでとても楽になっています。また、メモ欄をプロンプトに含めてくれるので、もし違うタイトルが出てきた場合はメモ欄を更新してやってみることもできます。

実際に使ってみて、この2つのShortcutの組み合わせでタスク追加の流れがかなり定着しました。気になった情報をコピーして追加しておく。そして時間があるときにActionize Inboxを実行して、タイトルを整理する。この流れができてから、「後で整理しなきゃ」というプレッシャーがなくなって、気軽にタスクを追加できるようになりました。Things.appを使っている人は、ぜひ試してみてください。

#### 追記：同じことをOmniFocusで実現したい

同じことがOmniFocusで実現できるかもやってみました。Thingsはショートカットの機能から「to-doを編集」することができるのですが、OmniFocusでは提供されていません。Omni Automationのスクリプトをショートカットで実行する機能が提供されているのでそれを使って実現することが可能なため、Claudeにスクリプトを作ってもらって実行することができています。

Omni Automationのみで同じことを実現することも論理的には可能なのです。しかし、Omni AutomationではApple IntelligenceのLLMのうちオンデバイスのみが利用可能で、性能が足りないのを感じてしまいます。

![](https://medium.com/_/stat?event=post.clientViewed&referrerSource=full_rss&postId=2e831224db25)