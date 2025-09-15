---
title: Growlに対応したTwitterrific
description: ''
date: '2007-06-28T18:12:10.000Z'
categories: []
keywords: []
slug: Growl%E3%81%AB%E5%AF%BE%E5%BF%9C%E3%81%97%E3%81%9FTwitterrific
---
TwitterのAPI制限に伴ってTwitなどクライアント側が対応されていますが、そんな中Mac用クライアントである[Twitterrific](http://iconfactory.com/software/twitterrific)がバージョンアップしていたのに気づきました。バージョンアップ版Ver2.1が公開されていたのが6月7日でしたので、ずいぶん気づかなかったことになります。

このバージョンアップで追加された機能、バグフィックス多数ありますが、一番大きいのがGrowlへの対応です。GrowlとはMacユーザなら必須といってもいいアプリで、いわばデスクトップ通知アプリですね。Windowsであれば、右下のタスクエリアに常駐させておけばアラートが吹き出しで出せるわけですが、Macの場合はこのGrowlが常駐していれば、各種アプリからその”吹き出し”のようなことが簡単にできるってわけです。  
twitterrificがgrowlに対応したことで、twitterrificをわざわざ開かなくてもどんな投稿があったかを確認することできるようになりました。

また、今まではtwitteririfcはキーチェインを参照して、Safariで使用したログインセッションを使っていたようなのですが、今回からtwitterrific自身にログイン情報を入力する必要がありますので、起動しておかしいなと思ったら、”コマンド+L”を押して入力画面を表示させてください。