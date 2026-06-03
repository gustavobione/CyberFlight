import processing.sound.*; 
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
import controlP5.*;
import org.gamecontrolplus.*;
import java.io.*;

// ===== MOTOR DE EFEITOS VISUAIS (VFX) =====
PostFX fx;

// ===== BIBLIOTECAS DE CONFIGURAÇÃO =====
ControlP5 cp5;
ControlIO control;
ControlDevice gamepad;

// ===== IMAGENS GLOBAIS =====
PImage imgPlayer, imgPlayerUp, imgDown, imgRight, imgLeft, imgPlayerBroken, spriteAtual;
PImage imgVidaNormal, imgBackground, imgBarricada, imgSnakeHead, imgSnakeBody;
PImage imgSpaceShooter, imgSpaceLaser, imgMinaMagnetica, imgMothershipBoss;
PImage imgPowerUpEspecial, imgPowerUpVida, imgPowerUpTiro, imgKamikaze; 
PImage imgLaserPlayer, imgLaserInimigo, imgMenuBG, imgBossDefeated, telaPausada; 

// ===== ÁUDIOS GLOBAIS =====
SoundFile somMusicaFundo, somLaserPlayer, somDanoNave, somLaserInimigo;
SoundFile somExplosao, somExplosaoBoss, somPowerUp, somEMP, somAlarmeBoss;

// ===== VARIÁVEIS DE ÁUDIO =====
float volMusica = 0.6;
float volEfeitos = 0.3;

// ===== MAPEAMENTO DE CONTROLES (ESTRUTURA COMPARTILHADA) =====
int teclaUp = UP, teclaDown = DOWN, teclaLeft = LEFT, teclaRight = RIGHT, teclaAtirar = 'X', teclaEMP = ' ';
String joyUp = "Y-Axis-", joyDown = "Y-Axis+", joyLeft = "X-Axis-", joyRight = "X-Axis+", joyAtirar = "Button 0", joyEMP = "Button 1";

// Variáveis para controle de remapeamento ativo
String acaoRemapeando = "";
boolean remapeandoTeclado = false;
boolean remapeandoJoy = false;

// ===== FONTES GLOBAIS =====
PFont fonteNormal, fonteTitulo;

// ===== ESTADOS DO JOGO =====
final int ESTADO_LOGIN = 0, ESTADO_LEADERBOARD = 1, ESTADO_CONTAGEM = 2, ESTADO_JOGANDO = 3;
final int ESTADO_BOSS = 4, ESTADO_ANIMACAO_VITORIA = 5, ESTADO_VITORIA = 6, ESTADO_GAMEOVER = 7;
final int ESTADO_PAUSE = 8, ESTADO_CREDITOS = 9, ESTADO_INSTRUCOES = 10, ESTADO_CONFIG = 11;
int estadoJogo = ESTADO_LOGIN, estadoAnterior = ESTADO_JOGANDO; 

// ===== VARIÁVEIS GLOBAIS (FÍSICA E PROGRESSÃO) =====
float bgY1, bgY2, limiteEsq, limiteDir;
int larguraNave = 100, alturaNave = 100;
float x, y, vx, vy, aceleracao = 1.8, atrito = 0.85; 

// Separação de canais de input para evitar de um controle anular o outro
boolean tecladoUp, tecladoDown, tecladoLeft, tecladoRight, tecladoAtirando;
boolean up, down, left, right, atirando = false;

int framesContagem = 0, framesJogados = 0, pontuacao = 0, highscore = 0; 
float dificuldade = 1.0, bossHPMax = 500, bossHP = bossHPMax;
int vidas = 5, invencivelFrames = 0, intervaloTiro = 12, ultimoDisparoFrame = 0;  

