/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

public void slidertheta_change(GSlider source, GEvent event) { //_CODE_:slidertheta:551549:
} //_CODE_:slidertheta:551549:

public void sliderphi_change(GSlider source, GEvent event) { //_CODE_:sliderphi:451999:
} //_CODE_:sliderphi:451999:

public void clearbutton_click(GButton source, GEvent event) { //_CODE_:clearbutton:560376:
  clearImages();
  recopy();
} //_CODE_:clearbutton:560376:

public void sliderstart_change(GSlider source, GEvent event) { //_CODE_:sliderstart:384026:
  needsRedraw = true;
} //_CODE_:sliderstart:384026:

public void sliderend_change(GSlider source, GEvent event) { //_CODE_:sliderend:276107:
  needsRedraw = true;
} //_CODE_:sliderend:276107:

public void checkbox_clicked(GCheckbox source, GEvent event) { //_CODE_:checkbox:935369:
  //clearbutton.setEnabled(!source.isSelected());
  slidera.setEnabled(!source.isSelected());
  sliderb.setEnabled(!source.isSelected());
  sliderc.setEnabled(!source.isSelected());
  
  if (!source.isSelected()) {
    recopy();
  }
  needsRedraw = true;
} //_CODE_:checkbox:935369:

public void slidera_change(GSlider source, GEvent event) { //_CODE_:slidera:417594:
  a = source.getValueF();
  toruspoints(pts, nres, mres);
} //_CODE_:slidera:417594:

public void sliderb_change(GSlider source, GEvent event) { //_CODE_:sliderb:912805:
  b = source.getValueF();
  toruspoints(pts, nres, mres);
} //_CODE_:sliderb:912805:

public void sliderc_change(GSlider source, GEvent event) { //_CODE_:sliderc:393942:
  c = source.getValueF();
  toruspoints(pts, nres, mres);
} //_CODE_:sliderc:393942:

synchronized public void preview_draw(PApplet appc, GWinData data) { //_CODE_:preview:226203:
  appc.pushMatrix();
  appc.translate(appc.width/2.0, appc.height/2.0, -zoom);
  appc.rotateX(alt);
  appc.rotateZ(rot);
  appc.background(255);
  appc.stroke(0, 0, 0, 50);
  appc.noFill();
  appc.strokeWeight(1);
  for (int i=0; i<nres; i++) {
    appc.beginShape();
    for (int j=0; j<mres; j++) {
      float ptx = (float)pts[0][i * mres + j] * scale;
      float pty = (float)pts[1][i * mres + j] * scale;
      float ptz = (float)pts[2][i * mres + j] * scale;
      appc.vertex(ptx, pty, ptz);
    }
    appc.endShape(CLOSE);
  }
  
  for (int i=0; i<mres; i++) {
    appc.beginShape();
    for (int j=0; j<nres; j++) {
      float ptx = (float)pts[0][j * mres + i] * scale;
      float pty = (float)pts[1][j * mres + i] * scale;
      float ptz = (float)pts[2][j * mres + i] * scale;
      appc.vertex(ptx, pty, ptz);
    }
    appc.endShape(CLOSE);
  }
  
  PVectord param = coord2params(lastmouseX, lastmouseY);
  PVectord pt = toruspoint(param.x, param.y);
  appc.stroke(100, 100, 0);
  appc.strokeWeight(5);
  appc.point((float)pt.x * scale, (float)pt.y * scale, (float)pt.z * scale);
  appc.stroke(100, 0, 0);
  appc.strokeWeight(2);
  appc.beginShape(LINES);
  appc.vertex((float)pt.x * scale, (float)pt.y * scale, (float)pt.z * scale);
  PVectord dir = initDir(param.x, param.y);
  //dir.mul(scale/40);
  pt.add(dir);
  appc.vertex((float)pt.x * scale, (float)pt.y * scale, (float)pt.z * scale);
  appc.endShape();
  
  if (checkbox.isSelected()) {
    appc.strokeWeight(1);
    appc.stroke(0, 100, 0);
    appc.beginShape();
    int start = sliderstart.getValueI();
    int end = sliderend.getValueI();
    
    for (int i=start; i<end; i++) {
      double phi = tdata[0][i];
      double theta = tdata[1][i];
      PVectord hit = toruspoint(phi, theta);
      color col = lerphue(((float)i - start)/(end - start));
      appc.stroke(col);
      appc.vertex((float)hit.x * scale, (float)hit.y * scale, (float)hit.z * scale);
    }
    appc.endShape();
  }
  appc.popMatrix();
} //_CODE_:preview:226203:

