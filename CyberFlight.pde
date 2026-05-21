import processing.sound.*; // BIBLIOTECA DE SOM ADICIONADA

// ===== IMAGENS =====
PImage imgPlayer, imgPlayerUp, imgDown, imgRight, imgLeft, imgPlayerBroken;
PImage imgVidaNormal, imgBackground, imgBarricada;
PImage imgSnakeHead, imgSnakeBody, imgSpaceShooter, imgSpaceLaser;
PImage imgMinaMagnetica, imgMothershipBoss, imgPowerUpEspecial, imgPowerUpVida, imgPowerUpTiro;
PImage imgKamikaze; 
PImage imgLaserPlayer, imgLaserInimigo, imgMenuBG, imgBossDefeated;
PImage spriteAtual; 

// ===== ÁUDIOS =====
SoundFile somMusicaFundo, somLaserPlayer, somDanoNave, somLaserInimigo;
SoundFile somExplosao, somExplosaoBoss, somPowerUp, somEMP, somAlarmeBoss;

// ===== ESTADOS DO JOGO =====
final int ESTADO_LOGIN = 0;
final int ESTADO_LEADERBOARD = 1;
final int ESTADO_CONTAGEM = 2;
final int ESTADO_JOGANDO = 3;
final int ESTADO_BOSS = 4;
final int ESTADO_ANIMACAO_VITORIA = 5;
final int ESTADO_VITORIA = 6;
final int ESTADO_GAMEOVER = 7;
final int ESTADO_PAUSE = 8; // NOVO ESTADO DE PAUSE
int estadoJogo = ESTADO_LOGIN;
int estadoAnterior = ESTADO_JOGANDO; // Guarda de onde o pause veio
PImage telaPausada; // Guarda o print da tela para o menu de pause

// ===== SISTEMA DE JUICE (EFEITOS VISUAIS) =====
int shakeTimer = 0;
ArrayList<Particula> particulas = new ArrayList<Particula>();

// Controle do Fundo Infinito
float bgY1, bgY2;
int larguraNave = 100, alturaNave = 100;
float x, y, vx, vy; 
float aceleracao = 1.8, atrito = 0.85; 
boolean up, down, left, right;
float limiteEsq, limiteDir;

// ===== SISTEMA DE PROGRESSÃO E HIGHSCORE =====
int framesContagem = 0, framesJogados = 0;
float dificuldade = 1.0;
int pontuacao = 0, highscore = 0; 
int vidas = 5, invencivelFrames = 0; 
float bossHPMax = 500, bossHP = bossHPMax;

// ===== SISTEMA DE SPAWN CENTRALIZADO =====
int proximoSpawnFrame = 0; 
boolean navesDesbloqueadas = false, serpentesDesbloqueadas = false, navesLaserDesbloqueadas = false;
boolean minasDesbloqueadas = false, kamikazesDesbloqueados = false;
boolean forcarNave = false, forcarSerpente = false, forcarNaveLaser = false, forcarMina = false, forcarKamikaze = false;

// ===== SISTEMA DE ESPECIAL E POWER-UPS =====
int cargasEMP = 1, maxCargasEMP = 3;
OndaEMP especialOnda;
int timerPowerUpTiro = 0; 
boolean temTiroDuplo = false;

// ===== LISTAS DE OBJETOS NA TELA =====
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<LaserInimigo> lasersInimigos = new ArrayList<LaserInimigo>();
ArrayList<Obstaculo> obstaculos = new ArrayList<Obstaculo>(); 
ArrayList<MinaMagnetica> minas = new ArrayList<MinaMagnetica>();
ArrayList<InimigoAtirador> inimigos = new ArrayList<InimigoAtirador>();
ArrayList<SegmentoSerpente> serpentes = new ArrayList<SegmentoSerpente>(); 
ArrayList<InimigoLaserContinuo> navesLaser = new ArrayList<InimigoLaserContinuo>();
ArrayList<InimigoKamikaze> kamikazes = new ArrayList<InimigoKamikaze>();
ArrayList<PowerUp> powerups = new ArrayList<PowerUp>(); 
MothershipBoss oBoss; 

boolean atirando = false;
int intervaloTiro = 12, ultimoDisparoFrame = 0;  

void setup() {
  fullScreen(P2D); 
  frameRate(60);
  limiteEsq = width * 0.22; limiteDir = width * 0.78;
  carregarHighscore(); 
  
  imgPlayer = loadImage("nave.png"); imgPlayerUp = loadImage("naveUp.png");
  imgDown = loadImage("naveDown.png"); imgRight = loadImage("naveRight.png");
  imgLeft = loadImage("naveLeft.png"); imgPlayerBroken = loadImage("nave-Broken.png"); 
  imgBackground = loadImage("Background.png"); imgBarricada = loadImage("Barricade.png");
  imgSnakeHead = loadImage("SnakeHead.png"); imgSnakeBody = loadImage("SnakeBody.png");
  imgSpaceShooter = loadImage("SpaceShooter.png"); imgSpaceLaser = loadImage("SpaceLaser.png"); 
  imgMinaMagnetica = loadImage("Bomb.png"); imgPowerUpEspecial = loadImage("Special.png");
  imgPowerUpVida = loadImage("Vida.png"); imgPowerUpTiro = loadImage("Upgrade.png");
  imgMothershipBoss = loadImage("Boss.png"); imgKamikaze = loadImage("Kamikaze.png");
  imgLaserPlayer = loadImage("LaserPlayer.png"); imgLaserInimigo = loadImage("LaserInimigo.png");
  imgMenuBG = loadImage("MenuBG.png"); imgBossDefeated = loadImage("BossDefeated.png");
  
  imgPlayer.resize(larguraNave, alturaNave); imgPlayerUp.resize(larguraNave, alturaNave);
  imgDown.resize(larguraNave, alturaNave); imgRight.resize(larguraNave, alturaNave);
  imgLeft.resize(larguraNave, alturaNave); imgPlayerBroken.resize(larguraNave, alturaNave);
  imgBackground.resize(width, 0); 
  if(imgMenuBG != null) imgMenuBG.resize(width, height);
  bgY1 = 0; bgY2 = -imgBackground.height; 
  
  imgVidaNormal = imgPlayer.get(); imgVidaNormal.resize(45, 45);
  spriteAtual = imgPlayer;
  resetPosicaoNave();
  
  try { somMusicaFundo = new SoundFile(this, "MusicaFundo.wav"); somMusicaFundo.amp(0.6); somMusicaFundo.loop(); } catch(Exception e) {}
  try { somLaserPlayer = new SoundFile(this, "LaserPlayer.wav"); somLaserPlayer.amp(0.1); } catch(Exception e) {}
  try { somDanoNave = new SoundFile(this, "DanoNave.wav"); } catch(Exception e) {}
  try { somLaserInimigo = new SoundFile(this, "LaserInimigo.wav"); somLaserInimigo.amp(0.1); } catch(Exception e) {}
  try { somExplosao = new SoundFile(this, "Explosao.wav"); somExplosao.amp(0.3); } catch(Exception e) {}
  try { somExplosaoBoss = new SoundFile(this, "ExplosaoBoss.wav"); } catch(Exception e) {}
  try { somPowerUp = new SoundFile(this, "PowerUp.wav"); } catch(Exception e) {}
  try { somEMP = new SoundFile(this, "SomEMP.wav"); } catch(Exception e) {}
  try { somAlarmeBoss = new SoundFile(this, "AlarmeBoss.wav"); } catch(Exception e) {}
}

