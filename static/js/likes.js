import { ref, get, set, onValue } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-database.js';

class LikeSystem {
  constructor() {
    this.database = window.firebaseDatabase;
    this.postId = this.getPostId();
    this.userKey = this.getUserKey();
    this.init();
  }

  // 投稿IDを取得（URLから生成）
  getPostId() {
    const path = window.location.pathname;
    return btoa(path).replace(/[^a-zA-Z0-9]/g, '');
  }

  // ユーザー識別キー（localStorage使用）
  getUserKey() {
    let userKey = localStorage.getItem('blog_user_key');
    if (!userKey) {
      userKey = 'user_' + Math.random().toString(36).substr(2, 9);
      localStorage.setItem('blog_user_key', userKey);
    }
    return userKey;
  }

  // 初期化
  init() {
    console.log('LikeSystem initializing...', this.postId, this.userKey);
    this.loadLikeCount();
    this.checkUserLiked();
    this.setupEventListeners();
  }

  // いいね数を読み込み
  loadLikeCount() {
    const likesRef = ref(this.database, `likes/${this.postId}/count`);
    onValue(likesRef, (snapshot) => {
      const count = snapshot.val() || 0;
      this.updateLikeDisplay(count);
    });
  }

  // ユーザーがいいね済みかチェック
  checkUserLiked() {
    const userLikeRef = ref(this.database, `likes/${this.postId}/users/${this.userKey}`);
    get(userLikeRef).then((snapshot) => {
      const liked = snapshot.val() || false;
      this.updateLikeButton(liked);
    });
  }

  // イベントリスナー設定
  setupEventListeners() {
    const likeBtn = document.getElementById('like-btn');
    if (likeBtn) {
      likeBtn.addEventListener('click', () => this.toggleLike());
    }
  }

  // いいねの切り替え
  async toggleLike() {
    console.log('toggleLike clicked!');
    const userLikeRef = ref(this.database, `likes/${this.postId}/users/${this.userKey}`);
    const countRef = ref(this.database, `likes/${this.postId}/count`);

    try {
      // 現在の状態をチェック
      const userLikeSnapshot = await get(userLikeRef);
      const countSnapshot = await get(countRef);

      const isLiked = userLikeSnapshot.val() || false;
      const currentCount = countSnapshot.val() || 0;

      console.log('Current state:', { isLiked, currentCount });

      if (isLiked) {
        // いいね解除
        await set(userLikeRef, false);
        await set(countRef, Math.max(0, currentCount - 1));
        console.log('Removed like');
      } else {
        // いいね追加
        await set(userLikeRef, true);
        await set(countRef, currentCount + 1);
        console.log('Added like');
      }

      this.updateLikeButton(!isLiked);
    } catch (error) {
      console.error('いいねの更新に失敗しました:', error);
    }
  }

  // いいね数の表示を更新
  updateLikeDisplay(count) {
    const countElement = document.getElementById('like-count');
    if (countElement) {
      countElement.textContent = count;
    }
  }

  // いいねボタンの表示を更新
  updateLikeButton(isLiked) {
    const likeBtn = document.getElementById('like-btn');
    if (likeBtn) {
      if (isLiked) {
        likeBtn.classList.add('liked');
        likeBtn.innerHTML = '👏 <span id="like-count">' + (document.getElementById('like-count')?.textContent || '0') + '</span>';
      } else {
        likeBtn.classList.remove('liked');
        likeBtn.innerHTML = '👏 <span id="like-count">' + (document.getElementById('like-count')?.textContent || '0') + '</span>';
      }
    }
  }
}

// DOM読み込み後に初期化
document.addEventListener('DOMContentLoaded', () => {
  console.log('DOM loaded, checking Firebase...');
  if (window.firebaseDatabase) {
    console.log('Firebase database found, initializing LikeSystem');

    // いいねボタンがある場合のみ初期化
    if (document.getElementById('like-btn')) {
      console.log('Like button found, initializing LikeSystem');
      new LikeSystem();
    } else {
      console.log('No like button found on this page');
    }
  } else {
    console.error('Firebase database not initialized');
    console.log('Available window properties:', Object.keys(window).filter(key => key.includes('firebase')));
  }
});