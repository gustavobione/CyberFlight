PImage imgNave, imgNaveUp, imgDown, imgRight, imgLeft, imgNaveBroken;
PImage imgVidaNormal, imgVidaQuebrada;
PImage spriteAtual; 

int larguraNave = 120; 
int alturaNave = 120;

float x, y;
float vx, vy; 
float aceleracao = 1.8; 
float atrito = 0.85; 

boolean up, down, left, right;

// ===== SISTEMA DE ESTADOS E DIFICULDADE =====
int estadoJogo = 1; 
int framesContagem = 0;
int framesJogados = 0;
float dificuldade = 1.0;
int pontuacao = 0;
int vidas = 5;
int invencivelFrames = 0; 

// ===== LISTAS DE OBJETOS NA TELA =====
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<LaserInimigo> lasersInimigos = new ArrayList<LaserInimigo>();
ArrayList<Obstaculo> obstaculos = new ArrayList<Obstaculo>(); 
ArrayList<Terreno> terrenos = new ArrayList<Terreno>(); // Novo: Margens e Ilhas
ArrayList<InimigoAtirador> inimigos = new ArrayList<InimigoAtirador>();
ArrayList<SegmentoSerpente> serpentes = new ArrayList<SegmentoSerpente>(); // Novo: Centopeia

boolean atirando = false;
int intervaloTiro = 12;      
int ultimoDisparoFrame = 0;  