// ===== VARIÁVEIS DE SISTEMAS (SPAWN E ITEMS) =====
int proximoSpawnFrame = 0; 
boolean navesDesbloqueadas = false, serpentesDesbloqueadas = false, navesLaserDesbloqueadas = false;
boolean minasDesbloqueadas = false, kamikazesDesbloqueados = false;
boolean forcarNave = false, forcarSerpente = false, forcarNaveLaser = false, forcarMina = false, forcarKamikaze = false;

int cargasEMP = 1, maxCargasEMP = 3, timerPowerUpTiro = 0, shakeTimer = 0; 
boolean temTiroDuplo = false;
OndaEMP especialOnda;
MothershipBoss oBoss; 

// ===== LISTAS DE ENTIDADES =====
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<LaserInimigo> lasersInimigos = new ArrayList<LaserInimigo>();
ArrayList<Obstaculo> obstaculos = new ArrayList<Obstaculo>(); 
ArrayList<MinaMagnetica> minas = new ArrayList<MinaMagnetica>();
ArrayList<InimigoAtirador> inimigos = new ArrayList<InimigoAtirador>();
ArrayList<SegmentoSerpente> serpentes = new ArrayList<SegmentoSerpente>(); 
ArrayList<InimigoLaserContinuo> navesLaser = new ArrayList<InimigoLaserContinuo>();
ArrayList<InimigoKamikaze> kamikazes = new ArrayList<InimigoKamikaze>();
ArrayList<PowerUp> powerups = new ArrayList<PowerUp>(); 
ArrayList<Particula> particulas = new ArrayList<Particula>();