void resetPosicaoNave() { x = width / 2 - (larguraNave / 2); y = height - alturaNave - 20; vx = 0; vy = 0; }
void carregarHighscore() { String[] linhas = loadStrings("highscore.txt"); if (linhas != null && linhas.length > 0) { highscore = int(linhas[0]); } }
void salvarHighscore() { if (pontuacao > highscore) { highscore = pontuacao; String[] lista = { str(highscore) }; saveStrings("data/highscore.txt", lista); } }

// ===== CONTROLE DO SCREEN SHAKE =====
void aplicarShake() {
  if (shakeTimer > 0) {
    translate(random(-10, 10), random(-10, 10));
    shakeTimer--;
  }
}

void draw() {
  if (estadoJogo == ESTADO_LOGIN || estadoJogo == ESTADO_LEADERBOARD) {
    if (imgMenuBG != null) image(imgMenuBG, 0, 0); else { fill(10, 15, 30); rect(0, 0, width, height); }
  } else if (estadoJogo != ESTADO_PAUSE) { // Fundo congela no pause
    float velocidadeFundo = (estadoJogo == ESTADO_ANIMACAO_VITORIA) ? 6 : 2 * (dificuldade * 0.8);
    bgY1 += velocidadeFundo; bgY2 += velocidadeFundo;
    if (bgY1 >= height) bgY1 = bgY2 - imgBackground.height;
    if (bgY2 >= height) bgY2 = bgY1 - imgBackground.height;
    image(imgBackground, 0, bgY1); image(imgBackground, 0, bgY2);
  }

  switch (estadoJogo) {
    case ESTADO_LOGIN: exibirTelaLogin(); break;
    case ESTADO_LEADERBOARD: exibirTelaLeaderboard(); break;
    case ESTADO_CONTAGEM: executarContagem(); break;
    case ESTADO_JOGANDO: executarLoopJogo(); break;
    case ESTADO_BOSS: executarBatalhaBoss(); break;
    case ESTADO_ANIMACAO_VITORIA: executarAnimacaoVitoria(); break;
    case ESTADO_VITORIA: exibirTelaVitoria(); break;
    case ESTADO_GAMEOVER: exibirTelaGameOver(); break;
    case ESTADO_PAUSE: exibirTelaPause(); break;
  }
}

// ===== NOVO FLUXO: PAUSE =====
void exibirTelaPause() {
  if (telaPausada != null) image(telaPausada, 0, 0); // Desenha a screenshot do jogo
  fill(0, 180); rect(0, 0, width, height); // Escurece a tela
  fill(0, 255, 255); textAlign(CENTER, CENTER); textSize(90); 
  text("PAUSADO", width/2, height/2 - 150);
  desenharBotaoMenu("RETOMAR", width/2, height/2);
  desenharBotaoMenu("DESISTIR", width/2, height/2 + 100);
}

void exibirTelaLogin() {
  fill(0, 180); rect(0, 0, width, height);
  fill(0, 255, 255); textAlign(CENTER, CENTER); textSize(90); text("CYBERFLIGHT: DATA RUNNER", width/2, height/2 - 150);
  desenharBotaoMenu("JOGAR", width/2, height/2);
  desenharBotaoMenu("LEADERBOARD", width/2, height/2 + 100);
  desenharBotaoMenu("SAIR", width/2, height/2 + 200);
}

void exibirTelaLeaderboard() {
  fill(0, 180); rect(0, 0, width, height);
  fill(0, 255, 255); textAlign(CENTER, CENTER); textSize(80); text("HALL OF FAME", width/2, height/2 - 150);
  fill(255, 255, 0); textSize(60); text("MAIOR PONTUAÇÃO: " + nf(highscore, 7), width/2, height/2);
  desenharBotaoMenu("VOLTAR", width/2, height/2 + 150);
}

void desenharBotaoMenu(String texto, float bX, float bY) {
  float bW = 350; float bH = 70;
  boolean hover = mouseX > bX - bW/2 && mouseX < bX + bW/2 && mouseY > bY - bH/2 && mouseY < bY + bH/2;
  if (hover) { fill(0, 255, 255, 100); stroke(255); } else { fill(0, 100, 100, 150); stroke(0, 255, 255); }
  strokeWeight(3); rect(bX - bW/2, bY - bH/2, bW, bH, 10);
  fill(255); textSize(35); textAlign(CENTER, CENTER); text(texto, bX, bY - 5);
}

void mousePressed() {
  if (estadoJogo == ESTADO_LOGIN) {
    if (checarCliqueBotao(width/2, height/2)) { estadoJogo = ESTADO_CONTAGEM; framesContagem = 0; }
    if (checarCliqueBotao(width/2, height/2 + 100)) { estadoJogo = ESTADO_LEADERBOARD; }
    if (checarCliqueBotao(width/2, height/2 + 200)) { exit(); }
  } else if (estadoJogo == ESTADO_LEADERBOARD) {
    if (checarCliqueBotao(width/2, height/2 + 150)) { estadoJogo = ESTADO_LOGIN; }
  } else if (estadoJogo == ESTADO_PAUSE) { // BOTÕES DO PAUSE
    if (checarCliqueBotao(width/2, height/2)) { estadoJogo = estadoAnterior; }
    if (checarCliqueBotao(width/2, height/2 + 100)) { estadoJogo = ESTADO_LOGIN; reiniciarObjetos(); }
  }
}

boolean checarCliqueBotao(float bX, float bY) { 
  float bW = 350; 
  float bH = 70;
  return mouseX > bX - bW/2 && mouseX < bX + bW/2 && mouseY > bY - bH/2 && mouseY < bY + bH/2; 
}