void setup() {
  fullScreen();
  
  imgNave = loadImage("nave.png");
  imgNaveUp = loadImage("naveUp.png");
  imgDown = loadImage("naveDown.png");
  imgRight = loadImage("naveRight.png");
  imgLeft = loadImage("naveLeft.png");
  imgNaveBroken = loadImage("nave-Broken.png"); 
  
  imgNave.resize(larguraNave, alturaNave);
  imgNaveUp.resize(larguraNave, alturaNave);
  imgDown.resize(larguraNave, alturaNave);
  imgRight.resize(larguraNave, alturaNave);
  imgLeft.resize(larguraNave, alturaNave);
  imgNaveBroken.resize(larguraNave, alturaNave);
  
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
  background(15, 15, 25); 

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
  x = constrain(x, 0, width - larguraNave);
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
  // Formata a pontuação para ter sempre 7 dígitos (ex: 0000100)
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
      if (framesContagem > 240) estadoJogo = 2; 
    }
    return; 
  }

  // ===== ESTADO 2: JOGO RODANDO =====
  framesJogados++;
  
  // AUMENTO GRADATIVO SUAVE (Sobe 1 nível a cada 30 segundos)
  dificuldade = 1.0 + (framesJogados / 1800.0);
  
  // TIRO DO JOGADOR
  if (atirando && (frameCount - ultimoDisparoFrame >= intervaloTiro)) {
    lasers.add(new Laser(x + larguraNave/2 - 3, y)); 
    ultimoDisparoFrame = frameCount; 
  }

  // ATUALIZA TIROS E COLISÕES DOS TIROS
  for (int i = lasers.size() - 1; i >= 0; i--) {
    Laser l = lasers.get(i);
    l.atualizar(); l.desenhar();
    boolean laserRemovido = false;
    
    // Tiro bate no Terreno (Indestrutível)
    for (Terreno t : terrenos) {
      if (checarColisao(l.x, l.y, 6, 25, t.x, t.y, t.w, t.h)) {
        lasers.remove(i); laserRemovido = true; break;
      }
    }
    if (laserRemovido) continue;

    // Tiro bate na Barricada (HP: 3)
    for (int j = obstaculos.size() - 1; j >= 0; j--) {
      Obstaculo obs = obstaculos.get(j);
      if (checarColisao(l.x, l.y, 6, 25, obs.x, obs.y, obs.tamanho, obs.tamanho)) {
        lasers.remove(i); laserRemovido = true;
        obs.hp--;
        if (obs.hp <= 0) { obstaculos.remove(j); pontuacao += 100; }
        break;
      }
    }
    if (laserRemovido) continue;
    
    // Tiro bate Inimigo Atirador
    for (int j = inimigos.size() - 1; j >= 0; j--) {
      InimigoAtirador in = inimigos.get(j);
      if (checarColisao(l.x, l.y, 6, 25, in.x, in.y, in.largura, in.altura)) {
        lasers.remove(i); laserRemovido = true;
        inimigos.remove(j); pontuacao += 200;
        break;
      }
    }
    if (laserRemovido) continue;
    
    // Tiro bate em UM segmento da Serpente
    for (int j = serpentes.size() - 1; j >= 0; j--) {
      SegmentoSerpente serp = serpentes.get(j);
      if (checarColisao(l.x, l.y, 6, 25, serp.x, serp.y, serp.tamanho, serp.tamanho)) {
        lasers.remove(i); laserRemovido = true;
        serpentes.remove(j); pontuacao += 150; 
        break;
      }
    }
    
    if (!laserRemovido && l.y < 0) lasers.remove(i);
  }

  // ===== SISTEMA DE SPAWN PROCEDURAL =====
  
  // 1. GERAÇÃO DO TERRENO (As margens do "Rio")
  if (framesJogados % 20 == 0) {
    // Cria um efeito de onda nas paredes usando seno e cosseno
    float larguraEsq = 200 + sin(framesJogados * 0.02) * 150;
    float larguraDir = 200 + cos(framesJogados * 0.02) * 150;
    
    terrenos.add(new Terreno(0, -100, larguraEsq, 120)); // Parede Esquerda
    terrenos.add(new Terreno(width - larguraDir, -100, larguraDir, 120)); // Parede Direita
  }
  
  // 2. BIFURCAÇÃO (Ilhas no meio da tela)
  if (framesJogados % 400 == 0) {
    terrenos.add(new Terreno(width/2 - 150, -300, 300, 600)); 
  }
  
  // 3. GERAÇÃO DE INIMIGOS
  int spawnRateBarricada = max(60, (int)(120 / dificuldade));
  int spawnRateAtirador = max(90, (int)(200 / dificuldade));
  int spawnRateSerpente = max(240, (int)(400 / dificuldade)); 

  if (framesJogados % spawnRateBarricada == 0) obstaculos.add(new Obstaculo(random(300, width - 300), -100));
  if (framesJogados % spawnRateAtirador == 0) inimigos.add(new InimigoAtirador(random(300, width - 300), -100));
  
  // Gera a Serpente (vários segmentos conectados em cadeia)
  if (framesJogados > 300 && framesJogados % spawnRateSerpente == 0) { 
    float startX = random(400, width - 400);
    for (int i = 0; i < 8; i++) {
      // Cria 8 bolas. O Y tem um espaço de 40 pixels entre elas. O multiplicador de ângulo (i * 0.4) cria o zig-zag
      serpentes.add(new SegmentoSerpente(startX, -100 - (i * 40), i * 0.4));
    }
  }

  // ===== ATUALIZAÇÃO E COLISÕES DOS INIMIGOS COM A NAVE =====
  
  // Terrenos (Margens e Ilhas)
  for (int i = terrenos.size() - 1; i >= 0; i--) {
    Terreno t = terrenos.get(i);
    t.atualizar(); t.desenhar();
    if (invencivelFrames == 0 && checarColisao(x, y, larguraNave, alturaNave, t.x, t.y, t.w, t.h)) receberDano();
    if (t.y > height) terrenos.remove(i);
  }

  for (int i = obstaculos.size() - 1; i >= 0; i--) {
    Obstaculo obs = obstaculos.get(i);
    obs.atualizar(); obs.desenhar();
    if (invencivelFrames == 0 && checarColisao(x, y, larguraNave, alturaNave, obs.x, obs.y, obs.tamanho, obs.tamanho)) {
      receberDano(); obstaculos.remove(i); continue;
    }
    if (obs.y > height) obstaculos.remove(i);
  }

  for (int i = inimigos.size() - 1; i >= 0; i--) {
    InimigoAtirador in = inimigos.get(i);
    in.atualizar(); in.desenhar(); in.atirar(); 
    if (invencivelFrames == 0 && checarColisao(x, y, larguraNave, alturaNave, in.x, in.y, in.largura, in.altura)) {
      receberDano(); inimigos.remove(i); continue;
    }
    if (in.y > height) inimigos.remove(i);
  }
  
  // Segmentos da Serpente
  for (int i = serpentes.size() - 1; i >= 0; i--) {
    SegmentoSerpente serp = serpentes.get(i);
    serp.atualizar(); serp.desenhar();
    if (invencivelFrames == 0 && checarColisao(x, y, larguraNave, alturaNave, serp.x, serp.y, serp.tamanho, serp.tamanho)) {
      receberDano(); serpentes.remove(i); continue;
    }
    if (serp.y > height) serpentes.remove(i);
  }

  for (int i = lasersInimigos.size() - 1; i >= 0; i--) {
    LaserInimigo li = lasersInimigos.get(i);
    li.atualizar(); li.desenhar();
    if (invencivelFrames == 0 && checarColisao(x, y, larguraNave, alturaNave, li.x, li.y, 8, 25)) {
      receberDano(); lasersInimigos.remove(i); continue;
    }
    if (li.y > height) lasersInimigos.remove(i);
  }

  if (vidas <= 0) estadoJogo = 3; 
}

