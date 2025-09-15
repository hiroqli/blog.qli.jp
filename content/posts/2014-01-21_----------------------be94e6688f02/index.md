---
title: バッテリーを著しく消費するアプリケーション
description: ''
date: '2014-01-21T00:17:22.000Z'
categories: []
keywords: []
slug: "%E3%83%90%E3%83%83%E3%83%86%E3%83%AA%E3%83%BC%E3%82%92%E8%91%97%E3%81%97%E3%81%8F%E6%B6%88%E8%B2%BB%E3%81%99%E3%82%8B%E3%82%A2%E3%83%97%E3%83%AA%E3..."
---
ここ数日、iPhone5sのバッテリーの持たなさに困っていました。

それはわりと急激に始まった感じで、どうしたらいいか困っていました。  
ハードウェアなのかソフトウェアなのかを切り分けるために、Apple Storeのジーニアスバーに持ち込んでみるも、ハードウェアの問題でないことは確実だったのですが、判明せず。

復元してみたり、初期化して一からアプリを入れ直してみたり。最後はbackgroundタスクを一度全部オフにして、それをひとつずつONにして様子を見るというようなことを行いました。それで分かったことは、fitbitアプリの background sync が悪さをしていること。

ちなみに fitbitのヘルプでも以下の通りの記載があります。

> Background sync may have an impact on battery life on both your iPhone device and your tracker. If you notice your battery draining quickly on either device, you may want to disable background sync.

> [fitbit help: Managing your tracker with the Fitbit app for iOS](https://help.fitbit.com/customer/portal/articles/1027415-managing-your-tracker-with-the-fitbit-app-for-ios)

fitbitアプリのbackground syncをオフにすることで、3時間くらいで 100% → 20%くらいまでバッテリーを消費するところを、16時間経過しても50%を切っていない状態になること、つまりバッテリーが持つことを確認しました。

実はこういうことはこれまでもよくありました。とてもひどいアプリではよく起こる現象です。ですが、iOS7でbackgroundタスクがそこそこ解禁されたことで問題アプリの特定までが複雑になってしまった感はあります。iOSにもそろそろ「エネルギー消費が著しいアプリケーション」を教えてくれる機能が欲しいですね。

ちなみに、ここであげているfitbitアプリは米fitbit社のアプリで、Softbankの契約者サービスであるfitbitがどうなっているかはよく分かりません。