void executarContagem() {
  framesContagem++; int segundosRestantes = 3 - (framesContagem / 60);
  fill(0, 255, 255, 150); textAlign(CENTER, CENTER); textSize(120);
  if (segundosRestantes > 0) { text(segundosRestantes, width/2, height/2); } 
  else { text("HACKING START!", width/2, height/2); if (framesContagem > 240) { estadoJogo = ESTADO_JOGANDO; proximoSpawnFrame = frameCount + 60; } }
}

void executarLoopJogo() {
  framesJogados++; dificuldade = 1.0 + (pontuacao / 20000.0);
  
  if (pontuacao >= 1000 && !minasDesbloqueadas) { minasDesbloqueadas = true; forcarMina = true; }
  if (pontuacao >= 4000 && !navesDesbloqueadas) { navesDesbloqueadas = true; forcarNave = true; }
  if (pontuacao >= 8000 && !kamikazesDesbloqueados) { kamikazesDesbloqueados = true; forcarKamikaze = true; }
  if (pontuacao >= 32000 && !serpentesDesbloqueadas) { serpentesDesbloqueadas = true; forcarSerpente = true; }
  if (pontuacao >= 16000 && !navesLaserDesbloqueadas) { navesLaserDesbloqueadas = true; forcarNaveLaser = true; }
  if (pontuacao >= 100000) { estadoJogo = ESTADO_BOSS; oBoss = new MothershipBoss(); if (somAlarmeBoss != null) somAlarmeBoss.play(); return; }

  gerenciarMovimentoJogador(); gerenciarTirosJogador(); gerenciarSpawn();
  
  pushMatrix(); // O SHAKE SÓ AFETA OS OBJETOS DO JOGO, NÃO A HUD
  aplicarShake();
  atualizarObjetos();
  desenharParticulas(); 
  popMatrix();
  
  desenharHUD();
}

void executarBatalhaBoss() {
  gerenciarMovimentoJogador(); gerenciarTirosJogador();
  
  pushMatrix();
  aplicarShake();
  oBoss.atualizar(); oBoss.desenhar();
  atualizarObjetos(); 
  desenharParticulas();
  popMatrix();
  
  desenharHUD();
  
  if (oBoss.y < 80 && frameCount % 60 < 30) {
    fill(255, 0, 0, 80); rect(0, 0, width, height); fill(255, 0, 0); textSize(70); textAlign(CENTER, CENTER);
    text("WARNING: MAINFRAME INBOUND", width/2, height/2);
  }
}

// ... [MANTER executarAnimacaoVitoria, desenharHUD, exibirTelaGameOver, exibirTelaVitoria] ...
void executarAnimacaoVitoria() {
  oBoss.y += 4; 
  pushMatrix(); translate(oBoss.x + oBoss.largura/2, oBoss.y + oBoss.altura/2);
  if(imgBossDefeated != null) { image(imgBossDefeated, -oBoss.largura/2, -oBoss.altura/2, oBoss.largura, oBoss.altura); } 
  else { image(imgPlayerBroken, -oBoss.largura/2, -oBoss.altura/2, oBoss.largura, oBoss.altura); }
  popMatrix();
  if (oBoss.y > height) { x = lerp(x, (width/2) - (larguraNave/2), 0.05); y -= 8; image(imgPlayerUp, x, y); } else { image(imgPlayer, x, y); }
  if (y < -150) { salvarHighscore(); estadoJogo = ESTADO_VITORIA; }
}

void desenharHUD() {
  strokeWeight(2); stroke(0, 255, 255, 150); fill(0, 100); rect(20, 20, 320, 130, 8);
  fill(0, 255, 255); textSize(18); textAlign(LEFT, TOP); text("SYSTEM STATUS", 30, 25);
  for (int i = 0; i < 5; i++) { if (i < vidas) { tint(255); } else { tint(50, 150); } image(imgVidaNormal, 30 + (i * 50), 50); noTint(); }
  for (int i = 0; i < maxCargasEMP; i++) { if (i < cargasEMP) { tint(255); } else { tint(50, 150); } image(imgPowerUpEspecial, 30 + (i * 50), 100, 35, 35); noTint(); }
  fill(255); textSize(40); textAlign(RIGHT, TOP); text("SCORE: " + nf(pontuacao, 7), width - 30, 30);
  if (temTiroDuplo) {
    fill(0, 255, 255); textSize(24); textAlign(RIGHT, TOP); text("OVERCLOCK: " + nf(timerPowerUpTiro/60.0, 1, 1) + "s", width - 30, 80);
    fill(0, 100, 100); rect(width - 230, 110, 200, 10); fill(0, 255, 255); rect(width - 230, 110, map(timerPowerUpTiro, 0, 900, 0, 200), 10);
  }
  if (estadoJogo == ESTADO_BOSS) {
    fill(255, 0, 0, 100); rect(width/2 - 300, 20, 600, 25); fill(255, 0, 0); rect(width/2 - 300, 20, map(bossHP, 0, bossHPMax, 0, 600), 25);
    fill(255); textSize(20); textAlign(CENTER, CENTER); text("MAINFRAME CORE", width/2, 32);
  }
}

void exibirTelaGameOver() {
  fill(0, 15); rect(0, 0, width, height); fill(255, 50, 50); textAlign(CENTER, CENTER);
  textSize(80); text("SYSTEM FAILURE", width/2, height/2 - 50);
  fill(255); textSize(40); text("SCORE FINAL: " + nf(pontuacao, 7), width/2, height/2 + 20);
  fill(200); textSize(24); text("Pressione 'R' para reiniciar ou 'M' para Menu", width/2, height/2 + 80);
}

void exibirTelaVitoria() {
  fill(0, 150); rect(0, 0, width, height); fill(0, 255, 0); textAlign(CENTER, CENTER);
  textSize(80); text("HACKING CONCLUÍDO", width/2, height/2 - 50);
  fill(255); textSize(40); text("DADOS TRANSMITIDOS COM SUCESSO!", width/2, height/2 + 20);
  fill(0, 255, 255); textSize(30); text("Pressione ENTER para voltar ao Menu", width/2, height/2 + 80);
}

void gerenciarMovimentoJogador() {
  if (up) vy -= aceleracao; if (down) vy += aceleracao; if (left) vx -= aceleracao; if (right) vx += aceleracao;
  vx *= atrito; vy *= atrito; x += vx; y += vy;
  x = constrain(x, limiteEsq, limiteDir - larguraNave); y = constrain(y, 0, height - alturaNave);
  if (invencivelFrames > 0) { invencivelFrames--; spriteAtual = (invencivelFrames % 8 < 4) ? imgPlayerBroken : imgPlayer;
  } else { if (up) spriteAtual = imgPlayerUp; else if (down) spriteAtual = imgDown; else if (left) spriteAtual = imgLeft; else if (right) spriteAtual = imgRight; else spriteAtual = imgPlayer; }
  image(spriteAtual, x, y);
}

