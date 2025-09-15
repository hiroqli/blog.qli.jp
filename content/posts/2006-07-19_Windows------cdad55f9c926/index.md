---
title: Windowsの開発環境
description: ""
date: "2006-07-19T09:01:00.000Z"
categories: []
keywords: []
slug: "97b75157-2dc9-40c2-9d3a-d6f97b6900b2"
---

Windows の開発環境を書いておく。  
基本的に、PHP やら perl やらはエディタがあれば十分なので、[MKEditor](http://www.mk-square.com/home/software/mkeditor/)を使用している。これを選んだ基準は色分けの柔軟さと機能の豊富さ。こいつが持っている Grep 機能は意外と使うことが多い。本当は PHP だと専用エディタとかもあるんだけど、それほど使えていない + 高機能なものはいらない。  
Java のときは[Eclipse](http://eclipsewiki.net/eclipse/ "EclipseWiki")を使用している。本当はこいつにプラグイン入れて PHP 開発できるようにした方が便利かもなとか思う。

簡単な修正には、[TeraPad](http://www5f.biglobe.ne.jp/%7Et-susumu/)を使うことが多い。メモ帳代わりに使っている常用テキストエディタなので。実は、昔の DOS 時代に[N88BASIC](http://ja.wikipedia.org/wiki/N88BASIC)をさわっていたせいか、黒背景に白地が落ち着く。

あとは、一応「某サイト」のソース管理に SVN を使っているので、[TortoiseSVN](http://tortoisesvn.tigris.org/)を入れている(PPC Fedra サーバが SVN サーバとなっている)。こいつは本家 SVN なくてもバージョン管理ができるので、ローカルでのドキュメント管理にもいいかも。コミット前の試験環境として Apache(php も)と MySQL が入っている状態。昔は IIS で http サーバたててたけど、やっぱ Apache の方が落ち着く(笑)
