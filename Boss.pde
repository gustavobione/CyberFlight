// ===== FLUXO DA BATALHA =====
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
    fill(255, 0, 0, 80); rect(0, 0, width, height); fill(255, 0, 0); textSize(70); textAlign(CENTER, CENTER); text("WARNING: MAINFRAME INBOUND", width/2, height/2);
  }
}

// ===== CLASSE MOTHERSHIP =====
class MothershipBoss {
  float x, y, velocidade = 1.0, largura = (width * 0.78 - width * 0.22) * 0.7, altura = 300; int timerAtaque, padraoAtaque = 0, hitTimer = 0; 
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