void receberDano() { vidas--; invencivelFrames = 60; }

boolean checarColisao(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  float padding = 15; 
  return x1 + padding < x2 + w2 && x1 + w1 - padding > x2 && y1 + padding < y2 + h2 && y1 + h1 - padding > y2;
}

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
    obstaculos.clear(); terrenos.clear(); inimigos.clear(); serpentes.clear(); lasers.clear(); lasersInimigos.clear();
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
  float x, y; float velocidade = 12; 
  LaserInimigo(float startX, float startY) { x = startX; y = startY; }
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { fill(255, 50, 50); noStroke(); rect(x, y, 8, 25); }
}

class Terreno {
  float x, y, w, h; float velocidade = 5;
  Terreno(float startX, float startY, float w, float h) { this.x = startX; this.y = startY; this.w = w; this.h = h; }
  void atualizar() { y += velocidade * (dificuldade * 0.8); } // Terreno desce um pouco mais devagar
  void desenhar() { 
    fill(20, 40, 60); stroke(0, 255, 255); strokeWeight(3); // Cyberpunk neon look
    rect(x, y, w, h); 
  }
}

class Obstaculo {
  float x, y; float velocidade = 6; float tamanho = 80; int hp = 3;
  Obstaculo(float startX, float startY) { x = startX; y = startY; }
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() {
    fill(255, 150, 0); noStroke(); rect(x, y, tamanho, tamanho);
    fill(0); textSize(20); textAlign(CENTER, CENTER); text(hp, x + tamanho/2, y + tamanho/2); 
  }
}

class InimigoAtirador {
  float x, y; float velocidade = 4; float largura = 90; float altura = 90; int frameUltimoTiro;
  InimigoAtirador(float startX, float startY) { x = startX; y = startY; frameUltimoTiro = frameCount; }
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { fill(200, 50, 150); noStroke(); triangle(x, y, x + largura, y, x + largura/2, y + altura); }
  void atirar() {
    int intervaloTiroAtual = max(40, (int)(100 / dificuldade));
    if (frameCount - frameUltimoTiro >= intervaloTiroAtual) {
      lasersInimigos.add(new LaserInimigo(x + largura/2 - 4, y + altura)); frameUltimoTiro = frameCount;
    }
  }
}

class SegmentoSerpente {
  float x, y, startX; float tamanho = 50;
  float velocidade = 5; float angulo; float amplitude = 180;
  
  SegmentoSerpente(float startX, float startY, float anguloInicial) { 
    this.startX = startX; this.x = startX; this.y = startY; this.angulo = anguloInicial; 
  }
  void atualizar() {
    y += velocidade * dificuldade;
    angulo += 0.08 * dificuldade;
    x = startX + sin(angulo) * amplitude; // Ziguezague sincronizado
  }
  void desenhar() { fill(50, 255, 100); noStroke(); ellipse(x + tamanho/2, y + tamanho/2, tamanho, tamanho); }
}
