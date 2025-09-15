---
title: MacBook Black(CoreDuo)でWindows Vistaを動作させてみた(on VMware Fusion)
description: ''
date: '2008-01-06T12:17:30.000Z'
categories: []
keywords: []
slug: MacBook+Black%28CoreDuo%29%E3%81%A7Windows+Vista%E3%82%92%E5%8B%95%E4%BD%9C%E3%81%95%E3%81%9B%E3%81%A6%E3%81%BF%E3%81%9F%28on+VMware+Fusion%29
---
うちにはメインであるMacBookと、そしてサブ機として自作PC(Windows Vista)があります。もともとサブ機はWindows時代のメイン機で、当時はWindowsでゲーム(FPSとか）もやっていたので、ミドルハイエンドくらいのスペックがあったりします。で、せっかくMacでWindowsが動くようになったのだから動かしたいと思っていたのですよ。もうゲームはXBOX360で満足していて、Windowsで動かす必要性もないので。

で、年末にMacBookにBootcampでWindows Vistaを入れてみました。一通りドライバ周りとか設定終わったところで動作を見てみると、わりと問題なし。もちろん初代MacBookということもあってAeroはオフで、それでもグラフィック的にはきつそうでしたが。

それをすでに購入済みのVMware Fusionで動かしてみました。FusionにはBootcamp上のWindowsを動かせるという機能があるのでそれを使いました。すると動作は激重。実際のところ、Fusion上では、Fedora Linuxを動作させても重いなぁと感じる部分もあったりして、あまり期待はしていなかったですが。

いろいろ状況を見てみると、やっぱりハード上で2GBのメモリしかもっていないところにLeopardとWindowsの２つのOSを動作させることにムリがあるのかなという印象を受けました。というわけで、メモリを4GB積める最新のMacBookにせめて買い換えたいなという結論でした。1月のAppleラインナップ刷新時期ではありますが、最新のサンタさんMacBook上で仮想環境で快適にVista使っているよって方がいたら、感想聞かせてください。