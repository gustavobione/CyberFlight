// ===== IMAGENS =====
PImage imgNave, imgNaveUp, imgDown, imgRight, imgLeft, imgNaveBroken;
PImage imgVidaNormal, imgVidaQuebrada;
PImage spriteAtual; 

PImage imgBackground;
PImage imgBarricada;
PImage imgSnakeHead;
PImage imgSnakeBody;
PImage imgSpaceShooter;
PImage imgSpaceLaser; // NOVO INIMIGO

// Controle do Fundo Infinito
float bgY1, bgY2;

int larguraNave = 100; 
int alturaNave = 100;

float x, y;
float vx, vy; 
float aceleracao = 1.8; 
float atrito = 0.85; 

boolean up, down, left, right;

// ===== LIMITES DO ABISMO =====
float limiteEsq;
float limiteDir;

// ===== SISTEMA DE ESTADOS E PROGRESSÃO =====
int estadoJogo = 1; 
int framesContagem = 0;
int framesJogados = 0;
float dificuldade = 1.0;
int pontuacao = 0;
int vidas = 5;
int invencivelFrames = 0; 

// ===== SISTEMA DE SPAWN CENTRALIZADO =====
int proximoSpawnFrame = 0; 
boolean navesDesbloqueadas = false;
boolean serpentesDesbloqueadas = false;
boolean navesLaserDesbloqueadas = false; // NOVO DESBLOQUEIO
boolean forcarNave = false;
boolean forcarSerpente = false;
boolean forcarNaveLaser = false;

// ===== LISTAS DE OBJETOS NA TELA =====
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<LaserInimigo> lasersInimigos = new ArrayList<LaserInimigo>();
ArrayList<Obstaculo> obstaculos = new ArrayList<Obstaculo>(); 
ArrayList<InimigoAtirador> inimigos = new ArrayList<InimigoAtirador>();
ArrayList<SegmentoSerpente> serpentes = new ArrayList<SegmentoSerpente>(); 
ArrayList<InimigoLaserContinuo> navesLaser = new ArrayList<InimigoLaserContinuo>(); // LISTA DO NOVO INIMIGO

boolean atirando = false;
int intervaloTiro = 12;      
int ultimoDisparoFrame = 0;  

void setup() {
  fullScreen(P2D); 
  frameRate(60);
  
  limiteEsq = width * 0.22;
  limiteDir = width * 0.78;
  
  imgNave = loadImage("nave.png");
  imgNaveUp = loadImage("naveUp.png");
  imgDown = loadImage("naveDown.png");
  imgRight = loadImage("naveRight.png");
  imgLeft = loadImage("naveLeft.png");
  imgNaveBroken = loadImage("nave-Broken.png"); 
  
  imgBackground = loadImage("Background.png");
  imgBarricada = loadImage("Barricade.png");
  imgSnakeHead = loadImage("SnakeHead.png");
  imgSnakeBody = loadImage("SnakeBody.png");
  imgSpaceShooter = loadImage("SpaceShooter.png");
  imgSpaceLaser = loadImage("SpaceLaser.png"); // CARREGA A IMAGEM NOVA
  
  imgNave.resize(larguraNave, alturaNave);
  imgNaveUp.resize(larguraNave, alturaNave);
  imgDown.resize(larguraNave, alturaNave);
  imgRight.resize(larguraNave, alturaNave);
  imgLeft.resize(larguraNave, alturaNave);
  imgNaveBroken.resize(larguraNave, alturaNave);
  
  imgBackground.resize(width, 0); 
  bgY1 = 0;
  bgY2 = -imgBackground.height; 
  
  imgVidaNormal = imgNave.get(); imgVidaNormal.resize(45, 45);
  imgVidaQuebrada = imgNaveBroken.get(); imgVidaQuebrada.resize(45, 45);
  
  spriteAtual = imgNave;
  resetPosicaoNave();
}

