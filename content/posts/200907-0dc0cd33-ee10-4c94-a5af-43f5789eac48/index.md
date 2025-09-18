---
title: Gmailが外部SMTPサーバをサポート
description: ''
date: '2009-07-31T23:03:33.000Z'
categories: []
keywords: []
slug: "0dc0cd33-ee10-4c94-a5af-43f5789eac48"
---
意外に話題にならないようなのですが、Gmailが外部のSMTPサーバをサポートしました。([Gmail blog](http://gmailblog.blogspot.com/2009/07/send-mail-from-another-address-without.html))

これまでGmailには、Fromを切り替えられる機能、そしてメールを取得することのできる機能(Mail Fetcher)がありましたが、今回から外部のSMTPサーバを使ってメールを送信することができるようになりました。

これまではFromを選択していても、Fromのドメインとメール送信元のサーバのドメインが異なっていて、かつなりすまし防止のためにSenderにGmailのオリジナルアドレスが記載されていたために、たとえば送信元としてFromではなくSenderを表示するLiveメールなどでは、Gmailから送信したことがバレてしまうという問題がありました。

この機能を使うことで、Fromのドメインと同一のメールサーバに一旦リレーすることで、受信側では正当なメールとして認識することができるようになり、Senderヘッダが必要なくなるということになります。ビジネス上、Gmail Appのエイリアスドメインなどを利用している場合にとても有効な変更となります。

なお、MobileMeで設定する場合には、ポート番号25、SSLをオフにしないとうまく設定できないようです。

ただし、メールヘッダにはきちんとGmailサーバからメールリレーが始まったことが記載されるため、完全にGmailから分離されるわけではありません（当たり前ですが）

Uploaded with [plasq](http://plasq.com/)’s [Skitch](http://skitch.com)!