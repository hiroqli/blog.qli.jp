---
title: Googleモバイルページの文字化け問題
description: ""
date: "2007-01-29T00:46:25.000Z"
categories: []
keywords: []
slug: "200701-5416092e-e7cf-4e23-bcea-8487b8d4de4e"
---

わりと昔の記事になるけど、文字化けしてしまっている Gmail の文字化けを直す方法が紹介されていた。

[» 携帯バージョン gmail の文字化けをなおす方法](http://ido.nu/kuma/2007/01/05/how-to-avoid-gmail-mobile-mojibake-problem/):

> いままで au 携帯から Gmail が文字化けの対処法 で見ていたのだけれど、なんとかならないかなーと電車の中でいじっていたら文字化けを回避する方法を見つけた。
>
> 解決法は、使う URL を
>
> https://mail.google.com/mail/?ui=mobile
>
> にすること。

これを参考に、今まで使っていた URL に ui=mobile を付与してみたが、文字化けは直らない。んで、しょうがないので上の URL を打ち込んでもどうやら直る気配がない。…あれ？と思いつつ URL を見直してみると、今まで使っていた URL が http だったので

> [http://mail.google.com/mail/?ui=mobile](http://mail.google.com/mail/?ui=mobile)

となってしまっていた。これを https に変えると文字化けしなかった。ちなみに、gmail.com ドメインでは Google.com ドメインの証明書で認証しようとする関係上、ケータイでは使えない(端末側が強制で認証しない)。

google reader も

> [http://www.google.com/reader/m/](http://www.google.com/reader/m/)

というモバイル用のページがあるのだけど、こちらも

> [https://www.google.com/reader/m/](https://www.google.com/reader/m/)

にすることで文字化けが解消された。

https のモジュールを更新し忘れているのか、それとも http 側の問題なのか、Google のモバイル向けページの文字化け問題はよくわかりません…。

p.s.:

試験環境は au W43S です。
