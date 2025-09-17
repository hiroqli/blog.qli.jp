---
title: macの開発環境
description: ""
date: "2006-07-23T23:33:44.000Z"
categories: []
keywords: []
slug: "200607-60ccbb23-d802-4f83-a3ec-c5fb1154a525"
---

久々に ecto から書き込み。

Windows の開発環境は書いたので、mac での開発環境を書いておく。

Mac のエディタはなんといっても[CotEditor](http://www.aynimac.com/p_blog/files/index2.php)。これ、かなり使いやすくておすすめ。こいつを Windows 版に書き直したものがあればそれを使いたいくらいだもん。mac の環境ではシェルが必須。でも標準のシェルは EUC コードに対する問題がかなりあったので、[iTerm](http://iterm.sourceforge.net/)を使っている。こいつも結構 mac らしい使いやすいソフト。grep とかもできちゃうので便利。まだ mac では PHP しかいじったことないので、他に IDE とかは分からないかな。

SVN クライアントは[fink](http://fink.sourceforge.net/index.php?phpLang=ja)で手に入るんだけど、mac にはそういうものは入れないという変なポリシーを決めていて、[単体で入れられるクライアント](http://metissian.com/projects/macosx/subversion/)を使っている。Apache とか MySQL とかは入れてない。基本的に mac ではちょっとした修正のみで、がっつりソース書きたいときは Windows という感じで使い分けているから問題ないのかも。本当は TortoiseSVN みたいに Finder で SVN 管理できるものがあればもっと便利なんだろうけど、まぁ WEB で管理できるのも出てるからねぇ。

mac の情報は少ないけど、もっといい方法がないかなぁとか考えてたりします。そのうち macbook の方には bootcamp で Fedra を入れることも考えてはいますが。
