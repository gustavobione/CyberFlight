// ===== GERENCIADOR DE SPAWN =====
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

// ===== ATUALIZADOR GERAL =====
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
      if (colisaoTiro(l.x, l.y, 6, 25, m.x, m.y, m.tamanho, m.tamanho)) { lasers.remove(i); laserRemovido = true; pontuacao += 150; if (somExplosao != null) somExplosao.play(); m.dispararEstrela(); minas.remove(j); break; }
    } if (laserRemovido) continue;
    for (int j = inimigos.size() - 1; j >= 0; j--) { InimigoAtirador in = inimigos.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, in.x, in.y, in.tamanho, in.tamanho)) { lasers.remove(i); laserRemovido = true; in.hp--; in.hitTimer = 3; if (in.hp <= 0) { inimigos.remove(j); pontuacao += 200; spawnPowerUpChance(in.x, in.y); if (somExplosao != null) somExplosao.play(); criarParticulas(in.x + in.tamanho/2, in.y + in.tamanho/2, 15, color(100, 200, 255)); } break; }
    } if (laserRemovido) continue;
    for (int j = kamikazes.size() - 1; j >= 0; j--) { InimigoKamikaze k = kamikazes.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, k.x, k.y, k.tamanho_world_w, k.tamanho_world_h)) { lasers.remove(i); laserRemovido = true; kamikazes.remove(j); pontuacao += 150; spawnPowerUpChance(k.x, k.y); if (somExplosao != null) somExplosao.play(); criarParticulas(k.x + k.tamanho_world_w/2, k.y + k.tamanho_world_h/2, 20, color(255, 100, 0)); break; }
    } if (laserRemovido) continue;
    for (int j = navesLaser.size() - 1; j >= 0; j--) { InimigoLaserContinuo nl = navesLaser.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, nl.x, nl.y, nl.tamanho, nl.tamanho)) { lasers.remove(i); laserRemovido = true; nl.hp--; nl.hitTimer = 3; if (nl.hp <= 0) { navesLaser.remove(j); pontuacao += 300; spawnPowerUpChance(nl.x, nl.y); if (somExplosao != null) somExplosao.play(); criarParticulas(nl.x + nl.tamanho/2, nl.y + nl.tamanho/2, 15, color(255, 50, 255)); } break; }
    } if (laserRemovido) continue;
    for (int j = serpentes.size() - 1; j >= 0; j--) { SegmentoSerpente serp = serpentes.get(j);
      if (colisaoTiro(l.x, l.y, 6, 25, serp.x, serp.y, serp.tamanho, serp.tamanho)) { lasers.remove(i); laserRemovido = true; serp.hp--; serp.hitTimer = 3; if(serp.hp <= 0) { serpentes.remove(j); pontuacao += 150; spawnPowerUpChance(serp.x, serp.y); if (somExplosao != null) somExplosao.play(); criarParticulas(serp.x + serp.tamanho/2, serp.y + serp.tamanho/2, 15, color(50, 255, 50)); } break; }
    } if (laserRemovido) continue;
    
    if (estadoJogo == ESTADO_BOSS && oBoss.y >= 80 && colisaoTiro(l.x, l.y, 6, 25, oBoss.x, oBoss.y, oBoss.largura, oBoss.altura)) {
      lasers.remove(i); laserRemovido = true; bossHP--; oBoss.hitTimer = 3; if (bossHP <= 0 && somExplosaoBoss != null) somExplosaoBoss.play(); break;
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
    especialOnda.atualizar(); especialOnda.desenhar(); destruirOndaEMP(obstaculos); destruirOndaEMP(minas); destruirOndaEMP(lasersInimigos);
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
      receberDano(); if (hpNaveTomaDano) { lista.remove(i); } else if (obj instanceof MinaMagnetica) { MinaMagnetica m = (MinaMagnetica)obj; m.dispararEstrela(); lista.remove(i); }
    }
    if (enemyY > height) lista.remove(i);
  }
}

// ===== BARRICADA =====
class Obstaculo {
  float x, y, velocidade = 2.5, largura = 160, altura = 65; int hp = 3, hitTimer = 0;
  Obstaculo(float startX, float startY) { x = startX; y = startY; } void atualizar() { y += velocidade * dificuldade; } 
  void desenhar() { image(imgBarricada, x, y, largura, altura); if (hitTimer > 0) { blendMode(ADD); tint(255, 150); image(imgBarricada, x, y, largura, altura); blendMode(BLEND); noTint(); hitTimer--; } }
}

// ===== MINA MAGNÉTICA =====
class MinaMagnetica {
  float x, y, velocidade = 1.2, tamanho = 85; int hp = 1; MinaMagnetica(float startX, float startY) { this.x = startX; this.y = startY; }
  void atualizar() { y += velocidade * dificuldade; } void desenhar() { image(imgMinaMagnetica, x, y, tamanho, tamanho); }
  void dispararEstrela() { shakeTimer = 10; float v = 5 * dificuldade; lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, 0, -v)); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, v/sqrt(2), -v/sqrt(2))); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, v, 0)); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, v/sqrt(2), v/sqrt(2))); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, 0, v)); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, -v/sqrt(2), v/sqrt(2))); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, -v, 0)); lasersInimigos.add(new LaserInimigoSimples(x + tamanho/2, y + tamanho/2, -v/sqrt(2), -v/sqrt(2))); }
}

