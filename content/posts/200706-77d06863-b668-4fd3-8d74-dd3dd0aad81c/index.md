---
title: 修正するまで待てなかった？
description: ''
date: '2007-06-27T10:14:18.000Z'
categories: []
keywords: []
slug: "77d06863-b668-4fd3-8d74-dd3dd0aad81c"
---
昨日のニュースですが、+LhacaというLzhソフトウェア(アーカイバ)に脆弱性が報告されたというニュースがありました。

リンク: [ITmedia エンタープライズ：Lhacaに未パッチの脆弱性、悪用トロイの木馬も出現](http://www.itmedia.co.jp/enterprise/articles/0706/26/news022.html "ITmedia エンタープライズ：Lhacaに未パッチの脆弱性、悪用トロイの木馬も出現").

> 日本で人気の圧縮・解凍ソフト「Lhaca」に未パッチの脆弱性が発覚、この問題を突いた「.lzh」圧縮形式のファイルが見つかった。米Symantecが6月25日のブログで報告している。

具体的には

リンク: [Symantec Security Response Weblog: Beware of LZH](http://www.symantec.com/enterprise/security_response/weblog/2007/06/beware_of_lzh.html "Symantec Security Response Weblog: Beware of LZH").

> All  
> the ingredients required by file format exploit recipes. The difficulty  
> in this case is finding the application that could be vulnerable.  
> Cheers to Masaki Suenaga in Security Response, Japan for doing the  
> initial analysis and finding out that Lhaca version 1.20 (at least) is  
> vulnerable.

という記事によって発表されています。一応ブログということらしいですが、コメント欄すらないのでブログとは認められません。（こういうところはいかにもsymantecらしいと思えます)

その後、昨日のうちに+Lhacaは改修された[1.21版がリリースされています](http://park8.wakwak.com/~app/Lhaca/)（ただし、正式版にはまだしないようです)。

Symantecが見つけるきっかけになったのは、日本のコンシューマから送られたLzhファイルで、日本のSymantecにて解析が行われたようなのですが、解析して問題を発見した時点でブログではなく、+Lhaca作成者側にきちんと伝わったのか、改修版リリースまで待てなかったのかというのは非常に気になります。

Lzh自身は、欧米では知名度があまりないようですが、日本では有名なフォーマット（windowsパワーのおかげでcabとかzipをメインで使う人やら、Linuxのおかげでtgzをメインで使う人やらいますが）なので、おまけに+Lhacaといえば、Lzhアーカイバとして著名なソフトウェアなだけに脆弱性情報の取り扱いには注意して欲しかったところです。

当事者でも関係者でもなんでもないのでITmediaの記事以外にはいきさつを詳細には知りませんが、きちんと声を上げておくべきと思ったので書いておきます。