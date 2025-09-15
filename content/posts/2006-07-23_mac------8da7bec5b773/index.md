---
title: macの開発環境
description: ''
date: '2006-07-23T23:33:44.000Z'
categories: []
keywords: []
slug: "60ccbb23-d802-4f83-a3ec-c5fb1154a525"
---
久々にectoから書き込み。

Windowsの開発環境は書いたので、macでの開発環境を書いておく。  
  
Macのエディタはなんといっても[CotEditor](http://www.aynimac.com/p_blog/files/index2.php)。これ、かなり使いやすくておすすめ。こいつをWindows版に書き直したものがあればそれを使いたいくらいだもん。macの環境ではシェルが必須。でも標準のシェルはEUCコードに対する問題がかなりあったので、[iTerm](http://iterm.sourceforge.net/)を使っている。こいつも結構macらしい使いやすいソフト。grepとかもできちゃうので便利。まだmacではPHPしかいじったことないので、他にIDEとかは分からないかな。

SVNクライアントは[fink](http://fink.sourceforge.net/index.php?phpLang=ja)で手に入るんだけど、macにはそういうものは入れないという変なポリシーを決めていて、[単体で入れられるクライアント](http://metissian.com/projects/macosx/subversion/)を使っている。ApacheとかMySQLとかは入れてない。基本的にmacではちょっとした修正のみで、がっつりソース書きたいときはWindowsという感じで使い分けているから問題ないのかも。本当はTortoiseSVNみたいにFinderでSVN管理できるものがあればもっと便利なんだろうけど、まぁWEBで管理できるのも出てるからねぇ。

macの情報は少ないけど、もっといい方法がないかなぁとか考えてたりします。そのうちmacbookの方にはbootcampでFedraを入れることも考えてはいますが。

Technorati Tags: [coteditor](http://www.technorati.com/tag/coteditor), [fink](http://www.technorati.com/tag/fink), [iTerm](http://www.technorati.com/tag/iTerm), [mac](http://www.technorati.com/tag/mac), [macbook](http://www.technorati.com/tag/macbook), [subversion](http://www.technorati.com/tag/subversion)