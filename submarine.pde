import java.util.Arrays;  // for fill

PImage image_backGround, image_player, bombPlayer, bombEnemy;
PImage[] enemy = new PImage[4];
int g_gameSequence; // ゲームの流れを管理
int g_playerX;  // プレイヤーx座標
//int g_playerY;  // プレイヤーy座標(今回は使用しない)
int g_playerWidth = 120;  //プレイヤーの幅
float[] g_enemyX = new float[12];  // 敵x座標
int[] g_enemyY = new int[12];  // 敵y座標
int[] g_enemyDirection = new int[12];  // 0:左向き 1:右向き 2.3 : 爆発 4:未使用
float[] g_enemySpeed = new float[12];  // 敵の移動速度
int[] g_enemyCount = new int[12];   // 敵の爆発カウント
int[] g_bombPlayerX = new int[6];  // プレイヤー爆弾のx座標
int[] g_bombPlayerY = new int[6];  // プレイヤー爆弾のy座標
int[] g_bombEnemyX = new int[20];  // 敵爆弾のx座標
int[] g_bombEnemyY = new int[20];  // 敵爆弾のy座標
int[] g_bombEnemyCount = new int[20]; // 水柱
int g_bombWait;  // 爆弾投下の間隔
int[] g_keyState = new int[3];  // キーの状態, 1だったら押されている0なら押されていない [0]左キーの状態 [1]右キーの状態 [2]スペースキーの状態
int g_playerSink;   // プレイヤー沈む
int g_messageCount; // メッセージ用カウンタ