void setup() {
  fullScreen(P2D); 
  frameRate(60);
  limiteEsq = width * 0.22; limiteDir = width * 0.78;
  carregarHighscore(); 
  
  fx = new PostFX(this);
  
  // INICIALIZANDO O CONTROLE COM A ROTINA COMPATÍVEL DA 8BITDO
  control = ControlIO.getInstance(this);
  for(ControlDevice dev : control.getDevices()) {
    if(dev.getTypeName().equals("Gamepad") || dev.getTypeName().equals("Stick")) {
      gamepad = dev; 
      println("Controle Detectado com Sucesso: " + gamepad.getName());
      break; 
    }
  }

  // CONFIGURAÇÃO INICIAL DO CONTROLP5
  cp5 = new ControlP5(this);
  configurarInterfaceConfiguracoes();
  
  try { fonteNormal = createFont("Font/Orbitron-Regular.ttf", 32); } catch(Exception e) { fonteNormal = createFont("Arial", 32); }
  try { fonteTitulo = createFont("Font/Orbitron-ExtraBold.ttf", 80); } catch(Exception e) { fonteTitulo = createFont("Arial", 80); }
  textFont(fonteNormal); 
  
  // CARREGAMENTO DE IMAGENS
  imgPlayer = loadImage("Sprites/Player/nave.png"); 
  imgPlayerUp = loadImage("Sprites/Player/naveUp.png");
  imgDown = loadImage("Sprites/Player/naveDown.png"); 
  imgRight = loadImage("Sprites/Player/naveRight.png");
  imgLeft = loadImage("Sprites/Player/naveLeft.png"); 
  imgPlayerBroken = loadImage("Sprites/Player/nave-Broken.png"); 
  
  imgBackground = loadImage("Sprites/HUD/Background.png"); 
  imgBarricada = loadImage("Sprites/Enemys/Barricade.png");
  imgSnakeHead = loadImage("Sprites/Enemys/SnakeHead.png"); 
  imgSnakeBody = loadImage("Sprites/Enemys/SnakeBody.png");
  imgSpaceShooter = loadImage("Sprites/Enemys/SpaceShooter.png"); 
  imgSpaceLaser = loadImage("Sprites/Enemys/SpaceLaser.png"); 
  imgMinaMagnetica = loadImage("Sprites/Enemys/Bomb.png"); 
  
  imgPowerUpEspecial = loadImage("Sprites/HUD/Special.png");
  imgPowerUpVida = loadImage("Sprites/HUD/Vida.png"); 
  imgPowerUpTiro = loadImage("Sprites/HUD/Upgrade.png");
  
  imgMothershipBoss = loadImage("Sprites/Boss/Boss.png"); 
  imgKamikaze = loadImage("Sprites/Enemys/Kamikaze.png");
  
  try { imgLaserPlayer = loadImage("Sprites/HUD/LaserPlayer.png"); } catch(Exception e) {}
  try { imgLaserInimigo = loadImage("Sprites/HUD/LaserInimigo.png"); } catch(Exception e) {}
  try { imgMenuBG = loadImage("Sprites/HUD/MenuBG.png"); } catch(Exception e) {}
  try { imgBossDefeated = loadImage("Sprites/Boss/BossDefeated.png"); } catch(Exception e) {}
  
  imgPlayer.resize(larguraNave, alturaNave); imgPlayerUp.resize(larguraNave, alturaNave);
  imgDown.resize(larguraNave, alturaNave); imgRight.resize(larguraNave, alturaNave);
  imgLeft.resize(larguraNave, alturaNave); imgPlayerBroken.resize(larguraNave, alturaNave);
  imgBackground.resize(width, 0); 
  if(imgMenuBG != null) imgMenuBG.resize(width, height);
  bgY1 = 0; bgY2 = -imgBackground.height; 
  imgVidaNormal = imgPlayer.get(); imgVidaNormal.resize(45, 45);
  spriteAtual = imgPlayer;
  
  resetPosicaoNave();
  
  // CARREGAMENTO DE ÁUDIOS
  try { somMusicaFundo = new SoundFile(this, "Sound/Musica/MusicaFundo.wav"); somMusicaFundo.amp(volMusica); somMusicaFundo.loop(); } catch(Exception e) {}
  try { somLaserPlayer = new SoundFile(this, "Sound/SFX/LaserPlayer.wav"); somLaserPlayer.amp(volEfeitos); } catch(Exception e) {}
  try { somDanoNave = new SoundFile(this, "Sound/SFX/DanoNave.wav"); somDanoNave.amp(volEfeitos); } catch(Exception e) {}
  try { somLaserInimigo = new SoundFile(this, "Sound/SFX/LaserInimigo.wav"); somLaserInimigo.amp(volEfeitos); } catch(Exception e) {}
  try { somExplosao = new SoundFile(this, "Sound/SFX/Explosao.wav"); somExplosao.amp(volEfeitos); } catch(Exception e) {}
  try { somExplosaoBoss = new SoundFile(this, "Sound/SFX/ExplosaoBoss.wav"); somExplosaoBoss.amp(volEfeitos); } catch(Exception e) {}
  try { somPowerUp = new SoundFile(this, "Sound/SFX/PowerUp.wav"); somPowerUp.amp(volEfeitos); } catch(Exception e) {}
  try { somEMP = new SoundFile(this, "Sound/SFX/SomEMP.wav"); somEMP.amp(volEfeitos); } catch(Exception e) {}
  try { somAlarmeBoss = new SoundFile(this, "Sound/SFX/AlarmeBoss.wav"); somAlarmeBoss.amp(volEfeitos); } catch(Exception e) {}
}