void gerenciarTirosJogador() {
  if (timerPowerUpTiro > 0) { timerPowerUpTiro--; temTiroDuplo = true; } else { temTiroDuplo = false; }
  if (atirando && (frameCount - ultimoDisparoFrame >= intervaloTiro)) {
    if (somLaserPlayer != null) somLaserPlayer.play(); 
    if (temTiroDuplo) { lasers.add(new Laser(x + larguraNave/2 - 25, y)); lasers.add(new Laser(x + larguraNave/2 + 15, y)); 
    } else { lasers.add(new Laser(x + larguraNave/2 - 3, y)); }
    ultimoDisparoFrame = frameCount; 
  }
}

void gerenciarSpawn() {
  if (frameCount >= proximoSpawnFrame) {
    if (forcarMina) { spawnMina(); forcarMina = false; } else if (forcarKamikaze) { spawnKamikaze(); forcarKamikaze = false; }
    else if (forcarSerpente) { spawnSerpente(); forcarSerpente = false; } else if (forcarNaveLaser) { spawnNaveLaser(); forcarNaveLaser = false; }
    else if (forcarNave) { spawnNaveAtiradora(); forcarNave = false; } 
    else {
      float sorteio = random(100);
      if (navesLaserDesbloqueadas) { if (sorteio < 25) spawnBarricada(); else if (sorteio < 45) spawnMina(); else if (sorteio < 60) spawnKamikaze(); else if (sorteio < 75) spawnNaveAtiradora(); else if (sorteio < 85) spawnSerpente(); else spawnNaveLaser(); }
      else if (serpentesDesbloqueadas) { if (sorteio < 30) spawnBarricada(); else if (sorteio < 50) spawnMina(); else if (sorteio < 70) spawnKamikaze(); else if (sorteio < 85) spawnNaveAtiradora(); else spawnSerpente(); }
      else if (kamikazesDesbloqueados) { if (sorteio < 40) spawnBarricada(); else if (sorteio < 60) spawnMina(); else if (sorteio < 80) spawnNaveAtiradora(); else spawnKamikaze(); }
      else if (navesDesbloqueadas) { if (sorteio < 40) spawnBarricada(); else if (sorteio < 70) spawnMina(); else spawnNaveAtiradora(); }
      else if (minasDesbloqueadas) { if (sorteio < 60) spawnBarricada(); else spawnMina(); } else { spawnBarricada(); }
    }
    proximoSpawnFrame = frameCount + (int)(random(60, 180) / dificuldade);
  }
}

void spawnBarricada() { obstaculos.add(new Obstaculo(random(limiteEsq + 20, limiteDir - 180), -100)); }
void spawnMina() { minas.add(new MinaMagnetica(random(limiteEsq + 50, limiteDir - 130), -100)); }
void spawnNaveAtiradora() { inimigos.add(new InimigoAtirador(random(limiteEsq + 50, limiteDir - 130), -100)); }
void spawnKamikaze() { kamikazes.add(new InimigoKamikaze(random(limiteEsq + 50, limiteDir - 100), -100)); }
void spawnSerpente() { float startX = width / 2; for (int i = 0; i < 15; i++) serpentes.add(new SegmentoSerpente(startX, -100 - (i * 25), i * 0.2, (i == 0))); }
void spawnNaveLaser() { navesLaser.add(new InimigoLaserContinuo(-150, (int)random(2))); }
void spawnPowerUpChance(float x, float y) { if (random(100) < 15) { powerups.add(new PowerUp(x, y)); } }

