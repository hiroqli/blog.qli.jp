---
title: "Things.appのINBOXを整理する"
date: "2025-10-04T03:01:53"
slug: "16a2a50d-647d-473a-8c09-6aab322657c7"
source: "medium"
original_url: "https://medium.com/@hiro/things-app%E3%81%AEinbox%E3%82%92%E6%95%B4%E7%90%86%E3%81%99%E3%82%8B-2e831224db25?source=rss-21bfda6f823e------2"
draft: false
---

本題に入る前に。これから Things という名前のアプリの話をします。Things ってアプリ名は一般用語なので、Things.app と表現しようと思います。ちなみに Things.app は公式 Bluesky アカウントのアカウント名でもあります（[@things.app](https://bsky.app/profile/things.app)）。

最近は Things.app を使っています。Things.app ってアプリ、あまり知られているアプリではないですが、Apple が時折出すアプリのアイコンがたくさん載っている現場によく出てきてたりします。Apple Store の iPhone 17 シリーズのデモ機にもインストールされているのを見つけました。[Things.app の同期のために作られたサーバー群 Things Cloud が、Swift で動いているようで](https://www.swift.org/blog/how-swifts-server-support-powers-things-cloud/)、サーバーサイド Swift 系のイベントでエンジニアが登壇していることが多いようです。

macOS26 Tahoe を使い始めて以降、刷新された Spotlight で Shortcut を使う機会が増えてきました。Things.app が用意している[公式 Shortcut のページ](https://culturedcode.com/things/support/articles/2955145/)を見てみたところ、いくつか Apple Intelligence を使った Shortcut が用意されているのを見つけました。このうち「Actionize Inbox」というタイトルのものをよく使っています。

こういう「タスク管理アプリ」を使うときに、一番よく使うのが、Web やメールからのタスクの追加です。仕事ではなくプライベートでも、「気になってたバンドの新曲をチェックする」とか「ライブのチケットの予約抽選に申し込む」というリマインダーを設定したいなという場面が日々発生します。Mac だとキーボードショートカットからクイック入力を呼び出してタイトルを書いたり、Web に載っている文章をコピーしたりするのですが、iPhone や iPad だと意外と面倒だったりします。

そこで、「Things.app に追加」Shortcut を自作しました。Things.app のインボックスに、メモ欄に構造化して markdown フォーマットにした to-do を追加できるようにしました。Things.app は markdown フォーマットに対応しているのと、長いメモでも操作に支障が出ない UI を持っているので、こういうときとても楽です。

その次に登場するのが[公式 Shortcut ページ](https://culturedcode.com/things/support/articles/2955145/)にあった「Actionize Inbox」です。この Shortcut は、インボックスにある to-do を確認して、そのメモ欄からタイトルを考え出してくれます。プロンプトがいいのかもしれないですが、とても適切にタイトルを考えてくれるのでとても楽になっています。また、メモ欄をプロンプトに含めてくれるので、もし違うタイトルが出てきた場合はメモ欄を更新してやってみることもできます。

実際に使ってみて、この 2 つの Shortcut の組み合わせでタスク追加の流れがかなり定着しました。気になった情報をコピーして追加しておく。そして時間があるときに Actionize Inbox を実行して、タイトルを整理する。この流れができてから、「後で整理しなきゃ」というプレッシャーがなくなって、気軽にタスクを追加できるようになりました。Things.app を使っている人は、ぜひ試してみてください。

## 追記：同じことを OmniFocus で実現したい

同じことが OmniFocus で実現できるかもやってみました。Things はショートカットの機能から「to-do を編集」することができるのですが、OmniFocus では提供されていません。Omni Automation のスクリプトをショートカットで実行する機能が提供されているのでそれを使って実現することが可能なため、Claude にスクリプトを作ってもらって実行することができています。

Omni Automation のみで同じことを実現することも論理的には可能なのです。しかし、Omni Automation では Apple Intelligence の LLM のうちオンデバイスのみが利用可能で、性能が足りないのを感じてしまいます。
