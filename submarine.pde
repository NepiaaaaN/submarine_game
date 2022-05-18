import java.util.Arrays;  // for fill

PImage image_backGround, image_player, bombPlayer;
PImage[] enemy = new PImage[2];
int g_gameSequence; // ゲームの流れを管理
int g_playerX;  // プレイヤーx座標
//int g_playerY;  // プレイヤーy座標(今回は使用しない)
int g_playerWidth = 120;  //プレイヤーの幅
float[] g_enemyX = new float[12];  // 敵x座標
int[] g_enemyY = new int[12];  // 敵y座標
int[] g_enemyDirection = new int[12];  // 0:左向き 1:右向き 2:未使用
float[] g_enemySpeed = new float[12];  // 敵の移動速度
int[] g_bombPlayerX = new int[6];  // プレイヤー爆弾のx座標
int[] g_bombPlayerY = new int[6];  // プレイヤー爆弾のy座標
int g_bombWait;  // 爆弾投下の間隔
int[] g_keyState = new int[3];  // キーの状態, 1だったら押されている0なら押されていない [0]左キーの状態 [1]右キーの状態 [2]スペースキーの状態

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
  Arrays.fill(g_enemyDirection, 2);  //0:左向き 1:右向き 2:未使用
  Arrays.fill(g_bombPlayerY, -20);  // -20 : 未使用
  g_bombWait = 0;
  Arrays.fill(g_keyState, 0);  // 1:押下中 0:押されていない
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
}
void imgLoad(){
  image_backGround = loadImage("sm_bg.png");  //背景絵の読み込み
  image_player = loadImage("sm_player.png");
  enemy[0] = loadImage("sm_enemyL.png");
  enemy[1] = loadImage("sm_enemyR.png");
  bombPlayer = loadImage("sm_bombP.png");
}
void enemyMove(){
  for(int i=0; i<12; i++){
    g_enemyX[i] += g_enemySpeed[i];  // 敵x座標に移動速度を足していくことで移動を実現
    if( ( g_enemyDirection[i] == 0 ) && ( g_enemyX[i] < -80 ) ){  // 左向きの敵が画面外に出たら
      g_enemyDirection[i] = 2;  // 未使用にする
    }
    if( ( g_enemyDirection[i] == 1 ) && ( g_enemyX[i] > 600 ) ){  // 右向きの敵が画面外に出たら
      g_enemyDirection[i] = 2;  // 未使用にする
    }
    if( random(1000) < 20 ){  // 敵の発生率はrandom関数内の数値で調整(高いほど出現率少ない, 低いほど多い)
      enemyAdd();
    }
  }
}
void enemyDisplay(){
  for(int i=0; i<12; i++){
    if( g_enemyDirection[i] < 2 ){
      image(enemy[g_enemyDirection[i]], g_enemyX[i], g_enemyY[i]);
    }
  }
}
void enemyAdd(){
  for(int i=0; i<12; i++){
    // 未使用の中から敵を追加する
    if( g_enemyDirection[i] == 2 ){
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