void resetPosicaoNave() {
  x = width / 2 - (larguraNave / 2);
  y = height - alturaNave - 20;
  vx = 0; vy = 0;
}

void draw() {
  // ===== DESENHA O FUNDO ROLANDO =====
  float velocidadeFundo = 2 * (dificuldade * 0.8);
  bgY1 += velocidadeFundo;
  bgY2 += velocidadeFundo;
  
  if (bgY1 >= height) bgY1 = bgY2 - imgBackground.height;
  if (bgY2 >= height) bgY2 = bgY1 - imgBackground.height;
  
  image(imgBackground, 0, bgY1);
  image(imgBackground, 0, bgY2);

  if (estadoJogo == 3) {
    exibirTelaGameOver();
    return; 
  }
  
  // ===== MOVIMENTAÇÃO DA NAVE =====
  if (up) vy -= aceleracao;
  if (down) vy += aceleracao;
  if (left) vx -= aceleracao;
  if (right) vx += aceleracao;
  
  vx *= atrito; vy *= atrito;
  x += vx; y += vy;
  
  x = constrain(x, limiteEsq, limiteDir - larguraNave);
  y = constrain(y, 0, height - alturaNave);
  
  if (invencivelFrames > 0) {
    invencivelFrames--;
    spriteAtual = (invencivelFrames % 8 < 4) ? imgNaveBroken : imgNave;
  } else {
    if (up) spriteAtual = imgNaveUp;
    else if (down) spriteAtual = imgDown;
    else if (left) spriteAtual = imgLeft;
    else if (right) spriteAtual = imgRight;
    else spriteAtual = imgNave;
  }
  image(spriteAtual, x, y);
  
  // ===== INTERFACE (HUD) =====
  for (int i = 0; i < 5; i++) {
    image(i < vidas ? imgVidaNormal : imgVidaQuebrada, 30 + (i * 55), 30);
  }
  
  fill(255); textSize(40); textAlign(RIGHT, TOP);
  text("SCORE: " + nf(pontuacao, 7), width - 30, 30);

  // ===== ESTADO 1: CONTAGEM REGRESSIVA =====
  if (estadoJogo == 1) {
    framesContagem++;
    int segundosRestantes = 3 - (framesContagem / 60);
    
    fill(0, 255, 255, 150); textAlign(CENTER, CENTER); textSize(120);
    if (segundosRestantes > 0) {
      text(segundosRestantes, width/2, height/2);
    } else {
      text("GO!", width/2, height/2);
      if (framesContagem > 240) {
        estadoJogo = 2; 
        proximoSpawnFrame = frameCount + 60; 
      }
    }
    return; 
  }

  // ===== ESTADO 2: JOGO RODANDO =====
  framesJogados++;
  dificuldade = 1.0 + (pontuacao / 3000.0);
  
  // Lógica de Desbloqueio de Inimigos
  if (pontuacao >= 1000 && !navesDesbloqueadas) {
    navesDesbloqueadas = true; forcarNave = true; 
  }
  if (pontuacao >= 3000 && !serpentesDesbloqueadas) {
    serpentesDesbloqueadas = true; forcarSerpente = true; 
  }
  if (pontuacao >= 5000 && !navesLaserDesbloqueadas) {
    navesLaserDesbloqueadas = true; forcarNaveLaser = true; 
  }

  // TIRO DO JOGADOR
  if (atirando && (frameCount - ultimoDisparoFrame >= intervaloTiro)) {
    lasers.add(new Laser(x + larguraNave/2 - 3, y)); 
    ultimoDisparoFrame = frameCount; 
  }

  // ===== ATUALIZA TIROS E VERIFICA COLISÕES =====
  for (int i = lasers.size() - 1; i >= 0; i--) {
    Laser l = lasers.get(i);
    l.atualizar(); l.desenhar();
    boolean laserRemovido = false;

    // Laser vs Barricada
    for (int j = obstaculos.size() - 1; j >= 0; j--) {
      Obstaculo obs = obstaculos.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, obs.x, obs.y, obs.largura, obs.altura)) {
        lasers.remove(i); laserRemovido = true;
        obs.hp--; if (obs.hp <= 0) { obstaculos.remove(j); pontuacao += 100; }
        break;
      }
    }
    if (laserRemovido) continue;
    
    // Laser vs Nave Atiradora Normal
    for (int j = inimigos.size() - 1; j >= 0; j--) {
      InimigoAtirador in = inimigos.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, in.x, in.y, in.tamanho, in.tamanho)) {
        lasers.remove(i); laserRemovido = true;
        inimigos.remove(j); pontuacao += 200;
        break;
      }
    }
    if (laserRemovido) continue;

    // Laser vs Nave Laser Contínuo
    for (int j = navesLaser.size() - 1; j >= 0; j--) {
      InimigoLaserContinuo nl = navesLaser.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, nl.x, nl.y, nl.tamanho, nl.tamanho)) {
        lasers.remove(i); laserRemovido = true;
        nl.hp--; if (nl.hp <= 0) { navesLaser.remove(j); pontuacao += 300; }
        break;
      }
    }
    if (laserRemovido) continue;
    
    // Laser vs Serpente
    for (int j = serpentes.size() - 1; j >= 0; j--) {
      SegmentoSerpente serp = serpentes.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, serp.x, serp.y, serp.tamanho, serp.tamanho)) {
        lasers.remove(i); laserRemovido = true;
        serp.hp--; if(serp.hp <= 0) { serpentes.remove(j); pontuacao += 150; }
        break;
      }
    }
    
    if (!laserRemovido && l.y < 0) lasers.remove(i);
  }

  // ===== CHAMA A FUNÇÃO CENTRAL DE SPAWN =====
  gerenciarSpawn();

  // ===== ATUALIZAÇÃO DOS INIMIGOS E COLISÃO COM A NAVE DO JOGADOR =====
  
  for (int i = obstaculos.size() - 1; i >= 0; i--) {
    Obstaculo obs = obstaculos.get(i);
    obs.atualizar(); obs.desenhar();
    if (invencivelFrames == 0 && colisaoNave(x, y, larguraNave, alturaNave, obs.x, obs.y, obs.largura, obs.altura)) {
      receberDano(); obstaculos.remove(i); continue;
    }
    if (obs.y > height) obstaculos.remove(i);
  }

  for (int i = inimigos.size() - 1; i >= 0; i--) {
    InimigoAtirador in = inimigos.get(i);
    in.atualizar(); in.desenhar(); in.atirar(); 
    if (invencivelFrames == 0 && colisaoNave(x, y, larguraNave, alturaNave, in.x, in.y, in.tamanho, in.tamanho)) {
      receberDano(); inimigos.remove(i); continue;
    }
    if (in.y > height) inimigos.remove(i);
  }

  // ATUALIZAÇÃO DA NOVA NAVE LASER CONTÍNUO
  for (int i = navesLaser.size() - 1; i >= 0; i--) {
    InimigoLaserContinuo nl = navesLaser.get(i);
    nl.atualizar(); nl.desenhar();
    
    // Colisão com o corpo da nave inimiga
    if (invencivelFrames == 0 && colisaoNave(x, y, larguraNave, alturaNave, nl.x, nl.y, nl.tamanho, nl.tamanho)) {
      receberDano(); navesLaser.remove(i); continue;
    }
    
    // Colisão com o feixe de Laser Contínuo
    if (nl.estado == 1 && invencivelFrames == 0) { // Se estiver atirando
      float hitX = (nl.lado == 0) ? nl.x + nl.tamanho : limiteEsq;
      float hitW = (nl.lado == 0) ? limiteDir - (nl.x + nl.tamanho) : nl.x - limiteEsq;
      float hitY = nl.y + nl.tamanho/2 - 15;
      float hitH = 30; // Altura do laser
      
      if (colisaoNave(x, y, larguraNave, alturaNave, hitX, hitY, hitW, hitH)) {
        receberDano(); // Leva dano se cruzar o raio
      }
    }
    if (nl.y > height) navesLaser.remove(i);
  }
  
  for (int i = serpentes.size() - 1; i >= 0; i--) {
    SegmentoSerpente serp = serpentes.get(i);
    serp.atualizar(); serp.desenhar();
    if (invencivelFrames == 0 && colisaoNave(x, y, larguraNave, alturaNave, serp.x, serp.y, serp.tamanho, serp.tamanho)) {
      receberDano(); serpentes.remove(i); continue;
    }
    if (serp.y > height) serpentes.remove(i);
  }

  for (int i = lasersInimigos.size() - 1; i >= 0; i--) {
    LaserInimigo li = lasersInimigos.get(i);
    li.atualizar(); li.desenhar();
    if (invencivelFrames == 0 && colisaoNave(x, y, larguraNave, alturaNave, li.x, li.y, 8, 25)) {
      receberDano(); lasersInimigos.remove(i); continue;
    }
    if (li.y > height) lasersInimigos.remove(i);
  }

  if (vidas <= 0) estadoJogo = 3; 
}