void draw() {
  if (estadoJogo == ESTADO_LOGIN || estadoJogo == ESTADO_LEADERBOARD || estadoJogo == ESTADO_CREDITOS || estadoJogo == ESTADO_INSTRUCOES || estadoJogo == ESTADO_CONFIG) {
    if (imgMenuBG != null) image(imgMenuBG, 0, 0); else { fill(10, 15, 30); rect(0, 0, width, height); }
  } else if (estadoJogo != ESTADO_PAUSE) { 
    float velocidadeFundo = (estadoJogo == ESTADO_ANIMACAO_VITORIA) ? 6 : 2 * (dificuldade * 0.8);
    bgY1 += velocidadeFundo; bgY2 += velocidadeFundo;
    if (bgY1 >= height) bgY1 = bgY2 - imgBackground.height;
    if (bgY2 >= height) bgY2 = bgY1 - imgBackground.height;
    image(imgBackground, 0, bgY1); image(imgBackground, 0, bgY2);
  }

  if (estadoJogo == ESTADO_JOGANDO || estadoJogo == ESTADO_BOSS) {
    atualizarEntradasJoystick();
  }

  switch (estadoJogo) {
    case ESTADO_LOGIN: exibirTelaLogin(); break;
    case ESTADO_CONFIG: exibirTelaConfiguracoes(); break; 
    case ESTADO_INSTRUCOES: exibirTelaInstrucoes(); break;
    case ESTADO_LEADERBOARD: exibirTelaLeaderboard(); break;
    case ESTADO_CREDITOS: exibirTelaCreditos(); break; 
    case ESTADO_CONTAGEM: executarContagem(); break;
    case ESTADO_JOGANDO: executarLoopJogo(); break;
    case ESTADO_BOSS: executarBatalhaBoss(); break;
    case ESTADO_ANIMACAO_VITORIA: executarAnimacaoVitoria(); break;
    case ESTADO_VITORIA: exibirTelaVitoria(); break;
    case ESTADO_GAMEOVER: exibirTelaGameOver(); break;
    case ESTADO_PAUSE: exibirTelaPause(); break;
  }
  
  if (estadoJogo == ESTADO_JOGANDO || estadoJogo == ESTADO_BOSS || estadoJogo == ESTADO_ANIMACAO_VITORIA) {
    PostFXBuilder pass = fx.render();
    pass.bloom(0.4, 20, 30); 
    if (shakeTimer > 0) {
      float distorcao = map(shakeTimer, 0, 40, 0, 100);
      pass.rgbSplit(distorcao); 
    }
    pass.compose(); 
  }
}

void reiniciarObjetos() {
  obstaculos.clear(); minas.clear(); inimigos.clear(); kamikazes.clear(); serpentes.clear(); 
  navesLaser.clear(); lasers.clear(); lasersInimigos.clear(); powerups.clear(); particulas.clear(); 
  resetPosicaoNave(); 
}

void mousePressed() {
  if (estadoJogo == ESTADO_LOGIN) {
    if (checarCliqueBotao(width/2, height/2 - 30)) { estadoJogo = ESTADO_INSTRUCOES; } 
    if (checarCliqueBotao(width/2, height/2 + 60)) { estadoJogo = ESTADO_CONFIG; cp5.show(); }
    if (checarCliqueBotao(width/2, height/2 + 150)) { estadoJogo = ESTADO_LEADERBOARD; } 
    if (checarCliqueBotao(width/2, height/2 + 240)) { estadoJogo = ESTADO_CREDITOS; } 
    if (checarCliqueBotao(width/2, height/2 + 330)) { exit(); }
  } else if (estadoJogo == ESTADO_INSTRUCOES) {
    if (checarCliqueBotao(width/2, height - 120)) { estadoJogo = ESTADO_CONTAGEM; framesContagem = 0; }
  } else if (estadoJogo == ESTADO_LEADERBOARD || estadoJogo == ESTADO_CREDITOS) { 
    float voltarY = (estadoJogo == ESTADO_CREDITOS) ? height/2 + 200 : height/2 + 150;
    if (checarCliqueBotao(width/2, voltarY)) { estadoJogo = ESTADO_LOGIN; }
  } else if (estadoJogo == ESTADO_PAUSE) { 
    if (checarCliqueBotao(width/2, height/2)) { estadoJogo = estadoAnterior; }
    if (checarCliqueBotao(width/2, height/2 + 100)) { estadoJogo = ESTADO_LOGIN; reiniciarObjetos(); }
  } else if (estadoJogo == ESTADO_CONFIG) {
    interacaoMouseConfig();
  }
}

