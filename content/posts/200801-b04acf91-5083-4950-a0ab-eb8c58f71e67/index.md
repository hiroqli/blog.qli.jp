---
title: MacBook Black(CoreDuo)でWindows Vistaを動作させてみた(on VMware Fusion)
description: ''
date: '2008-01-06T12:17:30.000Z'
categories: []
keywords: []
slug: "b04acf91-5083-4950-a0ab-eb8c58f71e67"
---
うちにはメインであるMacBookと、そしてサブ機として自作PC(Windows Vista)があります。もともとサブ機はWindows時代のメイン機で、当時はWindowsでゲーム(FPSとか）もやっていたので、ミドルハイエンドくらいのスペックがあったりします。で、せっかくMacでWindowsが動くようになったのだから動かしたいと思っていたのですよ。もうゲームはXBOX360で満足していて、Windowsで動かす必要性もないので。

で、年末にMacBookにBootcampでWindows Vistaを入れてみました。一通りドライバ周りとか設定終わったところで動作を見てみると、わりと問題なし。もちろん初代MacBookということもあってAeroはオフで、それでもグラフィック的にはきつそうでしたが。

それをすでに購入済みのVMware Fusionで動かしてみました。FusionにはBootcamp上のWindowsを動かせるという機能があるのでそれを使いました。すると動作は激重。実際のところ、Fusion上では、Fedora Linuxを動作させても重いなぁと感じる部分もあったりして、あまり期待はしていなかったですが。

いろいろ状況を見てみると、やっぱりハード上で2GBのメモリしかもっていないところにLeopardとWindowsの２つのOSを動作させることにムリがあるのかなという印象を受けました。というわけで、メモリを4GB積める最新のMacBookにせめて買い換えたいなという結論でした。1月のAppleラインナップ刷新時期ではありますが、最新のサンタさんMacBook上で仮想環境で快適にVista使っているよって方がいたら、感想聞かせてください。