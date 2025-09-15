---
title: SafariのGmailでの不調はfixされたらしい
description: ''
date: '2008-03-31T10:28:20.000Z'
categories: []
keywords: []
slug: Safari%E3%81%AEGmail%E3%81%A7%E3%81%AE%E4%B8%8D%E8%AA%BF%E3%81%AFfix%E3%81%95%E3%82%8C%E3%81%9F%E3%82%89%E3%81%97%E3%81%84
---
以前お伝えした問題、

> どうやらSafari3.1をインストールした方々から、

> Gmailでメールを書くときに、Shiftを押すとTABを押したような動作をする

> というような報告があがっているようです。

> \[From [きゅーり.jp: Safari3.1でGmailが不調なことがあるらしい](http://blog.qli.jp/2008/03/safari31gmail-5.html)\]

ですが、その後WebKitの bugzillaに[bug 16381](http://bugs.webkit.org/show_bug.cgi?id=16381)として登録され、fixされました。

buzillaの中で報告された現象は以下の通り：

1.  Gmail(http://mail.google.com/mail?ui=1)にログインする
2.  Older Linkを使うことなく、Gmail1.0を使う
3.  “compose message”(メール作成)リンクをクリック
4.  メッセージテキスト（本文部分）を選択
5.  シフトを押す
6.  カーソルが移動！

なお、シフト以外にもコマンドキー、オプションキー、コントロールキーでも同じ現象が起きることが判明しています。

しかし、Gmail側にも問題があるようなことにも言及されており、この修正は将来のsafariのバージョンにも適応されると思いますが、この問題の本来の原因は迷宮入りしそうです。Gmail 2.0では発生しないことからそのうちお蔵入りなんてこともあるかも。このbug自体もわりと紆余曲折しているので。

webKitがオープンソースだってことは知っていましたが、bugzillaを見るのは初めてでした。