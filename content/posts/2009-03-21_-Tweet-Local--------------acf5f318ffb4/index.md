---
title: "“Tweet-Local”なるものを作ってみました"
description: ''
date: '2009-03-21T15:31:47.000Z'
categories: []
keywords: []
slug: "%E2%80%9CTweet-Local%E2%80%9D%E3%81%AA%E3%82%8B%E3%82%82%E3%81%AE%E3%82%92%E4%BD%9C%E3%81%A3%E3%81%A6%E3%81%BF%E3%81%BE%E3%81%97%E3%81%9F"
---
きっかけはちょっとした思いつきだったのですが、作ってみたので公開します。その名も”[Tweet-Local](http://tweetlocal.qli.jp/)”です。一応アルファとしていますが、コンセプトレベルでの公開といった方が正しいでしょうね。(23:08 追記: 名前解決できているのですが、qli.jpのサブドメインではまだアクセスできないみたいです。[appspotのサブドメイン](http://tweetlocal.appspot.com/)ではアクセスできるのでぜひ）

簡単に説明すると、今開催中のイベントとイベントに紐付いたμブログでのつぶやきが見れるツールになっています。ここから会話を広げていくというよりも、とりあえず今は表示することに重きを置いてます。

イベントの情報は、いつも使わせていただいている[eventcast](http://clip.eventcast.jp/)さんから。そして、つぶやきの情報はジオ系μブログである[brightkite](http://brightkite.com/)と、μブログの代表サービス[twitter](http://twitter.com/)から取得しています。

イベントの情報とtwitterのつぶやきをどうやって結びつけるかというと、それがハッシュタグです。イベントにハッシュタグを追加していくことによって、そのハッシュタグに結びついたタイムラインを取得しています。

Uploaded with [plasq](http://plasq.com/)’s [Skitch](http://skitch.com)!

イベントの取得先についても、タイムラインの取得先についても、増やしていければいいなぁとは思っています。とっても使いやすいTODOリストツールであるcheckpadに[機能要望のリスト](http://www.checkpad.jp/list/show/850075)を作りましたので、よければ要望などいただければ。

twitterでご意見いただけるときは、#tweetlocal というハッシュタグでつぶやいていただければ拾いに行きます。

今回は、Google App Engineで作ってみました。フレームワークはGoogle App Engine Oilを使っています。不得手なpythonで困ったところはいっぱいあったので、はやくGAEでrubyが使えるようにならないかなぁとか思っていたり、思っていなかったり。