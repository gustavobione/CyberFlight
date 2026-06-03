// Variável para guardar posição inicial dos analógicos ao clicar para remapear
float[] sliderInicial;

// ===== CONFIGURAÇÃO DOS SLIDERS VISUAIS (CP5) =====
void configurarInterfaceConfiguracoes() {
  cp5.addSlider("volMusica")
     .setPosition(width/2 - 50, 180)
     .setSize(300, 40)
     .setRange(0.0, 1.0)
     .setValue(volMusica)
     .setLabel("VOLUME DA MUSICA")
     .setColorBackground(color(0, 45, 45))
     .setColorActive(color(0, 255, 255))
     .setColorForeground(color(0, 150, 150));
     
  cp5.getController("volMusica").getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(25);
  cp5.getController("volMusica").getValueLabel().setVisible(false);
     
  cp5.addSlider("volEfeitos")
     .setPosition(width/2 - 50, 250)
     .setSize(300, 40)
     .setRange(0.0, 1.0)
     .setValue(volEfeitos)
     .setLabel("VOLUME DOS EFEITOS (SFX)")
     .setColorBackground(color(0, 45, 45))
     .setColorActive(color(0, 255, 255))
     .setColorForeground(color(0, 150, 150));
     
  cp5.getController("volEfeitos").getCaptionLabel().align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER).setPaddingX(25);
  cp5.getController("volEfeitos").getValueLabel().setVisible(false);
     
  cp5.hide();
}

// ===== RENDERIZAÇÃO DA TELA DE OPÇÕES =====
void exibirTelaConfiguracoes() {
  fill(0, 220); rect(0, 0, width, height);
  
  volMusica = cp5.getController("volMusica").getValue();
  volEfeitos = cp5.getController("volEfeitos").getValue();
  atualizarVolumesGlobais();
  
  if (fonteTitulo != null) textFont(fonteTitulo);
  fill(0, 255, 255); textAlign(CENTER, TOP); textSize(50);
  text("CONFIGURAÇÕES DE SISTEMA", width/2, 40);
  
  if (fonteNormal != null) textFont(fonteNormal);
  fill(255); textSize(20); textAlign(LEFT, CENTER);
  text(int(volMusica * 100) + "%", width/2 + 270, 200);
  text(int(volEfeitos * 100) + "%", width/2 + 270, 270);
  
  checarRemapeamentoJoystick();
  
  float topoTabela = 360;
  float espacamentoLinha = 50;
  float col1X = width/2 - 300; 
  float col2X = width/2 - 50;  
  float col3X = width/2 + 200; 
  
  fill(0, 255, 255); textSize(22); textAlign(CENTER, CENTER);
  text("AÇÃO", col1X, topoTabela);
  text("TECLADO", col2X, topoTabela);
  text("CONTROLE", col3X, topoTabela);
  
  stroke(0, 255, 255, 100); strokeWeight(2);
  line(width/2 - 450, topoTabela + 20, width/2 + 450, topoTabela + 20);
  
  String[] acoes = {"VOAR PARA CIMA", "VOAR PARA BAIXO", "IR PARA ESQUERDA", "IR PARA DIREITA", "ATIRAR", "SOLTAR EMP"};
  String[] chavesTeclado = {obterNomeTecla(teclaUp), obterNomeTecla(teclaDown), obterNomeTecla(teclaLeft), obterNomeTecla(teclaRight), obterNomeTecla(teclaAtirar), obterNomeTecla(teclaEMP)};
  String[] chavesJoy = {joyUp, joyDown, joyLeft, joyRight, joyAtirar, joyEMP};
  
  for (int i = 0; i < acoes.length; i++) {
    float yLinha = topoTabela + 60 + (i * espacamentoLinha);
    
    fill(200); textSize(18); textAlign(LEFT, CENTER);
    text(acoes[i], col1X - 120, yLinha);
    
    desenharCaixaMapeamento(chavesTeclado[i], col2X, yLinha, acaoRemapeando.equals(acoes[i]) && remapeandoTeclado);
    desenharCaixaMapeamento(chavesJoy[i], col3X, yLinha, acaoRemapeando.equals(acoes[i]) && remapeandoJoy);
  }
  
  desenharBotaoMenu("VOLTAR E SALVAR", width/2, height - 80);
}

void desenharCaixaMapeamento(String texto, float cx, float cy, boolean ativo) {
  float w = 220, h = 35;
  if (ativo) { fill(0, 255, 255, 80); stroke(255); } else { fill(30, 40, 50); stroke(0, 255, 255, 150); }
  strokeWeight(2); rect(cx - w/2, cy - h/2, w, h, 5);
  fill(255); textSize(16); textAlign(CENTER, CENTER);
  if (ativo) text("> PRESSIONE <", cx, cy - 2); else text(texto, cx, cy - 2);
}