synchronized public void preview_mouse(PApplet appc, GWinData data, MouseEvent mevent) { //_CODE_:preview:836716:
  if (mevent.getAction() == MouseEvent.PRESS) {
    isDragging = true;
    dragPosX = mevent.getX();
    dragPosY = mevent.getY();
    lastRot = rot;
    lastAlt = alt;
    lastZoom = zoom;
  } else if (mevent.getAction() == MouseEvent.RELEASE) {
    isDragging = false;
  } else if (isDragging) {
    if (mevent.getButton() == LEFT) {
      rot = lastRot - (mevent.getX() - dragPosX) / 100f;
      alt = lastAlt - (mevent.getY() - dragPosY) / 100f;
    } else if (mevent.getButton() == RIGHT) {
      zoom = lastZoom + (mevent.getY() - dragPosY);
    }
  }
} //_CODE_:preview:836716:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  surface.setTitle("Sketch Window");
  panel1 = new GPanel(this, 0, 0, 240, 500, "Settings");
  panel1.setCollapsible(false);
  panel1.setDraggable(false);
  panel1.setText("Settings");
  panel1.setOpaque(true);
  slidertheta = new GSlider(this, 60, 60, 160, 40, 10.0);
  slidertheta.setShowValue(true);
  slidertheta.setRotation(PI/2, GControlMode.CORNER);
  slidertheta.setLimits(0.0, -1.5707964, 1.5707964);
  slidertheta.setNumberFormat(G4P.DECIMAL, 2);
  slidertheta.setOpaque(false);
  slidertheta.addEventHandler(this, "slidertheta_change");
  sliderphi = new GSlider(this, 60, 20, 160, 40, 10.0);
  sliderphi.setShowValue(true);
  sliderphi.setLimits(0.0, -1.5707964, 1.5707964);
  sliderphi.setNumberFormat(G4P.DECIMAL, 2);
  sliderphi.setOpaque(false);
  sliderphi.addEventHandler(this, "sliderphi_change");
  label1 = new GLabel(this, 0, 20, 60, 40);
  label1.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label1.setText("Launch direction");
  label1.setOpaque(false);
  clearbutton = new GButton(this, 60, 140, 160, 80);
  clearbutton.setText("clear canvas");
  clearbutton.addEventHandler(this, "clearbutton_click");
  sliderstart = new GSlider(this, 60, 260, 160, 40, 10.0);
  sliderstart.setShowValue(true);
  sliderstart.setShowLimits(true);
  sliderstart.setLimits(0, 0, 100);
  sliderstart.setEasing(10.0);
  sliderstart.setNumberFormat(G4P.INTEGER, 0);
  sliderstart.setOpaque(false);
  sliderstart.addEventHandler(this, "sliderstart_change");
  sliderend = new GSlider(this, 60, 300, 160, 40, 10.0);
  sliderend.setShowValue(true);
  sliderend.setShowLimits(true);
  sliderend.setLimits(100, 0, 100);
  sliderend.setEasing(10.0);
  sliderend.setNumberFormat(G4P.INTEGER, 0);
  sliderend.setOpaque(false);
  sliderend.addEventHandler(this, "sliderend_change");
  label2 = new GLabel(this, 0, 260, 60, 40);
  label2.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label2.setText("start");
  label2.setOpaque(false);
  label3 = new GLabel(this, 0, 300, 60, 40);
  label3.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label3.setText("end");
  label3.setOpaque(false);
  checkbox = new GCheckbox(this, 60, 230, 140, 20);
  checkbox.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  checkbox.setText("render selected range");
  checkbox.setOpaque(false);
  checkbox.addEventHandler(this, "checkbox_clicked");
  slidera = new GSlider(this, 60, 380, 160, 40, 10.0);
  slidera.setShowValue(true);
  slidera.setShowLimits(true);
  slidera.setLimits(0.5, 0.0, 1.0);
  slidera.setNumberFormat(G4P.DECIMAL, 2);
  slidera.setOpaque(false);
  slidera.addEventHandler(this, "slidera_change");
  sliderb = new GSlider(this, 60, 420, 160, 40, 10.0);
  sliderb.setShowValue(true);
  sliderb.setShowLimits(true);
  sliderb.setLimits(0.5, 0.0, 1.0);
  sliderb.setNumberFormat(G4P.DECIMAL, 2);
  sliderb.setOpaque(false);
  sliderb.addEventHandler(this, "sliderb_change");
  sliderc = new GSlider(this, 60, 460, 160, 40, 10.0);
  sliderc.setShowValue(true);
  sliderc.setShowLimits(true);
  sliderc.setLimits(0.5, 0.0, 1.0);
  sliderc.setNumberFormat(G4P.DECIMAL, 2);
  sliderc.setOpaque(false);
  sliderc.addEventHandler(this, "sliderc_change");
  label6 = new GLabel(this, 0, 380, 60, 40);
  label6.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label6.setText("a");
  label6.setOpaque(false);
  label7 = new GLabel(this, 0, 420, 60, 40);
  label7.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label7.setText("b");
  label7.setOpaque(false);
  label8 = new GLabel(this, 0, 460, 60, 40);
  label8.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label8.setText("c");
  label8.setOpaque(false);
  philabel = new GLabel(this, 60, 60, 160, 20);
  philabel.setText("last phi:");
  philabel.setOpaque(false);
  thetalabel = new GLabel(this, 60, 80, 160, 20);
  thetalabel.setText("last theta:");
  thetalabel.setOpaque(false);
  azilabel = new GLabel(this, 60, 100, 160, 20);
  azilabel.setText("last azi: ");
  azilabel.setOpaque(false);
  altlabel = new GLabel(this, 60, 120, 160, 20);
  altlabel.setText("last alt: ");
  altlabel.setOpaque(false);
  label9 = new GLabel(this, 60, 340, 160, 40);
  label9.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label9.setText("Parameters");
  label9.setOpaque(false);
  panel1.addControl(slidertheta);
  panel1.addControl(sliderphi);
  panel1.addControl(label1);
  panel1.addControl(clearbutton);
  panel1.addControl(sliderstart);
  panel1.addControl(sliderend);
  panel1.addControl(label2);
  panel1.addControl(label3);
  panel1.addControl(checkbox);
  panel1.addControl(slidera);
  panel1.addControl(sliderb);
  panel1.addControl(sliderc);
  panel1.addControl(label6);
  panel1.addControl(label7);
  panel1.addControl(label8);
  panel1.addControl(philabel);
  panel1.addControl(thetalabel);
  panel1.addControl(azilabel);
  panel1.addControl(altlabel);
  panel1.addControl(label9);
  label4 = new GLabel(this, 240, 0, 80, 20);
  label4.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label4.setText("Phase plot");
  label4.setLocalColorScheme(GCScheme.SCHEME_8);
  label4.setOpaque(false);
  label5 = new GLabel(this, 740, 0, 80, 20);
  label5.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  label5.setText("Phase plot 2");
  label5.setLocalColorScheme(GCScheme.SCHEME_8);
  label5.setOpaque(false);
  preview = GWindow.getWindow(this, "Preview", 50, 50, 200, 200, P3D);
  preview.noLoop();
  preview.addDrawHandler(this, "preview_draw");
  preview.addMouseHandler(this, "preview_mouse");
  preview.loop();
}

// Variable declarations 
// autogenerated do not edit
GPanel panel1; 
GSlider slidertheta; 
GSlider sliderphi; 
GLabel label1; 
GButton clearbutton; 
GSlider sliderstart; 
GSlider sliderend; 
GLabel label2; 
GLabel label3; 
GCheckbox checkbox; 
GSlider slidera; 
GSlider sliderb; 
GSlider sliderc; 
GLabel label6; 
GLabel label7; 
GLabel label8; 
GLabel philabel; 
GLabel thetalabel; 
GLabel azilabel; 
GLabel altlabel; 
GLabel label9; 
GLabel label4; 
GLabel label5; 
GWindow preview;