void atualizarObjetos() {
  for (int i = lasers.size() - 1; i >= 0; i--) {
    Laser l = lasers.get(i); l.atualizar(); l.desenhar(); boolean laserRemovido = false;
    for (int j = obstaculos.size() - 1; j >= 0; j--) { Obstaculo obs = obstaculos.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, obs.x, obs.y, obs.largura, obs.altura)) {
        lasers.remove(i); laserRemovido = true; obs.hp--; obs.hitTimer = 3; 
        if (obs.hp <= 0) { obstaculos.remove(j); pontuacao += 100; spawnPowerUpChance(obs.x, obs.y); if (somExplosao != null) somExplosao.play(); criarParticulas(obs.x + obs.largura/2, obs.y + obs.altura/2, 15, color(150)); } break;
      }
    } if (laserRemovido) continue;
    
    for (int j = minas.size() - 1; j >= 0; j--) { MinaMagnetica m = minas.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, m.x, m.y, m.tamanho, m.tamanho)) { 
        lasers.remove(i); laserRemovido = true; pontuacao += 150; 
        if (somExplosao != null) somExplosao.play(); 
        m.dispararEstrela(); 
        minas.remove(j); // AQUI: Remove a mina fisicamente da lista para não virar parede!
        break; 
      }
    } if (laserRemovido) continue;
    
    for (int j = inimigos.size() - 1; j >= 0; j--) { InimigoAtirador in = inimigos.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, in.x, in.y, in.tamanho, in.tamanho)) {
        lasers.remove(i); laserRemovido = true; in.hp--; in.hitTimer = 3; 
        if (in.hp <= 0) { inimigos.remove(j); pontuacao += 200; spawnPowerUpChance(in.x, in.y); if (somExplosao != null) somExplosao.play(); criarParticulas(in.x + in.tamanho/2, in.y + in.tamanho/2, 15, color(100, 200, 255)); } break;
      }
    } if (laserRemovido) continue;
    
    for (int j = kamikazes.size() - 1; j >= 0; j--) { InimigoKamikaze k = kamikazes.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, k.x, k.y, k.tamanho_world_w, k.tamanho_world_h)) {
        lasers.remove(i); laserRemovido = true; kamikazes.remove(j); pontuacao += 150; spawnPowerUpChance(k.x, k.y); if (somExplosao != null) somExplosao.play(); criarParticulas(k.x + k.tamanho_world_w/2, k.y + k.tamanho_world_h/2, 20, color(255, 100, 0)); break;
      }
    } if (laserRemovido) continue;

    for (int j = navesLaser.size() - 1; j >= 0; j--) { InimigoLaserContinuo nl = navesLaser.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, nl.x, nl.y, nl.tamanho, nl.tamanho)) {
        lasers.remove(i); laserRemovido = true; nl.hp--; nl.hitTimer = 3; 
        if (nl.hp <= 0) { navesLaser.remove(j); pontuacao += 300; spawnPowerUpChance(nl.x, nl.y); if (somExplosao != null) somExplosao.play(); criarParticulas(nl.x + nl.tamanho/2, nl.y + nl.tamanho/2, 15, color(255, 50, 255)); } break;
      }
    } if (laserRemovido) continue;
    
    for (int j = serpentes.size() - 1; j >= 0; j--) { SegmentoSerpente serp = serpentes.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, serp.x, serp.y, serp.tamanho, serp.tamanho)) {
        lasers.remove(i); laserRemovido = true; serp.hp--; serp.hitTimer = 3; 
        if(serp.hp <= 0) { serpentes.remove(j); pontuacao += 150; spawnPowerUpChance(serp.x, serp.y); if (somExplosao != null) somExplosao.play(); criarParticulas(serp.x + serp.tamanho/2, serp.y + serp.tamanho/2, 15, color(50, 255, 50)); } break;
      }
    } if (laserRemovido) continue;
    
    if (estadoJogo == ESTADO_BOSS && oBoss.y >= 80 && colisaoTiro(l.x, l.y, 6, 25, oBoss.x, oBoss.y, oBoss.largura, oBoss.altura)) {
      lasers.remove(i); laserRemovido = true; bossHP--; oBoss.hitTimer = 3; 
      if (bossHP <= 0 && somExplosaoBoss != null) somExplosaoBoss.play(); break;
    }
    if (!laserRemovido && l.y < 0) lasers.remove(i);
  }

  atualizarInimigoGenerico(obstaculos, true); atualizarInimigoGenerico(minas, false); 
  atualizarInimigoGenerico(inimigos, true); atualizarInimigoGenerico(kamikazes, true); 
  atualizarInimigoGenerico(navesLaser, true); atualizarInimigoGenerico(serpentes, true); 
  
  for (int i = lasersInimigos.size() - 1; i >= 0; i--) { LaserInimigo li = lasersInimigos.get(i); li.atualizar(); li.desenhar();
    if (invencivelFrames == 0 && colisaoNave(x, y, larguraNave, alturaNave, li.x, li.y, 8, 25)) { receberDano(); lasersInimigos.remove(i); continue; }
    if (li.y > height) lasersInimigos.remove(i);
  }
  
  for (int i = powerups.size() - 1; i >= 0; i--) { PowerUp p = powerups.get(i); p.atualizar(); p.desenhar();
    if (colisaoNave(x, y, larguraNave, alturaNave, p.x, p.y, p.tamanho, p.tamanho)) { aplicarPowerUp(p); powerups.remove(i); continue; }
    if (p.y > height) powerups.remove(i);
  }
  
  if (especialOnda != null) {
    especialOnda.atualizar(); especialOnda.desenhar();
    destruirOndaEMP(obstaculos); destruirOndaEMP(minas); destruirOndaEMP(lasersInimigos);
    darDanoOndaEMP(inimigos, 1); darDanoOndaEMP(kamikazes, 1); darDanoOndaEMP(navesLaser, 2); darDanoOndaEMP(serpentes, 1);
    if (estadoJogo == ESTADO_BOSS && oBoss.y >= 80) { darDanoOndaEMP(oBoss, 5); }
    if (especialOnda.finalizada) especialOnda = null;
  }
}

void atualizarInimigoGenerico(ArrayList lista, boolean hpNaveTomaDano) {
  for (int i = lista.size() - 1; i >= 0; i--) { Object obj = lista.get(i); float enemyX, enemyY, enemyW, enemyH;
    if (obj instanceof Obstaculo) { Obstaculo obs = (Obstaculo)obj; enemyX=obs.x; enemyY=obs.y; enemyW=obs.largura; enemyH=obs.altura; obs.atualizar(); obs.desenhar(); }
    else if (obj instanceof MinaMagnetica) { MinaMagnetica m = (MinaMagnetica)obj; enemyX=m.x; enemyY=m.y; enemyW=m.tamanho; enemyH=m.tamanho; m.atualizar(); m.desenhar(); }
    else if (obj instanceof InimigoAtirador) { InimigoAtirador in = (InimigoAtirador)obj; enemyX=in.x; enemyY=in.y; enemyW=in.tamanho; enemyH=in.tamanho; in.atualizar(); in.desenhar(); in.atirar(); }
    else if (obj instanceof InimigoKamikaze) { InimigoKamikaze k = (InimigoKamikaze)obj; enemyX=k.x; enemyY=k.y; enemyW=k.tamanho_world_w; enemyH=k.tamanho_world_h; k.atualizar(); k.desenhar(); }
    else if (obj instanceof InimigoLaserContinuo) { InimigoLaserContinuo nl = (InimigoLaserContinuo)obj; enemyX=nl.x; enemyY=nl.y; enemyW=nl.tamanho; enemyH=nl.tamanho; nl.atualizar(); nl.desenhar(); checarColisaoLaserContinuo(nl); }
    else if (obj instanceof SegmentoSerpente) { SegmentoSerpente serp = (SegmentoSerpente)obj; enemyX=serp.x; enemyY=serp.y; enemyW=serp.tamanho; enemyH=serp.tamanho; serp.atualizar(); serp.desenhar(); }
    else continue;
    
    if (invencivelFrames == 0 && colisaoNave(x, y, larguraNave, alturaNave, enemyX, enemyY, enemyW, enemyH)) { 
      receberDano(); 
      if (hpNaveTomaDano) { 
        lista.remove(i); 
      } else if (obj instanceof MinaMagnetica) {
        // Se a nave bater na mina, a mina explode e some para não bloquear!
        MinaMagnetica m = (MinaMagnetica)obj;
        m.dispararEstrela();
        lista.remove(i); 
      }
    }
    if (enemyY > height) lista.remove(i);
  }
}

void checarColisaoLaserContinuo(InimigoLaserContinuo nl) {
  if (nl.estado == 1 && invencivelFrames == 0) { 
    float hitX = (nl.lado == 0) ? nl.x + nl.tamanho : limiteEsq; float hitW = (nl.lado == 0) ? limiteDir - (nl.x + nl.tamanho) : nl.x - limiteEsq;
    float hitY = nl.y + nl.tamanho/2 - 15; float hitH = 30; 
    if (colisaoNave(x, y, larguraNave, alturaNave, hitX, hitY, hitW, hitH)) { receberDano(); }
  }
}

void receberDano() { 
  vidas--; invencivelFrames = 60; shakeTimer = 15; // SCREEN SHAKE NO DANO
  if (somDanoNave != null) somDanoNave.play(); 
  if (vidas <= 0) { estadoJogo = ESTADO_GAMEOVER; }
}

