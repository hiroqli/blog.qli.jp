---
title: Things Cloud “Nimbus”がリリースされた
description: ''
date: '2015-08-20T11:55:13.000Z'
categories: []
keywords: []
slug: Things+Cloud+%E2%80%9CNimbus%E2%80%9D%E3%81%8C%E3%83%AA%E3%83%AA%E3%83%BC%E3%82%B9%E3%81%95%E3%82%8C%E3%81%9F
---
Cultured CodeからThings Cloud “Nimbus”がリリースされました。Things Cloudというのは、Things で デバイス間データ同期を仲介するためのサービスです。

*   [Things Cloud “Nimbus” Released](http://culturedcode.com/things/blog/2015/08/things-cloud-nimbus-released.html)

Things上でThings Cloudにログインし、有効にすることで、Things上のデータが同期されます。

#### Nimbus でできるようになったこと

これまで、ThingsがThings Cloudとデータを同期するタイミングは、Thingsが起動しているときに限られていました。iOSの制限により、Thingsが終了しているときにはデータを同期することができませんでした。

Nimbusからは、AppleのPush Notification Serviceを使うことで、データの同期が必要なときにThingsを起動しデータを同期するとのこと。Apple側にThingsのデータを引き渡すのではなく、Thingsを起こす(wake)するためにPushの機構を使うようです。

#### 特に作業は必要ない

今回のリリースはCloud側のアップデートになり、デバイス側でアプリをアップデートしたりなどといった作業は必要ないとのこと。設定変更などもありません。

#### 常に最新に

こちらからの明示的なアクションがなくともMacでの作業内容がiOSにも同期されることで、常に最新データにアクセスすることができます。これはApple Watchのグランスもこれまで以上に最新データに表示されることを意味します。

Thingsは差分同期を行うため、そもそも同期にかかる時間は短くて済みます。今回のアップデートはそれ以上に「常に最新に」を目指すアップデートになりました。

Things 3の開発に随分時間がかかっているため、今回の Nimbus がここ最近では比較的大きめなアップデートになりました。

**p.s**  
最近、1日だけOmniFocusに乗り換える機会を持ちました。OmniFocusはさすがGTDのためのツールのことだけはあります。OmniFocusの方がたくさんタスクが出て頭のスッキリさを得ることができました。しかし、Thingsの方が同期を含んだ全体の使い勝手がいいことに改めて気付かされました。