// ==========================================
// FUNÇÕES DE GERENCIAMENTO DE SPAWN
// ==========================================

void gerenciarSpawn() {
  if (frameCount >= proximoSpawnFrame) {
    
    // 1. Decide QUEM vai nascer baseando-se nos Desbloqueios Forçados
    if (forcarNaveLaser) {
      spawnNaveLaser(); forcarNaveLaser = false;
    }
    else if (forcarSerpente) {
      spawnSerpente(); forcarSerpente = false;
    } 
    else if (forcarNave) {
      spawnNave(); forcarNave = false;
    } 
    else {
      // Sorteio normal
      float sorteio = random(100);
      
      if (navesLaserDesbloqueadas) {
        if (sorteio < 35) spawnBarricada();
        else if (sorteio < 65) spawnNave();
        else if (sorteio < 85) spawnSerpente();
        else spawnNaveLaser(); // 15% de chance
      }
      else if (serpentesDesbloqueadas) {
        if (sorteio < 40) spawnBarricada();
        else if (sorteio < 80) spawnNave();
        else spawnSerpente(); 
      } 
      else if (navesDesbloqueadas) {
        if (sorteio < 50) spawnBarricada();
        else spawnNave();
      } 
      else {
        spawnBarricada(); 
      }
    }
    
    // 2. Define o tempo para o PRÓXIMO inimigo
    int tempoEspera = (int)(random(60, 180) / dificuldade);
    proximoSpawnFrame = frameCount + tempoEspera;
  }
}