boolean colisaoNave(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) { return x1 + 15 < x2 + w2 && x1 + w1 - 15 > x2 && y1 + 15 < y2 + h2 && y1 + h1 - 15 > y2; }
boolean colisaoTiro(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) { return x1 - 10 < x2 + w2 && x1 + w1 + 10 > x2 && y1 < y2 + h2 && y1 + h1 > y2; }

void aplicarPowerUp(PowerUp p) { if (somPowerUp != null) somPowerUp.play(); switch (p.tipo) { case 0: if (vidas < 5) vidas++; break; case 1: if (cargasEMP < maxCargasEMP) cargasEMP++; break; case 2: timerPowerUpTiro = 900; break; } }

void destruirOndaEMP(ArrayList lista) {
  for (int i = lista.size() - 1; i >= 0; i--) { Object obj = lista.get(i); float objX, objY, objW, objH;
    if (obj instanceof Obstaculo) { Obstaculo obs = (Obstaculo)obj; objX=obs.x; objY=obs.y; objW=obs.largura; objH=obs.altura; }
    else if (obj instanceof MinaMagnetica) { MinaMagnetica m = (MinaMagnetica)obj; objX=m.x; objY=m.y; objW=m.tamanho; objH=m.tamanho; }
    else if (obj instanceof LaserInimigo) { LaserInimigo li = (LaserInimigo)obj; objX=li.x; objY=li.y; objW=8; objH=25; } else continue;
    
    if (colisaoOndaEMP(especialOnda.x, especialOnda.y, especialOnda.raio, objX, objY, objW, objH)) {
      if (obj instanceof MinaMagnetica) {
        ((MinaMagnetica)obj).dispararEstrela();
        lista.remove(i); 
      } else { 
        lista.remove(i); 
        if (obj instanceof Obstaculo) { pontuacao += 50; criarParticulas(objX + objW/2, objY + objH/2, 10, color(150)); } 
      }
    }
  }
}

void darDanoOndaEMP(ArrayList lista, int dano) {
  for (int i = lista.size() - 1; i >= 0; i--) { Object obj = lista.get(i); float objX, objY, objW, objH;
    if (obj instanceof InimigoAtirador) { InimigoAtirador in = (InimigoAtirador)obj; objX=in.x; objY=in.y; objW=in.tamanho; objH=in.tamanho; }
    else if (obj instanceof InimigoKamikaze) { InimigoKamikaze k = (InimigoKamikaze)obj; objX=k.x; objY=k.y; objW=k.tamanho_world_w; objH=k.tamanho_world_h; }
    else if (obj instanceof InimigoLaserContinuo) { InimigoLaserContinuo nl = (InimigoLaserContinuo)obj; objX=nl.x; objY=nl.y; objW=nl.tamanho; objH=nl.tamanho; }
    else if (obj instanceof SegmentoSerpente) { SegmentoSerpente serp = (SegmentoSerpente)obj; objX=serp.x; objY=serp.y; objW=serp.tamanho; objH=serp.tamanho; } else continue;
    if (colisaoOndaEMP(especialOnda.x, especialOnda.y, especialOnda.raio, objX, objY, objW, objH)) {
      if (obj instanceof InimigoAtirador) { InimigoAtirador in = (InimigoAtirador)obj; in.hp -= dano; in.hitTimer = 3; if (in.hp <= 0) { lista.remove(i); pontuacao += 100; criarParticulas(objX, objY, 15, color(100, 200, 255)); } } 
      else if (obj instanceof InimigoKamikaze) { lista.remove(i); pontuacao += 100; criarParticulas(objX, objY, 15, color(255, 100, 0)); }
      else if (obj instanceof InimigoLaserContinuo) { InimigoLaserContinuo nl = (InimigoLaserContinuo)obj; nl.hp -= dano; nl.hitTimer = 3; if (nl.hp <= 0) { lista.remove(i); pontuacao += 300; criarParticulas(objX, objY, 15, color(255, 50, 255)); } }
      else if (obj instanceof SegmentoSerpente) { SegmentoSerpente serp = (SegmentoSerpente)obj; serp.hp -= dano; serp.hitTimer = 3; if (serp.hp <= 0) { lista.remove(i); pontuacao += 150; criarParticulas(objX, objY, 15, color(50, 255, 50)); } }
    }
  }
}
void darDanoOndaEMP(MothershipBoss boss, int dano) { if (colisaoOndaEMP(especialOnda.x, especialOnda.y, especialOnda.raio, boss.x, boss.y, boss.largura, boss.altura)) { bossHP -= dano; boss.hitTimer = 3; if (bossHP <= 0 && somExplosaoBoss != null) somExplosaoBoss.play(); } }
boolean colisaoOndaEMP(float ondaX, float ondaY, float ondaR, float objX, float objY, float objW, float objH) { return objX < ondaX + ondaR && objX + objW > ondaX - ondaR && objY < ondaY + ondaR && objY + objH > ondaY - ondaR; }

void keyPressed() {
  if (key == ENTER) { if (estadoJogo == ESTADO_VITORIA) { estadoJogo = ESTADO_LOGIN; pontuacao = 0; dificuldade = 1.0; vidas = 5; cargasEMP = 1; timerPowerUpTiro = 0; bossHP = bossHPMax; reiniciarObjetos(); } }
  
  // SISTEMA DE PAUSE (P ou ESC)
  if (key == 'p' || key == 'P' || key == ESC) {
    if (key == ESC) key = 0; // Impede que o ESC feche o jogo nativamente
    if (estadoJogo == ESTADO_JOGANDO || estadoJogo == ESTADO_BOSS) {
      estadoAnterior = estadoJogo; // Salva se estava no jogo normal ou boss
      telaPausada = get(); // Tira print exato da tela pra usar de fundo do pause!
      estadoJogo = ESTADO_PAUSE;
    } else if (estadoJogo == ESTADO_PAUSE) {
      estadoJogo = estadoAnterior; // Retoma o jogo
    }
  }

  if (keyCode == UP || key == 'w' || key == 'W') up = true; if (keyCode == DOWN || key == 's' || key == 'S') down = true;
  if (keyCode == LEFT || key == 'a' || key == 'A') left = true; if (keyCode == RIGHT || key == 'd' || key == 'D') right = true;
  if (key == 'x' || key == 'X') atirando = true;
  
  if ((key == ' ' || key == 'c' || key == 'C') && cargasEMP > 0 && (estadoJogo == ESTADO_JOGANDO || estadoJogo == ESTADO_BOSS) && especialOnda == null) { 
    especialOnda = new OndaEMP(x + larguraNave/2, y + alturaNave/2); cargasEMP--; shakeTimer = 20; // SCREEN SHAKE DO EMP
    if (somEMP != null) somEMP.play(); 
  }
  if ((key == 'r' || key == 'R') && estadoJogo == ESTADO_GAMEOVER) {
    salvarHighscore(); estadoJogo = ESTADO_CONTAGEM; framesContagem = 0; framesJogados = 0; pontuacao = 0; dificuldade = 1.0; vidas = 5; cargasEMP = 1; timerPowerUpTiro = 0; invencivelFrames = 0; bossHP = bossHPMax; proximoSpawnFrame = 0; minasDesbloqueadas = false; navesDesbloqueadas = false; serpentesDesbloqueadas = false; navesLaserDesbloqueadas = false; kamikazesDesbloqueados = false; forcarNave = false; forcarSerpente = false; forcarNaveLaser = false; forcarMina = false; forcarKamikaze = false; reiniciarObjetos();
  }
  if ((key == 'm' || key == 'M') && estadoJogo == ESTADO_GAMEOVER) { salvarHighscore(); estadoJogo = ESTADO_LOGIN; pontuacao = 0; dificuldade = 1.0; vidas = 5; cargasEMP = 1; timerPowerUpTiro = 0; invencivelFrames = 0; bossHP = bossHPMax; reiniciarObjetos(); }
}