// ===== EVENTOS DO MOUSE =====
void interacaoMouseConfig() {
  if (checarCliqueBotao(width/2, height - 80)) {
    cp5.hide(); estadoJogo = ESTADO_LOGIN; acaoRemapeando = ""; remapeandoTeclado = false; remapeandoJoy = false; return;
  }
  float col2X = width/2 - 50, col3X = width/2 + 200;
  String[] acoes = {"VOAR PARA CIMA", "VOAR PARA BAIXO", "IR PARA ESQUERDA", "IR PARA DIREITA", "ATIRAR", "SOLTAR EMP"};
  
  for (int i = 0; i < acoes.length; i++) {
    float yLinha = 360 + 60 + (i * 50);
    // Teclado
    if (mouseX > col2X - 110 && mouseX < col2X + 110 && mouseY > yLinha - 17 && mouseY < yLinha + 17) {
      acaoRemapeando = acoes[i]; remapeandoTeclado = true; remapeandoJoy = false;
    }
    // Controle
    if (mouseX > col3X - 110 && mouseX < col3X + 110 && mouseY > yLinha - 17 && mouseY < yLinha + 17) {
      iniciarRemapeamentoJoystick(acoes[i]);
    }
  }
}

// Prepara os analógicos guardando a posição inicial pra não bugar
void iniciarRemapeamentoJoystick(String acao) {
  acaoRemapeando = acao;
  remapeandoTeclado = false;
  remapeandoJoy = true;
  
  if (gamepad != null) {
    sliderInicial = new float[gamepad.getNumberOfSliders()];
    for (int j = 0; j < gamepad.getNumberOfSliders(); j++) {
      sliderInicial[j] = gamepad.getSlider(j).getValue();
    }
  }
}

// ===== CAPTURA DO TECLADO =====
boolean remapKeyPressed() {
  if (estadoJogo == ESTADO_CONFIG && remapeandoTeclado && !acaoRemapeando.equals("")) {
    int teclaPressionada = (key != CODED) ? key : keyCode;
    if (acaoRemapeando.equals("VOAR PARA CIMA")) teclaUp = teclaPressionada;
    else if (acaoRemapeando.equals("VOAR PARA BAIXO")) teclaDown = teclaPressionada;
    else if (acaoRemapeando.equals("IR PARA ESQUERDA")) teclaLeft = teclaPressionada;
    else if (acaoRemapeando.equals("IR PARA DIREITA")) teclaRight = teclaPressionada;
    else if (acaoRemapeando.equals("ATIRAR")) teclaAtirar = teclaPressionada;
    else if (acaoRemapeando.equals("SOLTAR EMP")) teclaEMP = teclaPressionada;
    acaoRemapeando = ""; remapeandoTeclado = false; return true;
  } return false;
}

// ===== CAPTURA DO CONTROLE (COMPLETO: BOTOES, ANALOGICOS E D-PAD) =====
void checarRemapeamentoJoystick() {
  if (estadoJogo == ESTADO_CONFIG && remapeandoJoy && !acaoRemapeando.equals("") && gamepad != null) {
    
    // 1. Busca por botões físicos (A, B, X, Y, RB, LB)
    for (int i = 0; i < gamepad.getNumberOfButtons(); i++) {
      if (gamepad.getButton(i).pressed()) {
        atribuirComandoJoystick(gamepad.getButton(i).getName()); return;
      }
    }
    
    // 2. Busca por D-PAD com limite de segurança
    try {
      for (int i = 0; i < 4; i++) { // Varre de forma cega do 0 ao 3
        ControlHat hat = gamepad.getHat(i);
        if (hat != null) {
          if (hat.up()) { atribuirComandoJoystick(hat.getName() + "_HAT_UP"); return; }
          if (hat.down()) { atribuirComandoJoystick(hat.getName() + "_HAT_DOWN"); return; }
          if (hat.left()) { atribuirComandoJoystick(hat.getName() + "_HAT_LEFT"); return; }
          if (hat.right()) { atribuirComandoJoystick(hat.getName() + "_HAT_RIGHT"); return; }
        }
      }
    } catch (Exception e) {} // Silencia o erro se o índice do Hat não existir
    
    // 3. Busca por Eixos/Gatilhos com sensibilidade intencional (Impede falsos cliques)
    for (int i = 0; i < gamepad.getNumberOfSliders(); i++) {
      float valAtual = gamepad.getSlider(i).getValue();
      float valIni = sliderInicial != null && i < sliderInicial.length ? sliderInicial[i] : 0;
      
      // Só mapeia se você puxar forte o botão (+ de 50% do centro)
      if (abs(valAtual - valIni) > 0.5) { 
        if (valAtual > valIni) { atribuirComandoJoystick(gamepad.getSlider(i).getName() + "+"); } 
        else { atribuirComandoJoystick(gamepad.getSlider(i).getName() + "-"); }
        return;
      }
    }
  }
}

