---
title: MCPとAIエージェント
description: ''
date: '2025-07-12T03:01:47.628Z'
categories: []
keywords: []
slug: "20ee3eee-f3c4-446a-ab49-1c021f169893"
---
今日の内容には少し技術的な話も含まれるため、いつも読んでくれている方の中には、やや難しく感じる人もいるかもしれない。今回はAIエージェントとMCPの話をしたい。

#### ClaudeとThingsをつなげたい理由

Cultured Codeが開発しているThingsを、MCPサーバーを通じてClaudeで使えるようにしたいと考えている。

主な理由は、OmniFocusがClaudeを介して対話できる環境をすでに実現しており、その仕組みを応用すれば、Claudeを使ってOmniFocusからThingsへのデータ移行ができるのではと考えているからだ。

さらに、ThingsとClaudeを組み合わせることで、たとえば週次レビューのアシスタントをClaudeが担ってくれるかもしれない。Reviewモードが存在しないThingsにとって、これは大きな強化になると感じている。

#### 現在試しているMCPサーバー

ChatGPTのDeep Researchを使いながら、Thingsに対応するMCPサーバーをいくつか探してみた。具体的には、以下の2つである。

*   [https://github.com/excelsier/things-fastmcp](https://github.com/excelsier/things-fastmcp)
*   [https://github.com/upup666/things3-mcp-dxt-extension](https://github.com/upup666/things3-mcp-dxt-extension)

これらを試してみたが、現時点ではまともに動く気配がない。

#### ローカライズの壁

Thingsを直接操作する部分ではAppleScriptを使っているが、どうやらThingsではリスト名が完全にローカライズされており、英語版では”Today”、日本語版では”今日”を使わなければならないようだ。

端的に言うと、Thingsが日本語で起動している環境では、以下のコマンドは動く：

```
% osascript -e 'tell application "Things3" to get name of every to do of list "今日"'
```

しかし、英語のままでは動作しない：

```
% osascript -e 'tell application "Things3" to get name of every to do of list "Today"'
```

つまり、ローカライズを考慮したMCPサーバーにはなっていないようだ。

#### Claudeとの相性のよさ

このように、MCPサーバーを使う方法ではClaudeとの連携を多用している。MCPサーバーの発案者でもあることから、Claude側の対応も手厚い。しかし、Macでないと使えないという不便さもつきまとう。

#### Apple IntelligenceとChatGPTの連携強化

一方で、macOS26ではChatGPTとの連携が強化される予定だ。

macOS 26になれば、Shortcut内でApple Intelligenceの機能を使い、より便利に活用できるようになる。たとえば、雑多な文章からアクションを抽出してOmniFocusに登録するといったことも可能になる。

さらに、アプリ自体にApple Intelligenceが組み込まれれば、Shortcutを作る必要すらなくなるかもしれない。

#### 今後の選択肢

ClaudeとMCPサーバーを使って操作するのがいいのか、それともApple Intelligenceの中でChatGPTを使うほうがよいのか。今後の展開はまだ読めないでいる。

もし、どちらかに決めて本格的に使うことになれば、有料プランを検討できるのに、という気持ちで、決めかねている。