void keyPressed() {
  if (remapKeyPressed()) return; 

  if (key == ENTER) { if (estadoJogo == ESTADO_VITORIA) { estadoJogo = ESTADO_LOGIN; pontuacao = 0; dificuldade = 1.0; vidas = 5; cargasEMP = 1; timerPowerUpTiro = 0; bossHP = bossHPMax; reiniciarObjetos(); } }
  
  if (key == 'p' || key == 'P' || key == ESC) {
    if (key == ESC) key = 0; 
    if (estadoJogo == ESTADO_JOGANDO || estadoJogo == ESTADO_BOSS) {
      estadoAnterior = estadoJogo; telaPausada = get(); estadoJogo = ESTADO_PAUSE;
    } else if (estadoJogo == ESTADO_PAUSE) { estadoJogo = estadoAnterior; }
  }

  if (keyCode == teclaUp || key == Character.toLowerCase(teclaUp) || key == Character.toUpperCase(teclaUp)) tecladoUp = true; 
  if (keyCode == teclaDown || key == Character.toLowerCase(teclaDown) || key == Character.toUpperCase(teclaDown)) tecladoDown = true;
  if (keyCode == teclaLeft || key == Character.toLowerCase(teclaLeft) || key == Character.toUpperCase(teclaLeft)) tecladoLeft = true; 
  if (keyCode == teclaRight || key == Character.toLowerCase(teclaRight) || key == Character.toUpperCase(teclaRight)) tecladoRight = true;
  if (keyCode == teclaAtirar || key == Character.toLowerCase(teclaAtirar) || key == Character.toUpperCase(teclaAtirar)) tecladoAtirando = true;
  
  if ((keyCode == teclaEMP || key == Character.toLowerCase(teclaEMP) || key == Character.toUpperCase(teclaEMP)) && cargasEMP > 0 && (estadoJogo == ESTADO_JOGANDO || estadoJogo == ESTADO_BOSS) && especialOnda == null) { 
    especialOnda = new OndaEMP(x + larguraNave/2, y + alturaNave/2); cargasEMP--; shakeTimer = 20; 
    if (somEMP != null) somEMP.play(); 
  }
  
  if ((key == 'r' || key == 'R') && estadoJogo == ESTADO_GAMEOVER) {
    salvarHighscore(); estadoJogo = ESTADO_CONTAGEM; framesContagem = 0; framesJogados = 0; pontuacao = 0; dificuldade = 1.0; vidas = 5; cargasEMP = 1; timerPowerUpTiro = 0; invencivelFrames = 0; bossHP = bossHPMax; proximoSpawnFrame = 0; reiniciarObjetos();
  }
  if ((key == 'm' || key == 'M') && estadoJogo == ESTADO_GAMEOVER) { salvarHighscore(); estadoJogo = ESTADO_LOGIN; pontuacao = 0; dificuldade = 1.0; vidas = 5; cargasEMP = 1; timerPowerUpTiro = 0; invencivelFrames = 0; bossHP = bossHPMax; reiniciarObjetos(); }
}

void keyReleased() {
  if (keyCode == teclaUp || key == Character.toLowerCase(teclaUp) || key == Character.toUpperCase(teclaUp)) tecladoUp = false; 
  if (keyCode == teclaDown || key == Character.toLowerCase(teclaDown) || key == Character.toUpperCase(teclaDown)) tecladoDown = false;
  if (keyCode == teclaLeft || key == Character.toLowerCase(teclaLeft) || key == Character.toUpperCase(teclaLeft)) tecladoLeft = false; 
  if (keyCode == teclaRight || key == Character.toLowerCase(teclaRight) || key == Character.toUpperCase(teclaRight)) tecladoRight = false;
  if (keyCode == teclaAtirar || key == Character.toLowerCase(teclaAtirar) || key == Character.toUpperCase(teclaAtirar)) tecladoAtirando = false;
}