void reiniciarObjetos() { obstaculos.clear(); minas.clear(); inimigos.clear(); kamikazes.clear(); serpentes.clear(); navesLaser.clear(); lasers.clear(); lasersInimigos.clear(); powerups.clear(); particulas.clear(); resetPosicaoNave(); }
void keyReleased() {
  if (keyCode == UP || key == 'w' || key == 'W') up = false; if (keyCode == DOWN || key == 's' || key == 'S') down = false;
  if (keyCode == LEFT || key == 'a' || key == 'A') left = false; if (keyCode == RIGHT || key == 'd' || key == 'D') right = false;
  if (key == 'x' || key == 'X') atirando = false;
}

// ===== SISTEMA DE PARTICULAS =====
class Particula {
  float x, y, vx, vy, tamanho;
  int vida, vidaMax;
  color cor;
  Particula(float startX, float startY, color c) {
    x = startX; y = startY; cor = c;
    vx = random(-6, 6); vy = random(-6, 6);
    tamanho = random(4, 12);
    vidaMax = (int)random(15, 30); vida = vidaMax;
  }
  void atualizar() { x += vx; y += vy; vida--; tamanho *= 0.95; }
  void desenhar() { noStroke(); fill(cor, map(vida, 0, vidaMax, 0, 255)); rect(x, y, tamanho, tamanho); }
}

void criarParticulas(float x, float y, int qtd, color cor) { for (int i = 0; i < qtd; i++) particulas.add(new Particula(x, y, cor)); }
void desenharParticulas() { for (int i = particulas.size() - 1; i >= 0; i--) { Particula p = particulas.get(i); p.atualizar(); p.desenhar(); if (p.vida <= 0) particulas.remove(i); } }

// ===== CLASSES DE OBJETOS COM HIT FLASH INTEGRADO =====
class Laser {
  float x, y; float velocidade = 20; 
  Laser(float startX, float startY) { x = startX; y = startY; } void atualizar() { y -= velocidade; }
  void desenhar() { if(imgLaserPlayer != null) image(imgLaserPlayer, x-10, y-10, 20, 45); else { fill(0, 255, 255); noStroke(); rect(x, y, 6, 25); } }
}

class LaserInimigo {
  float x, y; float velocidade = 7; 
  LaserInimigo(float startX, float startY) { x = startX; y = startY; } void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { if(imgLaserInimigo != null) image(imgLaserInimigo, x-10, y-10, 20, 45); else { fill(255, 50, 50); noStroke(); rect(x, y, 8, 25); } }
}

class Obstaculo {
  float x, y; float velocidade = 2.5; float largura = 160; float altura = 65; int hp = 3; int hitTimer = 0;
  Obstaculo(float startX, float startY) { x = startX; y = startY; } void atualizar() { y += velocidade * dificuldade; } 
  void desenhar() { 
    image(imgBarricada, x, y, largura, altura); 
    if (hitTimer > 0) { blendMode(ADD); tint(255, 150); image(imgBarricada, x, y, largura, altura); blendMode(BLEND); noTint(); hitTimer--; } 
  }
}

class InimigoAtirador {
  float x, y; float velocidade = 1.8; float tamanho = 90; int frameUltimoTiro; int hp = 2; int hitTimer = 0; 
  InimigoAtirador(float startX, float startY) { x = startX; y = startY; frameUltimoTiro = frameCount; }
  InimigoAtirador(float startX, float startY, float v) { x = startX; y = startY; frameUltimoTiro = frameCount; velocidade=v; tamanho=70; hp=1; } 
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { 
    image(imgSpaceShooter, x, y, tamanho, tamanho); 
    if (hitTimer > 0) { blendMode(ADD); tint(255, 150); image(imgSpaceShooter, x, y, tamanho, tamanho); blendMode(BLEND); noTint(); hitTimer--; } 
  }
  void atirar() { int intTiro = max(50, (int)(120 / dificuldade)); if (frameCount - frameUltimoTiro >= intTiro) { lasersInimigos.add(new LaserInimigo(x + tamanho/2 - 4, y + tamanho)); if(somLaserInimigo != null) somLaserInimigo.play(); frameUltimoTiro = frameCount; } }
}

class InimigoKamikaze {
  float x, y; float velocidade = 5.0; float tamanho_local_w = 50; float tamanho_local_h = 120; float tamanho_world_w; float tamanho_world_h;
  InimigoKamikaze(float startX, float startY) { this.x = startX; this.y = startY; this.tamanho_world_w = tamanho_local_w; this.tamanho_world_h = tamanho_local_h; }
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { pushMatrix(); translate(x + tamanho_world_w/2, y + tamanho_world_h/2); rotate(HALF_PI); image(imgKamikaze, -tamanho_local_h/2, -tamanho_local_w/2, tamanho_local_h, tamanho_local_w); popMatrix(); }
}

