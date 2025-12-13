---
title: SocialThing!の招待メールが届いた
description: ''
date: '2008-04-05T00:37:38.000Z'
categories: []
keywords: []
slug: "c245d0ce-6746-4bb0-a94a-f96be6524648"
---
こちらはTechCrunchで紹介されてわりと長い間待ったんですが、やっと今日届いて使い始めている感じです。そもそも使いたいと思ったのは

> しかしFriendFeedに強力なライバルが現れた。TechStarsからのスタートアップ「Socialthing!」だ。こちらのほうが、友達がウェブ上で今何をしているかを知るのに、FriendFeedよりさらに使いやすい

> \[From [TechCrunch Japanese アーカイブ » FriendFeed、ご注意！ ―Socialthing!はもっと使いやすい](http://jp.techcrunch.com/archives/watch-out-friendfeed-socialthing-is-even-easier-to-use/)\]

書いてあってFriendFeedが面白い！と思っている自分としては試してみないわけにはいかないだろうと思ったからです。 というわけで、Socialthing!もFriendFeedと同種のサービス、ということは他のサービスのデータを持ってきて再構成する系のサービスだってことは理解してもらえると思います。

詳細は不明ですが、現在使える”他のサービス”はLiveJournal、Pownce、Facebook、Flickr、twitter、vimeoの６つだけ。他のサービスは「何を使いたいか？」という投票が行われている状態です。これらのサービスで主に使っているのはtwitterのみなので、これを登録して様子見している状態ですが、これがまた面白い。

(非公開にしている人もいるのでスクリーンショットをお見せできないのが悔しいのですが）、twitterのフィードが発言者別に並んでいるのです。SQL風に表すと、twitterでは ORDER BY DATETIME DESC で並んでいるのが、Socialthing!では ORDER BY USER, DATETIME DESC で並んでいる感じというとわかりやすいでしょうか？こういう再構成のあり方はありかなと思います。

FriendFeedと同じく、APIクライアントとして投稿することもできるのですが、どうやら日本語は通らないみたいです。

このサービス、招待メールを2通だけお送りすることができるのですが、興味ある方はぜひ右のメールアドレスあてにコンタクトください。2通なので厳正なる個人的趣味による抽選になってしまうと思うのですが。そうですね、たぶんブログとかでレビューを書いてくれそうな人とかに優先するかもしれません。