void atribuirComandoJoystick(String comando) {
  if (acaoRemapeando.equals("VOAR PARA CIMA")) joyUp = comando;
  else if (acaoRemapeando.equals("VOAR PARA BAIXO")) joyDown = comando;
  else if (acaoRemapeando.equals("IR PARA ESQUERDA")) joyLeft = comando;
  else if (acaoRemapeando.equals("IR PARA DIREITA")) joyRight = comando;
  else if (acaoRemapeando.equals("ATIRAR")) joyAtirar = comando;
  else if (acaoRemapeando.equals("SOLTAR EMP")) joyEMP = comando;
  acaoRemapeando = ""; remapeandoJoy = false;
}

// ===== EXECUÇÃO EM LOOP DOS INPUTS JOGANDO =====
void atualizarEntradasJoystick() {
  boolean joyU = false, joyD = false, joyL = false, joyR = false, joyA = false, triggerEMP = false;

  if (gamepad != null) {
    joyU = lerEntradaJoystick(joyUp);
    joyD = lerEntradaJoystick(joyDown);
    joyL = lerEntradaJoystick(joyLeft);
    joyR = lerEntradaJoystick(joyRight);
    joyA = lerEntradaJoystick(joyAtirar);
    triggerEMP = lerEntradaJoystick(joyEMP);
  }
  
  // A nave agora respeita o Joystick sem esquecer o Teclado!
  up = tecladoUp || joyU;
  down = tecladoDown || joyD;
  left = tecladoLeft || joyL;
  right = tecladoRight || joyR;
  atirando = tecladoAtirando || joyA;
  
  if (triggerEMP && cargasEMP > 0 && especialOnda == null) {
    especialOnda = new OndaEMP(x + larguraNave/2, y + alturaNave/2);
    cargasEMP--; shakeTimer = 20; if (somEMP != null) somEMP.play();
  }
}

boolean lerEntradaJoystick(String conf) {
  if (conf == null || conf.equals("")) return false;
  try {
    if (conf.endsWith("+") || conf.endsWith("-")) {
      char dir = conf.charAt(conf.length() - 1);
      String nomeSlider = conf.substring(0, conf.length() - 1);
      ControlSlider s = gamepad.getSlider(nomeSlider);
      if (s != null) {
        float val = s.getValue();
        if (dir == '+' && val > 0.4) return true;
        if (dir == '-' && val < -0.4) return true;
      }
    } else if (conf.contains("_HAT_")) {
      String nomeHat = conf.substring(0, conf.indexOf("_HAT_"));
      String dir = conf.substring(conf.lastIndexOf("_") + 1);
      
      ControlHat h = null;
      try {
        for(int i = 0; i < 4; i++) {
          ControlHat tempHat = gamepad.getHat(i);
          if(tempHat != null && tempHat.getName().equals(nomeHat)) {
            h = tempHat;
            break;
          }
        }
      } catch (Exception e) {}
      
      if (h != null) {
        if (dir.equals("UP")) return h.up();
        if (dir.equals("DOWN")) return h.down();
        if (dir.equals("LEFT")) return h.left();
        if (dir.equals("RIGHT")) return h.right();
      }
    } else {
      ControlButton b = gamepad.getButton(conf);
      if (b != null) return b.pressed();
    }
  } catch (Exception e) {}
  return false;
}

String obterNomeTecla(int k) {
  if (k == UP) return "SETA CIMA"; if (k == DOWN) return "SETA BAIXO";
  if (k == LEFT) return "SETA ESQ"; if (k == RIGHT) return "SETA DIR";
  if (k == ' ') return "ESPACO";
  if (k >= 32 && k <= 126) return String.valueOf((char)k).toUpperCase();
  return "TECLA " + k;
}

void atualizarVolumesGlobais() {
  if (somMusicaFundo != null) somMusicaFundo.amp(volMusica);
  if (somLaserPlayer != null) somLaserPlayer.amp(volEfeitos);
  if (somDanoNave != null) somDanoNave.amp(volEfeitos);
  if (somLaserInimigo != null) somLaserInimigo.amp(volEfeitos);
  if (somExplosao != null) somExplosao.amp(volEfeitos);
  if (somExplosaoBoss != null) somExplosaoBoss.amp(volEfeitos);
  if (somPowerUp != null) somPowerUp.amp(volEfeitos);
  if (somEMP != null) somEMP.amp(volEfeitos);
  if (somAlarmeBoss != null) somAlarmeBoss.amp(volEfeitos);
}