void spawnBarricada() {
  obstaculos.add(new Obstaculo(random(limiteEsq + 20, limiteDir - 180), -100));
}

void spawnNave() {
  inimigos.add(new InimigoAtirador(random(limiteEsq + 50, limiteDir - 130), -100));
}

void spawnSerpente() {
  float startX = width / 2; 
  for (int i = 0; i < 15; i++) {
    boolean cabeca = (i == 0); 
    serpentes.add(new SegmentoSerpente(startX, -100 - (i * 25), i * 0.2, cabeca));
  }
}

void spawnNaveLaser() {
  // Sorteia 0 (Esquerda apontando pra Direita) ou 1 (Direita apontando pra Esquerda)
  int ladoSorteado = (int)random(2);
  navesLaser.add(new InimigoLaserContinuo(-150, ladoSorteado));
}


// ===== SISTEMAS DE FÍSICA =====
void receberDano() { vidas--; invencivelFrames = 60; }

boolean colisaoNave(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  float padding = 15; 
  return x1 + padding < x2 + w2 && x1 + w1 - padding > x2 && y1 + padding < y2 + h2 && y1 + h1 - padding > y2;
}

boolean colisaoTiro(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  float margem = 10; 
  return x1 - margem < x2 + w2 && x1 + w1 + margem > x2 && y1 < y2 + h2 && y1 + h1 > y2;
}