// ===== NAVE ATIRADORA E DRONES =====
class InimigoAtirador {
  float x, y, velocidade = 1.8, tamanho = 90; int frameUltimoTiro, hp = 2, hitTimer = 0; 
  InimigoAtirador(float startX, float startY) { x = startX; y = startY; frameUltimoTiro = frameCount; }
  InimigoAtirador(float startX, float startY, float v) { x = startX; y = startY; frameUltimoTiro = frameCount; velocidade=v; tamanho=70; hp=1; } 
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { image(imgSpaceShooter, x, y, tamanho, tamanho); if (hitTimer > 0) { blendMode(ADD); tint(255, 150); image(imgSpaceShooter, x, y, tamanho, tamanho); blendMode(BLEND); noTint(); hitTimer--; } }
  void atirar() { int intTiro = max(50, (int)(120 / dificuldade)); if (frameCount - frameUltimoTiro >= intTiro) { lasersInimigos.add(new LaserInimigo(x + tamanho/2 - 4, y + tamanho)); if(somLaserInimigo != null) somLaserInimigo.play(); frameUltimoTiro = frameCount; } }
}

// ===== KAMIKAZE =====
class InimigoKamikaze {
  float x, y, velocidade = 5.0, tamanho_local_w = 50, tamanho_local_h = 120, tamanho_world_w, tamanho_world_h;
  InimigoKamikaze(float startX, float startY) { this.x = startX; this.y = startY; this.tamanho_world_w = tamanho_local_w; this.tamanho_world_h = tamanho_local_h; }
  void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { pushMatrix(); translate(x + tamanho_world_w/2, y + tamanho_world_h/2); rotate(HALF_PI); image(imgKamikaze, -tamanho_local_h/2, -tamanho_local_w/2, tamanho_local_h, tamanho_local_w); popMatrix(); }
}

// ===== SERPENTE =====
class SegmentoSerpente {
  float x, y, startX, tamanho, velocidade = 2.2, angulo, amplitude = 350; boolean eCabeca; int hp = 1, hitTimer = 0; 
  SegmentoSerpente(float startX, float startY, float aInicial, boolean cabeca) { this.startX = startX; this.x = startX; this.y = startY; this.angulo = aInicial; this.eCabeca = cabeca; this.tamanho = cabeca ? 75 : 68; }
  void atualizar() { y += velocidade * dificuldade; angulo += 0.02 * dificuldade; x = startX + sin(angulo) * amplitude; x = constrain(x, limiteEsq, limiteDir - tamanho); }
  void desenhar() { PImage img = eCabeca ? imgSnakeHead : imgSnakeBody; image(img, x, y, tamanho, tamanho); if (hitTimer > 0) { blendMode(ADD); tint(255, 150); image(img, x, y, tamanho, tamanho); blendMode(BLEND); noTint(); hitTimer--; } }
}

// ===== NAVE LASER CONTÍNUO =====
class InimigoLaserContinuo {
  float x, y, velocidade = 1.5, tamanho = 110; int hp = 6, lado, estado = 0, timer = 60, hitTimer = 0; 
  InimigoLaserContinuo(float startY, int ladoSorteado) { this.y = startY; this.lado = ladoSorteado; this.x = (lado == 0) ? limiteEsq : limiteDir - tamanho; }
  void atualizar() { y += velocidade * dificuldade; timer--; if (timer <= 0) { estado = (estado == 0) ? 1 : 0; timer = 60; } }
  void desenhar() {
    if (estado == 1) { noStroke(); fill(200, 0, 255, random(150, 255)); if (lado == 0) { rect(x + tamanho, y + tamanho/2 - 15, limiteDir - (x + tamanho), 30); fill(255, random(200, 255)); rect(x + tamanho, y + tamanho/2 - 5, limiteDir - (x + tamanho), 10); } else { rect(limiteEsq, y + tamanho/2 - 15, x - limiteEsq, 30); fill(255, random(200, 255)); rect(limiteEsq, y + tamanho/2 - 5, x - limiteEsq, 10); } }
    pushMatrix(); translate(x + tamanho/2, y + tamanho/2); if (lado == 0) rotate(HALF_PI); else rotate(-HALF_PI); image(imgSpaceLaser, -tamanho/2, -tamanho/2, tamanho, tamanho); if (hitTimer > 0) { blendMode(ADD); tint(255, 150); image(imgSpaceLaser, -tamanho/2, -tamanho/2, tamanho, tamanho); blendMode(BLEND); noTint(); hitTimer--; } popMatrix(); 
  }
}
void checarColisaoLaserContinuo(InimigoLaserContinuo nl) { if (nl.estado == 1 && invencivelFrames == 0) { float hitX = (nl.lado == 0) ? nl.x + nl.tamanho : limiteEsq; float hitW = (nl.lado == 0) ? limiteDir - (nl.x + nl.tamanho) : nl.x - limiteEsq; float hitY = nl.y + nl.tamanho/2 - 15; float hitH = 30; if (colisaoNave(x, y, larguraNave, alturaNave, hitX, hitY, hitW, hitH)) { receberDano(); } } }

// ===== PROJÉTEIS INIMIGOS =====
class LaserInimigo {
  float x, y, velocidade = 7; LaserInimigo(float startX, float startY) { x = startX; y = startY; } void atualizar() { y += velocidade * dificuldade; }
  void desenhar() { if(imgLaserInimigo != null) image(imgLaserInimigo, x-10, y-10, 20, 45); else { fill(255, 50, 50); noStroke(); rect(x, y, 8, 25); } }
}
class LaserInimigoSimples extends LaserInimigo { float vx, vy; LaserInimigoSimples(float x, float y, float vx, float vy) { super(x, y); this.vx = vx; this.vy = vy; } void atualizar() { x += vx; y += vy; } void desenhar() { fill(255, 100, 100); noStroke(); ellipse(x, y, 15, 15); } }