class SegmentoSerpente {
  float x, y, startX; float tamanho; float velocidade = 2.2; float angulo; float amplitude = 350; boolean eCabeca; int hp = 1; int hitTimer = 0; 
  SegmentoSerpente(float startX, float startY, float aInicial, boolean cabeca) { this.startX = startX; this.x = startX; this.y = startY; this.angulo = aInicial; this.eCabeca = cabeca; this.tamanho = cabeca ? 75 : 68; }
  void atualizar() { y += velocidade * dificuldade; angulo += 0.02 * dificuldade; x = startX + sin(angulo) * amplitude; x = constrain(x, limiteEsq, limiteDir - tamanho); }
  void desenhar() { 
    PImage img = eCabeca ? imgSnakeHead : imgSnakeBody;
    image(img, x, y, tamanho, tamanho); 
    if (hitTimer > 0) { blendMode(ADD); tint(255, 150); image(img, x, y, tamanho, tamanho); blendMode(BLEND); noTint(); hitTimer--; } 
  }
}

class InimigoLaserContinuo {
  float x, y; float velocidade = 1.5; float tamanho = 110; int hp = 6; int lado, estado = 0, timer = 60; int hitTimer = 0; 
  InimigoLaserContinuo(float startY, int ladoSorteado) { this.y = startY; this.lado = ladoSorteado; this.x = (lado == 0) ? limiteEsq : limiteDir - tamanho; }
  void atualizar() { y += velocidade * dificuldade; timer--; if (timer <= 0) { estado = (estado == 0) ? 1 : 0; timer = 60; } }
  void desenhar() {
    if (estado == 1) { noStroke(); fill(200, 0, 255, random(150, 255)); if (lado == 0) { rect(x + tamanho, y + tamanho/2 - 15, limiteDir - (x + tamanho), 30); fill(255, random(200, 255)); rect(x + tamanho, y + tamanho/2 - 5, limiteDir - (x + tamanho), 10); } else { rect(limiteEsq, y + tamanho/2 - 15, x - limiteEsq, 30); fill(255, random(200, 255)); rect(limiteEsq, y + tamanho/2 - 5, x - limiteEsq, 10); } }
    pushMatrix(); translate(x + tamanho/2, y + tamanho/2); if (lado == 0) rotate(HALF_PI); else rotate(-HALF_PI); 
    image(imgSpaceLaser, -tamanho/2, -tamanho/2, tamanho, tamanho); 
    if (hitTimer > 0) { blendMode(ADD); tint(255, 150); image(imgSpaceLaser, -tamanho/2, -tamanho/2, tamanho, tamanho); blendMode(BLEND); noTint(); hitTimer--; } 
    popMatrix(); 
  }
}

class MinaMagnetica {
  float x, y; float velocidade = 1.2; float tamanho = 85; int hp = 1; // Variável 'explodiu' inútil removida
  MinaMagnetica(float startX, float startY) { this.x = startX; this.y = startY; }
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { image(imgMinaMagnetica, x, y, tamanho, tamanho); }
  void dispararEstrela() {
    shakeTimer = 10; 
    float v = 5 * dificuldade;
    lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, 0, -v)); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, v/sqrt(2), -v/sqrt(2))); 
    lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, v, 0)); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, v/sqrt(2), v/sqrt(2))); 
    lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, 0, v)); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, -v/sqrt(2), v/sqrt(2))); 
    lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, -v, 0)); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, -v/sqrt(2), -v/sqrt(2))); 
  }
}

class LaserInimigoSimples extends LaserInimigo {
  float vx, vy; LaserInimigoSimples(float x, float y, float vx, float vy) { super(x, y); this.vx = vx; this.vy = vy; }
  void atualizar() { x += vx; y += vy; } void desenhar() { fill(255, 100, 100); noStroke(); ellipse(x, y, 15, 15); } 
}

class MothershipBoss {
  float x, y; float velocidade = 1.0; float largura = (width * 0.78 - width * 0.22) * 0.7; float altura = 300; int timerAtaque; int padraoAtaque = 0; int hitTimer = 0; 
  MothershipBoss() { this.x = width/2 - largura/2; this.y = -400; this.timerAtaque = 180; }
  void atualizar() {
    if (y < 80) { y += velocidade; }
    if (bossHP > 0 && y >= 80) { timerAtaque--; if (timerAtaque <= 0) { realizarAtaque(); padraoAtaque = (padraoAtaque + 1) % 2; timerAtaque = 180 + (int)random(60); }
    } else if (bossHP <= 0) { estadoJogo = ESTADO_ANIMACAO_VITORIA; }
  }
  void desenhar() {
    pushMatrix(); translate(x + largura/2, y + altura/2);
    PImage img = (bossHP <= 0 && invencivelFrames % 10 < 5) ? imgPlayerBroken : imgMothershipBoss;
    image(img, -largura/2, -altura/2, largura, altura); 
    if (hitTimer > 0) { blendMode(ADD); tint(255, 150); image(img, -largura/2, -altura/2, largura, altura); blendMode(BLEND); noTint(); hitTimer--; } 
    popMatrix();
  }
  void realizarAtaque() { if (padraoAtaque == 0) { float v = 6 * dificuldade; for (int i = 0; i < 5; i++) { lasersInimigos.add(new LaserInimigoSimples(x + largura/2, y + altura, (i-2)*1.5, v)); } } else { inimigos.add(new InimigoAtirador(limiteEsq + 50, -50, 2.5)); inimigos.add(new InimigoAtirador(limiteDir - 130, -50, 2.5)); } }
}

class OndaEMP {
  float x, y, raio = 0, raioMax = 500, velocidadeExpansao = 15; boolean finalizada = false;
  OndaEMP(float startX, float startY) { this.x = startX; this.y = startY; }
  void atualizar() { if (raio < raioMax) { raio += velocidadeExpansao; } else { finalizada = true; } }
  void desenhar() { noFill(); stroke(255, 255, 0, map(raio, 0, raioMax, 255, 0)); strokeWeight(15); ellipse(x, y, raio * 2, raio * 2); }
}

class PowerUp {
  float x, y, velocidade = 3.0, tamanho = 50; int tipo; 
  PowerUp(float startX, float startY) { this.x = constrain(startX, limiteEsq + 50, limiteDir - 100); this.y = startY; float sorteio = random(100); if (sorteio < 40) tipo = 0; else if (sorteio < 70) tipo = 1; else tipo = 2; }
  void atualizar() { y += velocidade; x += sin(frameCount * 0.1) * 0.5; }
  void desenhar() { noStroke(); if (tipo == 0) fill(50, 255, 100, 50); else if (tipo == 1) fill(255, 255, 0, 50); else if (tipo == 2) fill(50, 100, 255, 50); ellipse(x + tamanho/2, y + tamanho/2, tamanho*1.5, tamanho*1.5); switch (tipo) { case 0: image(imgPowerUpVida, x, y, tamanho, tamanho); break; case 1: image(imgPowerUpEspecial, x, y, tamanho, tamanho); break; case 2: image(imgPowerUpTiro, x, y, tamanho, tamanho); break; } }
}