// ===== CONTROLES E TELAS =====
void exibirTelaGameOver() {
  fill(0, 15); rect(0, 0, width, height); 
  fill(255, 50, 50); textAlign(CENTER, CENTER);
  textSize(80); text("GAME OVER", width/2, height/2 - 50);
  fill(255); textSize(40); text("SCORE FINAL: " + nf(pontuacao, 7), width/2, height/2 + 20);
  fill(200); textSize(24); text("Pressione 'R' para reiniciar", width/2, height/2 + 80);
}

void keyPressed() {
  if (keyCode == UP || key == 'w' || key == 'W') up = true;
  if (keyCode == DOWN || key == 's' || key == 'S') down = true;
  if (keyCode == LEFT || key == 'a' || key == 'A') left = true;
  if (keyCode == RIGHT || key == 'd' || key == 'D') right = true;
  if (key == 'x' || key == 'X') atirando = true;
  
  if ((key == 'r' || key == 'R') && estadoJogo == 3) {
    estadoJogo = 1; framesContagem = 0; framesJogados = 0;
    vidas = 5; pontuacao = 0; invencivelFrames = 0; dificuldade = 1.0;
    
    proximoSpawnFrame = 0;
    navesDesbloqueadas = false;
    serpentesDesbloqueadas = false;
    navesLaserDesbloqueadas = false;
    forcarNave = false;
    forcarSerpente = false;
    forcarNaveLaser = false;
    
    obstaculos.clear(); inimigos.clear(); serpentes.clear(); navesLaser.clear(); lasers.clear(); lasersInimigos.clear();
    resetPosicaoNave();
  }
}

void keyReleased() {
  if (keyCode == UP || key == 'w' || key == 'W') up = false;
  if (keyCode == DOWN || key == 's' || key == 'S') down = false;
  if (keyCode == LEFT || key == 'a' || key == 'A') left = false;
  if (keyCode == RIGHT || key == 'd' || key == 'D') right = false;
  if (key == 'x' || key == 'X') atirando = false;
}

// ===== CLASSES DE OBJETOS =====

class Laser {
  float x, y; float velocidade = 20; 
  Laser(float startX, float startY) { x = startX; y = startY; }
  void atualizar() { y -= velocidade; }
  void desenhar() { fill(0, 255, 255); noStroke(); rect(x, y, 6, 25); }
}

class LaserInimigo {
  float x, y; float velocidade = 7; 
  LaserInimigo(float startX, float startY) { x = startX; y = startY; }
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { fill(255, 50, 50); noStroke(); rect(x, y, 8, 25); }
}

class Obstaculo {
  float x, y; float velocidade = 2.5; float largura = 160; float altura = 65; int hp = 3;
  Obstaculo(float startX, float startY) { x = startX; y = startY; }
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { image(imgBarricada, x, y, largura, altura); }
}

class InimigoAtirador {
  float x, y; float velocidade = 1.8; float tamanho = 90; int frameUltimoTiro;
  InimigoAtirador(float startX, float startY) { x = startX; y = startY; frameUltimoTiro = frameCount; }
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { image(imgSpaceShooter, x, y, tamanho, tamanho); }
  void atirar() {
    int intervaloTiroAtual = max(50, (int)(120 / dificuldade));
    if (frameCount - frameUltimoTiro >= intervaloTiroAtual) {
      lasersInimigos.add(new LaserInimigo(x + tamanho/2 - 4, y + tamanho)); frameUltimoTiro = frameCount;
    }
  }
}

class SegmentoSerpente {
  float x, y, startX; float tamanho; float velocidade = 2.2; float angulo; float amplitude = 350; 
  boolean eCabeca; int hp = 2;
  