void setup(){
  size(600,450); // 画面サイズ
  noStroke();
  frameRate(30); //フレームレート
  imgLoad();
  gameInit(); //ゲーム情報の初期化
}
void draw(){
  background(0,255,255);
  if( g_gameSequence == 0 ){
    gameTitle();  //タイトル表示
  } else if( g_gameSequence == 1 ){
    gamePlay();   //ゲームプレイ
  } else {
    gameOver();
  }
}
void gameInit(){
  g_gameSequence = 0;
  g_playerX = 240;
  Arrays.fill(g_enemyDirection, 4);  //0:左向き 1:右向き 2.3 : 爆発 4:未使用
  Arrays.fill(g_bombPlayerY, -20);  // -20 : 未使用
  g_bombWait = 0;
  Arrays.fill(g_keyState, 0);  // 1:押下中 0:押されていない
  Arrays.fill(g_bombEnemyY, -20); // -20 : 未使用
  g_playerSink = 0;
  g_messageCount = 0;
}
void gameTitle(){
  g_gameSequence = 1;  //(仮)何もせずゲームプレイへ
}
void gamePlay(){
  image(image_backGround, 0,90,600,360);   // 背景表示(表示座標, サイズ)
  playerMove();                            // プレイヤー移動
  image(image_player, g_playerX, 58);      // プレイヤー表示
  enemyMove();                             // 敵の移動
  enemyDisplay();                          // 敵の表示
  bombPlayerMove();                        // プレイヤー爆弾
  bombEnemyMove();                         // 敵の爆弾
}
void playerMove(){
  if( (g_keyState[0] == 1) && (g_playerX > 0) ){  // 左キー
    g_playerX -= 3;  // 左へ移動
  }
  if( (g_keyState[1] == 1) && (g_playerX < 600 - g_playerWidth) ){  // 右キー
    g_playerX += 3;  // 右へ移動
  }
  if( g_bombWait > 0 ){  // チャタリング対策
    g_bombWait--;
  }
  if( ( g_keyState[2] == 1) && (g_bombWait == 0) ){  // スペースキー押下判別式
    g_bombWait = 10;  // 次の投下までの待ちカウント
    bombPlayerAdd();  // プレイヤー爆弾投下
  }
}
void gameOver(){
  image(image_player, g_playerX, 58 + (g_playerSink/2) );  // プレイヤー表示
  image(image_backGround, 0, 90, 600, 360); // 背景表示
  enemyDisplay(); // 敵の表示
  bombEnemyMove();  // 敵の爆弾
  g_messageCount++;
  if ( g_messageCount < 100 ) {
    g_playerSink++;   // プレイヤーを沈ませる
  }
  if( g_messageCount > 60 ){
    textSize(70);
    fill(255, 0, 0);
    text("GAME OVER", 110, 240);
  }
}
void imgLoad(){
  image_backGround = loadImage("sm_bg.png");  //背景絵の読み込み
  image_player = loadImage("sm_player.png");
  enemy[0] = loadImage("sm_enemyL.png");
  enemy[1] = loadImage("sm_enemyR.png");
  enemy[2] = loadImage("sm_explosion1.png");
  enemy[3] = loadImage("sm_explosion2.png");
  bombPlayer = loadImage("sm_bombP.png");
  bombEnemy = loadImage("sm_bombE.png");
}
void enemyMove(){
  for(int i=0; i<12; i++){
    if ( g_enemyDirection[i] < 2 ) { // 生存中の敵のみ
      g_enemyX[i] += g_enemySpeed[i];  // 敵x座標に移動速度を足していくことで移動を実現
    }
    if( ( g_enemyDirection[i] == 0 ) && ( g_enemyX[i] < -80 ) ){  // 左向きの敵が画面外に出たら
      g_enemyDirection[i] = 4;  // 未使用にする
    }
    if( ( g_enemyDirection[i] == 1 ) && ( g_enemyX[i] > 600 ) ){  // 右向きの敵が画面外に出たら
      g_enemyDirection[i] = 4;  // 未使用にする
    }
  }
  if( random(1000) < 20 ){  // 敵の発生率はrandom関数内の数値で調整(高いほど出現率少ない, 低いほど多い)
    enemyAdd();
  }
}
void enemyDisplay(){  // 敵の表示
  for(int i=0; i<12; i++){
    if( g_enemyDirection[i] < 4 ){  // 敵が未使用でないかの判別
      image(enemy[g_enemyDirection[i]], g_enemyX[i], g_enemyY[i]);  // 敵の表示
    }
    if (g_enemyDirection[i] < 2) {  // 生存中の敵のみ
      for(int j=0; j<6; j++){ // 爆弾との当たり判定
        if( ( g_bombPlayerY[j] < g_enemyY[i] + 21 ) && ( g_bombPlayerY[j] + 16 > g_enemyY[i] ) && (g_bombPlayerX[j] < g_enemyX[i] + 76) && (g_bombPlayerX[j] + 10 > g_enemyX[i]) ){
          g_bombPlayerY[j] = -20;       // 爆弾を未使用にする
          g_enemyDirection[i] = 2;  // 敵を爆発にセット
          g_enemyCount[i] = 0;    // 爆発カウント
          break;
        }
      }
    }
    if ( (g_enemyDirection[i] == 2) || (g_enemyDirection[i] == 3) ) {  // 爆発中
      g_enemyCount[i]++;
      g_enemyDirection[i] = (g_enemyCount[i] / 3) % 2 + 2;  // 爆発の絵を交互にする(3=切替フレームレート, %2=絵の枚数, +2=配列の添字に合わせるため)
      if ( g_enemyCount[i] > 60 ) {   // 爆発のアニメ終了
        g_enemyDirection[i] = 4;  // // 0:左向き 1:右向き 2.3 : 爆発 4:未使用
      }
    }
    if ( (g_enemyDirection[i] < 2) && (random(1000) < 10) ) {  // 爆弾発生率
      bombEnemyAdd(int(g_enemyX[i]), g_enemyY[i]);  // 爆弾発射
    }
  }
}
void enemyAdd(){
  for(int i=0; i<12; i++){
    // 未使用の中から敵を追加する
    if( g_enemyDirection[i] == 4 ){   // 0:左向き 1:右向き 2.3 : 爆発 4:未使用
      g_enemySpeed[i] = random(0.5, 2.5);  // 0.5~2.5の間で速度設定されている
      if( random(100) < 50 ){  // 50%の確率で左向きの敵、右向きの敵分配
        g_enemyDirection[i] = 0;  // 左向きの敵
        g_enemyX[i] = 600;  // 出発地点
        g_enemySpeed[i] = -g_enemySpeed[i];  // 左へ移動
      } else {
        g_enemyDirection[i] = 1;  // 右向きの敵
        g_enemyX[i] = -80;  // 出発地点
      }
      g_enemyY[i] = int(random(120, 420));  // Y座標120~420で敵を出現させる
      break;  // ここで抜けないと、一回のenemyAdd()呼び出しで全ての未使用の敵が使用されてしまう
    }
  }
}
void bombPlayerAdd(){
  for(int i=0; i<6; i++){
    if( g_bombPlayerY[i] == -20 ){  // 未使用の爆弾を使う
      g_bombPlayerX[i] = g_playerX +  (g_playerWidth / 2);  // プレイヤーの中心座標
      g_bombPlayerY[i] = 90;
      break;  // 一発だけ発射
    }
  }
}
void bombPlayerMove(){
  int bombCount = 6;
  for( int i=0; i<6; i++ ){
    if( g_bombPlayerY[i] > 0 ){   // 投下中なので移動
      g_bombPlayerY[i] += 2;      // 投下スピード
      bombCount--;
    }
    if( g_bombPlayerY[i] > 450 ){ // 画面の外へ出た
      g_bombPlayerY[i] = -20;     // 未使用に変更
    }
    image(bombPlayer, g_bombPlayerX[i], g_bombPlayerY[i]);
  }
  for(int i=0; i<bombCount; i++){
    image(bombPlayer, 230+i*26,20);
  }
}
void keyPressed(){  // キーが押されるたびに呼ばれる
  if( key == CODED ){  // CODED = keyが文字で表せないものだったときの処置をするためのフラグ
    if( keyCode == LEFT ) g_keyState[0] = 1;
    if( keyCode == RIGHT ) g_keyState[1] = 1;
  }
  if( key == ' ' ) g_keyState[2] = 1;
}
void keyReleased(){  // キーを離された時に呼ばれる
  if( key == CODED ){  // キーを離した時に直前までキーを押していたかを判別
    if( keyCode == LEFT ) g_keyState[0] = 0;  // 直前まで押していたキーが左ならg_keyState[0]の値を0にする。以下同様。
    if( keyCode == RIGHT ) g_keyState[1] = 0;
  }
  if( key == ' ' ) g_keyState[2] = 0;
}
void bombEnemyAdd(int xx, int yy) {
  for(int i=0; i < 20; i++){
    if ( g_bombEnemyY[i] == -20 ) { // 未使用のものを使う
      g_bombEnemyX[i] = xx + 38;  // 敵船の幅を足す
      g_bombEnemyY[i] = yy;
      println("bomb go");
      break;
    }
  }
}
void bombEnemyMove(){ // 敵爆弾の表示と移動
  for (int i = 0; i < 20; i++) {
    if( g_bombEnemyY[i] > 60 ){ // 発射中なので移動
      g_bombEnemyY[i] -= 1; // 敵の爆弾を上に移動
      if( g_bombEnemyY[i] < 90 ){  // 海面まで来た
        g_bombEnemyY[i] = 60;   // 水柱の表示位置
        g_bombEnemyCount[i] = 10; // 表示時間
      }
    }
    if( g_bombEnemyY[i] == 60 ){  // 60ってなに？？？★
      fill(255, 80, 10);  // シェイプを塗りつぶす色を設定
      rect(g_bombEnemyX[i], g_bombEnemyY[i], 16, 30); // 視覚表示(水柱)
      g_bombEnemyCount[i]--;
      if ( g_bombEnemyCount[i] == 0 ) { // 敵の爆弾カウントが0になったら...
        g_bombEnemyY[i] = -20;  // 未使用に戻す
      }
      // プレイヤーとの当たり判定
      if( (g_bombEnemyX[i] < g_playerX + g_playerWidth) && (g_bombEnemyX[i]+16 > g_playerX)){
        g_gameSequence = 2; // ゲームオーバーへ
      }
    } else { // 敵の爆弾カウントが0でない場合...
      image(bombEnemy, g_bombEnemyX[i], g_bombEnemyY[i]); // 爆弾表示
    }
  }
}