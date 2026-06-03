// ===== ARQUIVOS E HIGHSCORE =====
void carregarHighscore() { String[] linhas = loadStrings("highscore.txt"); if (linhas != null && linhas.length > 0) { highscore = int(linhas[0]); } }
void salvarHighscore() { if (pontuacao > highscore) { highscore = pontuacao; String[] lista = { str(highscore) }; saveStrings("data/highscore.txt", lista); } }

// ===== UTILITÁRIOS UI =====
void desenharBotaoMenu(String texto, float bX, float bY) {
  float bW = 350, bH = 70;
  boolean hover = mouseX > bX - bW/2 && mouseX < bX + bW/2 && mouseY > bY - bH/2 && mouseY < bY + bH/2;
  if (hover) { fill(0, 255, 255, 100); stroke(255); } else { fill(0, 100, 100, 150); stroke(0, 255, 255); }
  strokeWeight(3); rect(bX - bW/2, bY - bH/2, bW, bH, 10);
  
  textFont(fonteNormal); // Fonte padrão para o botão
  fill(255); textSize(30); textAlign(CENTER, CENTER); text(texto, bX, bY - 5);
}

boolean checarCliqueBotao(float bX, float bY) { return mouseX > bX - 175 && mouseX < bX + 175 && mouseY > bY - 35 && mouseY < bY + 35; }

// ===== MENU INICIAL =====
void exibirTelaLogin() {
  fill(0, 180); rect(0, 0, width, height);
  textFont(fonteTitulo); // FONTE EXTRA BOLD PARA O TÍTULO
  fill(0, 255, 255); textAlign(CENTER, CENTER); textSize(70); text("CYBERFLIGHT: DATA RUNNER", width/2, height/2 - 180);
  
  desenharBotaoMenu("JOGAR", width/2, height/2 - 30);
  desenharBotaoMenu("LEADERBOARD", width/2, height/2 + 60);
  desenharBotaoMenu("CRÉDITOS", width/2, height/2 + 150);
  desenharBotaoMenu("SAIR", width/2, height/2 + 240);
}

// ===== INSTRUÇÕES =====
void exibirTelaInstrucoes() {
  fill(0, 180); rect(0, 0, width, height); 
  
  textFont(fonteTitulo);
  fill(0, 255, 255); textAlign(CENTER, CENTER); textSize(50); text("MANUAL DO DATA RUNNER", width/2, 100);
  
  textFont(fonteNormal); // Volta para a fonte normal
  float centroEsq = width * 0.35, centroDir = width * 0.65;
  
  fill(255); textSize(30); text("CONTROLES", centroEsq, 220);
  textSize(20); textAlign(LEFT, CENTER); fill(200);
  text("W / A / S / D  ou  SETAS - Movimentar Nave", centroEsq - 250, 300);
  text("X - Disparar Laser Primário", centroEsq - 250, 370);
  text("ESPAÇO ou C - Ativar Pulso EMP", centroEsq - 250, 440);
  text("P ou ESC - Pausar o Sistema", centroEsq - 250, 510);
  
  textAlign(CENTER, CENTER); fill(255); textSize(30); text("ELEMENTOS", centroDir, 220);
  textAlign(LEFT, CENTER); textSize(20); fill(200);
  float imgX = centroDir - 200, textoX = centroDir - 130;
  
  image(imgPlayer, imgX, 280, 50, 50); text("Você. Sobreviva e faça Upload.", textoX, 305);
  image(imgBarricada, imgX, 360, 50, 50); text("Desvie ou Destrua Ameaças.", textoX, 385);
  
  fill(0, 100, 100, 150); stroke(0, 255, 255); strokeWeight(2); rect(imgX - 20, 450, 500, 160, 10);
  fill(0, 255, 255); textSize(18); text("COLETE DROPS (POWER-UPS)", imgX, 475);
  image(imgPowerUpVida, imgX, 500, 40, 40); fill(200); textSize(18); text("Restaura 1 Vida", textoX, 520);
  image(imgPowerUpEspecial, imgX, 550, 40, 40); text("Recarrega 1 Pulso EMP", textoX, 570);
  image(imgPowerUpTiro, imgX + 260, 500, 40, 40); text("Laser Duplo", imgX + 310, 520);
  
  desenharBotaoMenu("INICIAR HACKING", width/2, height - 120);
}

