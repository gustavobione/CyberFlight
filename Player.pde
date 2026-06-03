// ===== CONTROLES E MOVIMENTO =====
void resetPosicaoNave() { x = width / 2 - (larguraNave / 2); y = height - alturaNave - 20; vx = 0; vy = 0; }

void gerenciarMovimentoJogador() {
  if (up) vy -= aceleracao; if (down) vy += aceleracao; if (left) vx -= aceleracao; if (right) vx += aceleracao;
  vx *= atrito; vy *= atrito; x += vx; y += vy;
  x = constrain(x, limiteEsq, limiteDir - larguraNave); y = constrain(y, 0, height - alturaNave);
  if (invencivelFrames > 0) { invencivelFrames--; spriteAtual = (invencivelFrames % 8 < 4) ? imgPlayerBroken : imgPlayer;
  } else { if (up) spriteAtual = imgPlayerUp; else if (down) spriteAtual = imgDown; else if (left) spriteAtual = imgLeft; else if (right) spriteAtual = imgRight; else spriteAtual = imgPlayer; }
  image(spriteAtual, x, y);
}

// ===== TIRO E ARMAS COM VFX =====
class Laser {
  float x, y; float velocidade = 20; 
  Laser(float startX, float startY) { x = startX; y = startY; } void atualizar() { y -= velocidade; }
  void desenhar() { 
    blendMode(ADD); // VFX Luz Neon
    if(imgLaserPlayer != null) image(imgLaserPlayer, x-10, y-10, 20, 45); 
    else { fill(0, 255, 255); noStroke(); rect(x, y, 6, 25); } 
    blendMode(BLEND);
  }
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

// ===== SISTEMA DE DANO E COLISÃO =====
void receberDano() { 
  vidas--; invencivelFrames = 60; shakeTimer = 15; 
  if (somDanoNave != null) somDanoNave.play(); 
  if (vidas <= 0) { estadoJogo = ESTADO_GAMEOVER; }
}

boolean colisaoNave(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) { return x1 + 15 < x2 + w2 && x1 + w1 - 15 > x2 && y1 + 15 < y2 + h2 && y1 + h1 - 15 > y2; }
boolean colisaoTiro(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) { return x1 - 10 < x2 + w2 && x1 + w1 + 10 > x2 && y1 < y2 + h2 && y1 + h1 > y2; }
