---
title: Google TalkのステータスをWEBに表示するchatback
description: ''
date: '2008-02-26T10:35:13.000Z'
categories: []
keywords: []
slug: "bc4da79d-5a6d-4e67-a046-69f2a712736a"
---
Google Talkからやっとステータスを通知してくれるバッジ(chatback)がでました。[ここ](http://www.google.com/talk/service/badge/New)から作ることができます。さっそく右側に設置しています。

リンク: [Google Talkabout: Google Talk chatback](http://googletalk.blogspot.com/2008/02/google-talk-chatback.html "Google Talkabout: Google Talk chatback").

> Do you have a blog, online profile, or some other personal web page? Would you like to communicate more with your visitors? Today we’re launching a new Google Talk feature that lets visitors to your web site chat with you.

ここで軽いTipsを。これのタグは以下の通りになっています。

> <iframe src=”http://www.google.com/talk/service/badge/Show?tk=(random strings)&w=200&h=60" frameborder=”0" allowtransparency=”true” width=”200" height=”60"></iframe>

iframeのsrc urlにご注目。wとhというパラメータが見えると思います。これを変更するとサイズが自由に変更できるようです。このブログでは横幅が200もありませんでしたので、ここを変更しました。