// ===== LEADERBOARD =====
void exibirTelaLeaderboard() {
  fill(0, 180); rect(0, 0, width, height);
  textFont(fonteTitulo);
  fill(0, 255, 255); textAlign(CENTER, CENTER); textSize(70); text("HALL OF FAME", width/2, height/2 - 150);
  
  textFont(fonteNormal);
  fill(255, 255, 0); textSize(50); text("MAIOR PONTUAÇÃO: " + nf(highscore, 7), width/2, height/2);
  desenharBotaoMenu("VOLTAR", width/2, height/2 + 150);
}

// ===== CRÉDITOS =====
void exibirTelaCreditos() {
  fill(0, 180); rect(0, 0, width, height);
  textFont(fonteTitulo);
  fill(0, 255, 255); textAlign(CENTER, CENTER); textSize(70); text("DESENVOLVEDORES", width/2, height/2 - 200);
  
  textFont(fonteNormal);
  fill(255); textSize(35);
  text("Gustavo Teixeira Bione", width/2, height/2 - 60);
  text("Thiago Lima Freire", width/2, height/2);
  text("Lucas Ferraz Valença Parente", width/2, height/2 + 60);
  desenharBotaoMenu("VOLTAR", width/2, height/2 + 200);
}

// ===== PAUSE =====
void exibirTelaPause() {
  if (telaPausada != null) image(telaPausada, 0, 0); 
  fill(0, 180); rect(0, 0, width, height); 
  textFont(fonteTitulo);
  fill(0, 255, 255); textAlign(CENTER, CENTER); textSize(80); text("PAUSADO", width/2, height/2 - 150);
  desenharBotaoMenu("RETOMAR", width/2, height/2); desenharBotaoMenu("DESISTIR", width/2, height/2 + 100);
}

// ===== HUD E EFEITOS =====
void desenharHUD() {
  textFont(fonteNormal);
  strokeWeight(2); stroke(0, 255, 255, 150); fill(0, 100); rect(20, 20, 320, 130, 8);
  fill(0, 255, 255); textSize(16); textAlign(LEFT, TOP); text("SYSTEM STATUS", 30, 25);
  for (int i = 0; i < 5; i++) { if (i < vidas) { tint(255); } else { tint(50, 150); } image(imgVidaNormal, 30 + (i * 50), 50); noTint(); }
  for (int i = 0; i < maxCargasEMP; i++) { if (i < cargasEMP) { tint(255); } else { tint(50, 150); } image(imgPowerUpEspecial, 30 + (i * 50), 100, 35, 35); noTint(); }
  fill(255); textSize(35); textAlign(RIGHT, TOP); text("SCORE: " + nf(pontuacao, 7), width - 30, 30);
  if (temTiroDuplo) {
    fill(0, 255, 255); textSize(20); textAlign(RIGHT, TOP); text("OVERCLOCK: " + nf(timerPowerUpTiro/60.0, 1, 1) + "s", width - 30, 80);
    fill(0, 100, 100); rect(width - 230, 110, 200, 10); fill(0, 255, 255); rect(width - 230, 110, map(timerPowerUpTiro, 0, 900, 0, 200), 10);
  }
  if (estadoJogo == ESTADO_BOSS) {
    fill(255, 0, 0, 100); rect(width/2 - 300, 20, 600, 25); fill(255, 0, 0); rect(width/2 - 300, 20, map(bossHP, 0, bossHPMax, 0, 600), 25);
    fill(255); textSize(20); textAlign(CENTER, CENTER); text("MAINFRAME CORE", width/2, 32);
  }
}

