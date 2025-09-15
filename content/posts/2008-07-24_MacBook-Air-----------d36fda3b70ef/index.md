---
title: MacBook Airのシングルコア化問題
description: ''
date: '2008-07-24T21:35:32.000Z'
categories: []
keywords: []
slug: MacBook+Air%E3%81%AE%E3%82%B7%E3%83%B3%E3%82%B0%E3%83%AB%E3%82%B3%E3%82%A2%E5%8C%96%E5%95%8F%E9%A1%8C
---
MacBook Airを買って、約4ヶ月。性能には問題は感じていないのですが、問題点がひとつありました。それはCPUのシングルコア化です。

これについては、いろいろな話があって、「intelのCPUの仕様だ」とかそういう話が幅をきかせている（実際自分も信じてはいた）のですが、熱上昇によるシングルコア化は修理対応になるべきものだそうです（via [Apple Discussion](http://discussions.info.apple.co.jp/WebX?14@616.v9yccqoyojp.51@.f0406b2/65))。夏になって、よくシングルコア化するなーと思われる方はぜひ一度ジーニアスに持ち込んでみるのもいいかもしれません。

自分もそれに該当するかというとちょっと違うようで、そもそもシングルコア化になるときにはCPU利用率のうちシステム利用率が異常に上がるという状況でした。プロセスレベルに話を落としていくと”kernel\_task”、そして”DockSyncClient”がCPUリソースを食い尽くすという感じでした。

それで探してみたところ、[アメリカのApple Discussion](http://discussions.apple.com/thread.jspa?messageID=7146454&#7146454)にて解決方法と見られるものが見つかりました。方法は次の通りです。

1.  ターミナルを開いてコマンドを実行：killall SyncServer syncuid SystenUIServer
2.  /home/\[login-id\]/ライブラリ/Application Support/SyncServicesをごみ箱へ
3.  マシン再起動
4.  MobileMeの同期をする

これを実行したところ、kernel\_taskのメモリ使用量が減りました。そしてMobileMe Syncが早く終わるようになりました。MacBook Airだけではなく、Leopardを使っていて、原因不明のシステム高負荷に悩んでいる方は一度試してみるのもいいかもしれません。ただし自己責任でお願いします。