---
title: Gmail IMAPは快適です。
description: ''
date: '2007-11-30T23:00:03.000Z'
categories: []
keywords: []
slug: "200711-cad7f6a3-e079-4ba1-bce0-340781b12673"
---
以前、[Gmail IMAPに関する話](http://blog.qli.jp/2007/10/gmail_imap_cc24.html)を書いたけれども、いろいろ使ってみて分かったことがあるので、修正＋補足を。

WEB上では未読メールがINBOXに着信し、それを読んでArchivesすることで、All Mailに移動される。これがIMAP上では、未読メールもAll Mailに入っているので、Archivesを改めてやる必要がないようだ。

つまり、どういうことかというと、INBOX上のメールを読んだ後削除すれば、WEB上でArchiveしたのと同じということ。実は最近[muttというコマンドラインでメールを読むクライアント](http://hiroqli.blogspot.com/2007/11/mutt-15mutt-gmail-imap.html)でGmail IMAPにアクセスすることがあるのだけど、これだと読んで削除すればいいだけなので、楽。

ちなみに、読んで気になれば、フラグ（たいていのメールソフトにはついてますよね）をたててあげれば、スターをつけたのと同じになって、Starredディレクトリに現れるようになる。[WEBとIMAPの操作の対応表](http://mail.google.com/support/bin/answer.py?answer=77657)はGmailヘルプにあるのでご参照を。

モバイルとかでも、INBOXだけ確認しておけばいいので楽ですね。Windows MobileのOutlookで試そうかと思ったのですが、変なディレクトリをGmail上で作っちゃうので困り中です。でも、この方式、慣れると快適すぎて、.Macもこういう方式になってくれないかなとか本気で思い始めました。