void aplicarShake() { if (shakeTimer > 0) { translate(random(-10, 10), random(-10, 10)); shakeTimer--; } }

class Particula {
  float x, y, vx, vy, tamanho; int vida, vidaMax; color cor;
  Particula(float startX, float startY, color c) { x = startX; y = startY; cor = c; vx = random(-6, 6); vy = random(-6, 6); tamanho = random(4, 12); vidaMax = (int)random(15, 30); vida = vidaMax; }
  void atualizar() { x += vx; y += vy; vida--; tamanho *= 0.95; }
  void desenhar() { noStroke(); fill(cor, map(vida, 0, vidaMax, 0, 255)); rect(x, y, tamanho, tamanho); }
}
void criarParticulas(float x, float y, int qtd, color cor) { for (int i = 0; i < qtd; i++) particulas.add(new Particula(x, y, cor)); }
void desenharParticulas() { for (int i = particulas.size() - 1; i >= 0; i--) { Particula p = particulas.get(i); p.atualizar(); p.desenhar(); if (p.vida <= 0) particulas.remove(i); } }

// ===== LOOPS GERAIS DO JOGO E TELAS FINAIS =====
void executarContagem() {
  framesContagem++; int segundosRestantes = 3 - (framesContagem / 60);
  textFont(fonteTitulo);
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
  
  pushMatrix(); aplicarShake(); atualizarObjetos(); desenharParticulas(); popMatrix();
  desenharHUD();
}

void exibirTelaGameOver() { 
  fill(0, 15); rect(0, 0, width, height); 
  textFont(fonteTitulo); fill(255, 50, 50); textAlign(CENTER, CENTER); textSize(80); text("SYSTEM FAILURE", width/2, height/2 - 50); 
  textFont(fonteNormal); fill(255); textSize(35); text("SCORE FINAL: " + nf(pontuacao, 7), width/2, height/2 + 20); 
  fill(200); textSize(20); text("Pressione 'R' para reiniciar ou 'M' para Menu", width/2, height/2 + 80); 
}

void exibirTelaVitoria() { 
  fill(0, 150); rect(0, 0, width, height); 
  textFont(fonteTitulo); fill(0, 255, 0); textAlign(CENTER, CENTER); textSize(80); text("HACKING CONCLUÍDO", width/2, height/2 - 50); 
  textFont(fonteNormal); fill(255); textSize(35); text("DADOS TRANSMITIDOS COM SUCESSO!", width/2, height/2 + 20); 
  fill(0, 255, 255); textSize(20); text("Pressione ENTER para voltar ao Menu", width/2, height/2 + 80); 
}

void executarAnimacaoVitoria() {
  oBoss.y += 4; pushMatrix(); translate(oBoss.x + oBoss.largura/2, oBoss.y + oBoss.altura/2);
  if(imgBossDefeated != null) { image(imgBossDefeated, -oBoss.largura/2, -oBoss.altura/2, oBoss.largura, oBoss.altura); } else { image(imgPlayerBroken, -oBoss.largura/2, -oBoss.altura/2, oBoss.largura, oBoss.altura); } popMatrix();
  if (oBoss.y > height) { x = lerp(x, (width/2) - (larguraNave/2), 0.05); y -= 8; image(imgPlayerUp, x, y); } else { image(imgPlayer, x, y); }
  if (y < -150) { salvarHighscore(); estadoJogo = ESTADO_VITORIA; }
}

