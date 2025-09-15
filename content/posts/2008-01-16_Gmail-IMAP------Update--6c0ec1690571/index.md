---
title: Gmail IMAPの挙動変更[Update]
description: ''
date: '2008-01-16T08:02:17.000Z'
categories: []
keywords: []
slug: Gmail+IMAP%E3%81%AE%E6%8C%99%E5%8B%95%E5%A4%89%E6%9B%B4%5BUpdate%5D
---
KeynoteにてiPhoneそしてiPod Touchのアップデートが発表されましたが、 それにあわせて、Gmail公式ブログより、メールアプリの挙動が変更されたことが発表されました。

iPhoneリリース時はIMAPリリース前だったのですが、今回IMAPリリースに伴い、gmailのデフォルトアクセスがIMAPに変更されたそうです。またあわせて、ゴミ箱がIMAP上のゴミ箱になるように設定されており、受信箱からメールを削除すると、これまで”すべてのメール”になっていたものが”ゴミ箱”に入るようになっているそうです。

iPod Touchの追加アプリでも上記が当てはまります。またメールソフトからゴミ箱をIMAP上のゴミ箱に連携させると同様の動作になることも確認しました。GmailをIMAPでアクセスしていて、メールソフトのゴミ箱とIMAPのゴミ箱を連携させている方は注意が必要です。

> If you delete a message on your iPhone, it will be moved to the Trash in Gmail and permanently deleted in 30 days.

> \[From [Official Gmail Blog: Important changes to email deletion on the iPhone mail client](http://gmailblog.blogspot.com/2008/01/important-changes-to-email-deletion-on.html)\]

**追記：**改めてThunderbirdで確認してみると上記のような挙動にはならなりませんでした。またiPod Touchから削除してみたメールはInboxとTrashのタグが付く状態となっていました。もしかするとiPhone/iPod TouchのMail.app独自の機能追加でもされたのかもしれません。引き続き確認してみますが、もしこうだよ、という情報があればお寄せいただけると助かります。

**追記２:**試験してみたところ、Mail.appでは削除動作=ゴミ箱移動となるようですが、Thunderbirdでは[こちら](http://mail.google.com/support/bin/answer.py?answer=78892)を参考にした設定で”削除としてマークする”を選択していることから、削除動作ではゴミ箱の移動を行わないという点が異なることに気づきました。どうやらGmailではゴミ箱への移動をもってメールの削除としているようです。若干混乱しますが気をつける必要がありそうです。