  SegmentoSerpente(float startX, float startY, float anguloInicial, boolean eCabeca) { 
    this.startX = startX; this.x = startX; this.y = startY; this.angulo = anguloInicial; this.eCabeca = eCabeca;
    this.tamanho = eCabeca ? 75 : 68; 
  }
  
  void atualizar() {
    y += velocidade * dificuldade;
    angulo += 0.02 * dificuldade; 
    x = startX + sin(angulo) * amplitude;
    x = constrain(x, limiteEsq, limiteDir - tamanho);
  }
  
  void desenhar() { 
    if (eCabeca) { image(imgSnakeHead, x, y, tamanho, tamanho); } 
    else { image(imgSnakeBody, x, y, tamanho, tamanho); }
  }
}

// ==========================================
// NOVO INIMIGO: NAVE COM LASER CONTÍNUO
// ==========================================
class InimigoLaserContinuo {
  float x, y;
  float velocidade = 1.5; // Desce bem devagar para dar tempo de desviar
  float tamanho = 110; // Um pouco maior e intimidadora
  int hp = 6; // Nave Tanque (6 Tiros para morrer)
  
  int lado; // 0 = Fica na esquerda (Atira pra direita) | 1 = Fica na direita (Atira pra esquerda)
  
  // Máquina de Estados: 0 = Carregando/Desligado (2s) | 1 = Atirando (3s)
  int estado = 0; 
  int timer; 
  
  InimigoLaserContinuo(float startY, int ladoSorteado) {
    this.y = startY;
    this.lado = ladoSorteado;
    
    if (lado == 0) {
      this.x = limiteEsq; // Nasce colado na parede esquerda
    } else {
      this.x = limiteDir - tamanho; // Nasce colado na parede direita
    }
    
    this.timer = 120; // Começa desligado (2 segundos) para não matar injustamente no spawn
  }
  
  void atualizar() {
    y += velocidade * dificuldade;
    
    // Controle do Cronômetro do Laser
    timer--;
    if (timer <= 0) {
      if (estado == 0) {
        estado = 1; // Liga o laser
        timer = 60; // Fica ligado por 1 segundos (60 frames)
      } else {
        estado = 0; // Desliga o laser
        timer = 60; // Fica desligado por 1 segundos (60 frames)
      }
    }
  }
  
  void desenhar() {
    // 1. DESENHA O RAIO LASER (Se estiver ligado)
    if (estado == 1) {
      noStroke();
      fill(200, 0, 255, random(150, 255)); // Roxo neon com efeito de piscar (flicker) aleatório
      
      if (lado == 0) {
        // Laser vai da nave até a borda direita
        rect(x + tamanho, y + tamanho/2 - 15, limiteDir - (x + tamanho), 30);
        // Núcleo branco central do laser para dar brilho
        fill(255, random(200, 255));
        rect(x + tamanho, y + tamanho/2 - 5, limiteDir - (x + tamanho), 10);
      } else {
        // Laser vai da borda esquerda até a nave
        rect(limiteEsq, y + tamanho/2 - 15, x - limiteEsq, 30);
        fill(255, random(200, 255));
        rect(limiteEsq, y + tamanho/2 - 5, x - limiteEsq, 10);
      }
    }
    
    // 2. DESENHA A NAVE ROTACIONADA
    pushMatrix();
    // Move o eixo central de rotação para o meio da nave
    translate(x + tamanho/2, y + tamanho/2);
    
    if (lado == 0) {
      rotate(HALF_PI); // Rotaciona 90 graus para a direita
    } else {
      rotate(-HALF_PI); // Rotaciona 270 graus para a esquerda
    }
    
    // Desenha a imagem baseada no novo centro rotacionado
    image(imgSpaceLaser, -tamanho/2, -tamanho/2, tamanho, tamanho);
    popMatrix(); // Restaura o eixo normal da tela
  }
}
