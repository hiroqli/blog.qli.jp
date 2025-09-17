---
title: OmniFocusのアーカイブをひとつにまとめる方法
description: OmniFocusには「アーカイブ」というものがあります。OmniFocusのライブラリはOmniSyncを通じて他のデバイスに「同期」されていますが、ライブラリの肥大化を防ぎ、同期を軽くするために、古い項目をライブラリから「アーカイブ」に移動させます。
date: '2020-10-23T13:07:08.416Z'
categories: []
keywords: []
slug: "202010-4dd99d81-a28b-446e-9d5a-7cce3b68506a"
---
OmniFocusには「アーカイブ」というものがあります。OmniFocusのライブラリはOmniSyncを通じて他のデバイスに「同期」されていますが、ライブラリの肥大化を防ぎ、同期を軽くするために、古い項目をライブラリから「アーカイブ」に移動させます。

「アーカイブ」はデバイス間で共有することはなく、マシンの中に保存されます。アーカイブ機能を持っているのはOmniFocusでもMac版飲みなので、基本は “母艦” と言われるMacに保存されることが多く、アーカイブ作業自体は必ず1台のマシンで行うことが注意されています。

例えば、Macの乗り換え中などに操作を誤り、これまでとは別のMacでアーカイブを実行してしまい、アーカイブファイルが複数できてしまうことがあります。

アーカイブファイルは過去の履歴であり、参照することは多くありませんが、たまに見返すときにアーカイブファイルが複数あると操作が複雑になってしまいます。というわけで、アーカイブファイルをひとつにまとめる必要性が出てきます。

アーカイブをひとつにまとめる方法、実は公式にアナウンスされているものではなく、OmniFocusのユーザー掲示板に2015年に書かれたものしかありません。

これをわかりやすく説明した記事があってもいいのではないかと思ったので、紹介することにしました。（前書きが長い）

[**Manually merging two archives? \[Yes, see thread\]**  
_At some point I ended up archiving in two copies of OF 1 on two different machines. I didn't realize it until I…_discourse.omnigroup.com](https://discourse.omnigroup.com/t/manually-merging-two-archives-yes-see-thread/4850/5 "https://discourse.omnigroup.com/t/manually-merging-two-archives-yes-see-thread/4850/5")[](https://discourse.omnigroup.com/t/manually-merging-two-archives-yes-see-thread/4850/5)

マージのレシピは上記リンク先に書いてある通りです。簡単な仕組みを紹介すると、次の通りです。

1.  アーカイブファイルから「バックアップファイル」を作成
2.  OmniFocusのバックアップから戻す処理を利用して、OmniFocusにデータを読み込む
3.  OmniFocus上で「アーカイブ」作業をする

バックアップから戻すと全部のデータが戻ってしまいます。つまり、最後の作業前の状態に戻す必要があるのでバックアップをとっておくことが必要だということと、裏で同期が走っているとややこしいことになるので、同期を切っておきましょう。

現在は、データファイルが200KB程度に対して、アーカイブファイルが4MB程度あります。ほとんどテキストファイルとはいえ、数年の蓄積が重なるものですね。将来的にはアーカイブファイルもOmniSyncに入れて欲しいものです。