// ===== POWER-UPS E EMP =====
class PowerUp {
  float x, y, velocidade = 3.0, tamanho = 50; int tipo; 
  PowerUp(float startX, float startY) { this.x = constrain(startX, limiteEsq + 50, limiteDir - 100); this.y = startY; float sorteio = random(100); if (sorteio < 40) tipo = 0; else if (sorteio < 70) tipo = 1; else tipo = 2; }
  void atualizar() { y += velocidade; x += sin(frameCount * 0.1) * 0.5; }
  void desenhar() { noStroke(); if (tipo == 0) fill(50, 255, 100, 50); else if (tipo == 1) fill(255, 255, 0, 50); else if (tipo == 2) fill(50, 100, 255, 50); ellipse(x + tamanho/2, y + tamanho/2, tamanho*1.5, tamanho*1.5); switch (tipo) { case 0: image(imgPowerUpVida, x, y, tamanho, tamanho); break; case 1: image(imgPowerUpEspecial, x, y, tamanho, tamanho); break; case 2: image(imgPowerUpTiro, x, y, tamanho, tamanho); break; } }
}

void aplicarPowerUp(PowerUp p) { if (somPowerUp != null) somPowerUp.play(); switch (p.tipo) { case 0: if (vidas < 5) vidas++; break; case 1: if (cargasEMP < maxCargasEMP) cargasEMP++; break; case 2: timerPowerUpTiro = 900; break; } }
void spawnPowerUpChance(float px, float py) { if (random(100) < 15) { powerups.add(new PowerUp(px, py)); } }

class OndaEMP {
  float x, y, raio = 0, raioMax = 500, velocidadeExpansao = 15; boolean finalizada = false;
  OndaEMP(float startX, float startY) { this.x = startX; this.y = startY; }
  void atualizar() { if (raio < raioMax) { raio += velocidadeExpansao; } else { finalizada = true; } }
  void desenhar() { noFill(); stroke(255, 255, 0, map(raio, 0, raioMax, 255, 0)); strokeWeight(15); ellipse(x, y, raio * 2, raio * 2); }
}

void destruirOndaEMP(ArrayList lista) {
  for (int i = lista.size() - 1; i >= 0; i--) { Object obj = lista.get(i); float objX, objY, objW, objH;
    if (obj instanceof Obstaculo) { Obstaculo obs = (Obstaculo)obj; objX=obs.x; objY=obs.y; objW=obs.largura; objH=obs.altura; } else if (obj instanceof MinaMagnetica) { MinaMagnetica m = (MinaMagnetica)obj; objX=m.x; objY=m.y; objW=m.tamanho; objH=m.tamanho; } else if (obj instanceof LaserInimigo) { LaserInimigo li = (LaserInimigo)obj; objX=li.x; objY=li.y; objW=8; objH=25; } else continue;
    if (colisaoOndaEMP(especialOnda.x, especialOnda.y, especialOnda.raio, objX, objY, objW, objH)) { if (obj instanceof MinaMagnetica) { ((MinaMagnetica)obj).dispararEstrela(); lista.remove(i); } else { lista.remove(i); if (obj instanceof Obstaculo) { pontuacao += 50; criarParticulas(objX + objW/2, objY + objH/2, 10, color(150)); } } }
  }
}
void darDanoOndaEMP(ArrayList lista, int dano) {
  for (int i = lista.size() - 1; i >= 0; i--) { Object obj = lista.get(i); float objX, objY, objW, objH;
    if (obj instanceof InimigoAtirador) { InimigoAtirador in = (InimigoAtirador)obj; objX=in.x; objY=in.y; objW=in.tamanho; objH=in.tamanho; } else if (obj instanceof InimigoKamikaze) { InimigoKamikaze k = (InimigoKamikaze)obj; objX=k.x; objY=k.y; objW=k.tamanho_world_w; objH=k.tamanho_world_h; } else if (obj instanceof InimigoLaserContinuo) { InimigoLaserContinuo nl = (InimigoLaserContinuo)obj; objX=nl.x; objY=nl.y; objW=nl.tamanho; objH=nl.tamanho; } else if (obj instanceof SegmentoSerpente) { SegmentoSerpente serp = (SegmentoSerpente)obj; objX=serp.x; objY=serp.y; objW=serp.tamanho; objH=serp.tamanho; } else continue;
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
