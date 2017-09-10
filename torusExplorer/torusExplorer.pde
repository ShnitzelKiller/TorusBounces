import g4p_controls.*;
import java.lang.Math.*;

static final double MIN_STEP = 1e-4;
static final double TOLERANCE = 1e-9;
static final int bounces = 10000;
static final int nres = 64;
static final int mres = 16;
static final int scale = 40;
static final int background_brightness = 0;

/* EDIT THESE FUNCTIONS TO MODIFY PARAMETRIZATION (Derivatives must be correct) */

double R(double phi) {
  return 2;
}
double r(double phi, double theta) {
  return 1 + 0.5 * Math.sin(phi);
}
double dRdphi(double phi) {
  return 0;
}
double drdphi(double phi, double theta) {
  return 0.5 * Math.cos(phi);
}
double drdtheta(double phi, double theta) {
  return 0;
}

/* END EDIT */

class PVectord {
  double x;
  double y;
  double z;
  PVectord(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  PVectord(double x, double y) {
    this.x = x;
    this.y = y;
    this.z = 0;
  }
  
  void add(PVectord other) {
    this.x += other.x;
    this.y += other.y;
    this.z += other.z;
  }
  void normalize() {
    double s = Math.sqrt(x*x+y*y+z*z);
    x/=s;
    y/=s;
    z/=s;
  }
  void mul(double s) {
    x*=s;
    y*=s;
    z*=s;
  }
  void set(PVectord other) {
    x = other.x;
    y = other.y;
    z = other.z;
  }
  
  void set(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
 
  void rotateX(double ang) {
    double newy = Math.cos(ang) * y - Math.sin(ang) * z;
    double newz = Math.sin(ang) * y + Math.cos(ang) * z;
    y = newy;
    z = newz;
  }
  
  void rotateY(double ang) {
    double newz = Math.cos(ang) * z - Math.sin(ang) * x;
    double newx = Math.sin(ang) * z + Math.cos(ang) * x;
    z = newz;
    x = newx;
  }
  
  void rotateZ(double ang) {
    double newx = Math.cos(ang) * x - Math.sin(ang) * y;
    double newy = Math.sin(ang) * x + Math.cos(ang) * y;
    x = newx;
    y = newy;
  }
  
  public String toString() {
    return "( " + x + ", " + y + ", " + z + " )";
  }
}

PVectord cross(PVectord a, PVectord b) {
  return new PVectord(
       a.y*b.z-a.z*b.y,
       a.z*b.x-a.x*b.z,
       a.x*b.y-a.y*b.x);
}

double dot(PVectord a, PVectord b) {
  return a.x*b.x+a.y*b.y+a.z*b.z;
}

GWindow window;
GWindow window2;
GSlider slider1;
GSlider slider2;
GButton button;
GLabel label1;
GLabel label2;
GSlider sliderstart;
GSlider sliderend;
GLabel labelstart;
GLabel labelend;
GCheckbox checkbox;
GLabel labelcheck;
GLabel labelphi;
GLabel labeltheta;

GWindow preview;
PVectord[] pts;
color currColor;

static final double[][] tdata = new double[3][bounces];

boolean clearcanvas1;
boolean clearcanvas2;
boolean enabledraw;
boolean partialdraw;

float rot;
float alt;

void setup() {
  clearcanvas1 = true;
  clearcanvas2 = true;
  enabledraw = false;
  partialdraw = false;
  rot = 0;
  alt = PI/4;
  noSmooth();
  size(500,200);
  colorMode(HSB, 100);
  pts = toruspoints(nres, mres);
  preview = GWindow.getWindow(this, "Preview", 100, 600, 200, 200, P3D);
  preview.addDrawHandler(this, "previewDraw");
  preview.addMouseHandler(this, "previewMouse");
  window = GWindow.getWindow(this, "Trajectory Picker", 100, 50, 500, 500, JAVA2D);
  window.addMouseHandler(this, "windowMouse");
  window.addDrawHandler(this, "windowDraw");
  window2 = GWindow.getWindow(this, "Plot2", 600, 50, 500, 500, JAVA2D);
  window2.addDrawHandler(this, "windowDraw2");
  slider1 = new GSlider(this, 50, 10, 300, 50, 10);
  slider2 = new GSlider(this, 50, 50, 300, 50, 10);
  sliderstart = new GSlider(this, 50, 90, 300, 50, 10);
  sliderend = new GSlider(this, 50, 130, 300, 50, 10);
  label1 = new GLabel(this, 10, 20, 50, 20, "phi");
  label2 = new GLabel(this, 10, 60, 50, 20, "theta");
  label2 = new GLabel(this, 10, 100, 50, 20, "start");
  label2 = new GLabel(this, 10, 140, 50, 20, "end");
  slider1.setLimits(0, -PI/2, PI/2);
  slider1.setShowValue(true);
  slider1.setShowLimits(true);
  slider2.setLimits(0, -PI/2, PI/2);
  slider2.setShowValue(true);
  slider2.setShowLimits(true);
  sliderstart.setLimits(0, 0, bounces);
  sliderstart.setShowValue(true);
  sliderstart.setShowLimits(true);
  sliderend.setLimits(bounces, 0, bounces);
  sliderend.setShowValue(true);
  sliderend.setShowLimits(true);
  button = new GButton(this, 380, 50, 100, 25, "clear canvas");
  checkbox = new GCheckbox(this, 440, 120, 50, 50);
  labelcheck = new GLabel(this, 400, 135, 50, 20, "render");
  labelphi = new GLabel(this, 50, 180, 200, 20, "phi: ");
  labeltheta = new GLabel(this, 250, 180, 200, 20, "theta: ");
}

PVectord[] toruspoints(int n, int m) {
  PVectord[] pts = new PVectord[n * m];
  for (int i=0; i<n; i++) {
    for (int j=0; j<m; j++) {
      pts[i * m + j] = toruspoint(2*Math.PI/n*i, 2*Math.PI/m*j);
    }
  }
  return pts;
}

float dragPosX;
float dragPosY;
float lastRot;
float lastAlt;
boolean isDragging;

public void previewMouse(PApplet app, GWinData data, MouseEvent event) {
  if (event.getAction() == MouseEvent.PRESS) {
    isDragging = true;
    dragPosX = event.getX();
    dragPosY = event.getY();
    lastRot = rot;
    lastAlt = alt;
  } else if (event.getAction() == MouseEvent.RELEASE) {
    isDragging = false;
  } else if (isDragging) {
    rot = lastRot + (event.getX() - dragPosX) / 100f;
    alt = lastAlt + (event.getY() - dragPosY) / 100f;
  }
}

public void previewDraw(PApplet app, GWinData data) {
  app.pushMatrix();
  app.translate(app.width/2.0, app.height/2.0, -100);
  app.rotateX(alt);
  app.rotateZ(rot);
  app.background(255);
  app.stroke(0, 0, 0, 50);
  app.noFill();
  app.strokeWeight(1);
  for (int i=0; i<nres; i++) {
    app.beginShape();
    for (int j=0; j<mres; j++) {
      PVectord pt = pts[i * mres + j];
      app.vertex((float)pt.x * scale, (float)pt.y * scale, (float)pt.z * scale);
    }
    app.endShape(CLOSE);
  }
  
  for (int i=0; i<mres; i++) {
    app.beginShape();
    for (int j=0; j<nres; j++) {
      PVectord pt = pts[j * mres + i];
      app.vertex((float)pt.x * scale, (float)pt.y * scale, (float)pt.z * scale);
    }
    app.endShape(CLOSE);
  }
  
  PVectord param = coord2params(window.mouseX, window.mouseY);
  PVectord pt = toruspoint(param.x, param.y);
  app.stroke(100, 100, 0);
  app.strokeWeight(5);
  app.point((float)pt.x * scale, (float)pt.y * scale, (float)pt.z * scale);
  app.stroke(100, 0, 0);
  app.strokeWeight(2);
  app.beginShape(LINES);
  app.vertex((float)pt.x * scale, (float)pt.y * scale, (float)pt.z * scale);
  PVectord dir = initDir(param.x, param.y);
  //dir.mul(scale/40);
  pt.add(dir);
  app.vertex((float)pt.x * scale, (float)pt.y * scale, (float)pt.z * scale);
  app.endShape();
  app.strokeWeight(1);
  app.stroke(0, 100, 0);
  app.beginShape();
  if (partialdraw) {
    for (int i=sliderstart.getValueI(); i<sliderend.getValueI(); i++) {
      double phi = tdata[0][i];
      double theta = tdata[1][i];
      PVectord hit = toruspoint(phi, theta);
      app.vertex((float)hit.x * scale, (float)hit.y * scale, (float)hit.z * scale);
    }
  }
  app.endShape();
  app.popMatrix();
}

public void windowMouse(PApplet app, GWinData data, MouseEvent event) {
  if (event.getButton() == LEFT && event.getAction() == MouseEvent.CLICK) {
    PVectord params0 = coord2params(event.getX(), event.getY());
    double phi0 = params0.x;
    double theta0 = params0.y;
    
    labelphi.setText("phi: " + phi0);
    labeltheta.setText("theta: " + theta0);
    
    PVectord dir = initDir(phi0, theta0);
    initial_cond(tdata, phi0, theta0, dir, bounces);
    
    currColor = color(random(100), 100, 100);
    enabledraw = true;
    drawhelper1(app, 0, bounces);
  }
}

public void windowDraw(PApplet app, GWinData data) {
  if (clearcanvas1) {
    app.background(background_brightness);
    clearcanvas1 = false;
  } else if (partialdraw) {
    app.background(background_brightness);
    drawhelper1(app, sliderstart.getValueI(), sliderend.getValueI());
  }
}

public void windowDraw2(PApplet app, GWinData data) {
  if (clearcanvas2) {
    app.background(background_brightness);
    clearcanvas2 = false;
  } else if (enabledraw) {
    drawhelper2(app, 0, bounces);
    enabledraw = false;
  } else if (partialdraw) {
    app.background(background_brightness);
    drawhelper2(app, sliderstart.getValueI(), sliderend.getValueI());
  }
}

private void drawhelper1(PApplet app, int start, int end) {
  app.stroke(currColor);
  for (int i=start; i<end; i++) {
    double phi = tdata[0][i];
    double theta = tdata[1][i];
    double posX = (phi/(2*Math.PI) + 0.5) * app.width;
    double posY = (theta/(2*Math.PI) + 0.5) * app.height;
    
    app.point((float)posX, (float)posY);
    //println();
    //println(params[i].x);
    //println(params[i].y);
  }
}

private void drawhelper2(PApplet app, int start, int end) {
  app.stroke(currColor);
    for (int i=start; i<end; i++) {
      double phi = tdata[0][i];
      double momZ = tdata[2][i];
      double posX = (phi/(2*Math.PI) + 0.5) * app.width;
      double posY = (momZ/(6) + 0.5) * app.height;
      
      app.point((float)posX, (float)posY);
      //println();
      //println(params[i].x);
      //println(params[i].y);
    }
}

public void handleToggleControlEvents(GToggleControl checkbox, GEvent event) {
  if (checkbox == this.checkbox) {
    if (checkbox.isSelected()) {
      clearcanvas1 = true;
      clearcanvas2 = true;
      partialdraw = true;
    } else {
      partialdraw = false;
    }
  }
}

public void handleButtonEvents(GButton button, GEvent event) {
  if (this.button == button) {
    clearcanvas1 = true;
    clearcanvas2 = true;
  }
}

void draw() {
  background(0, 0, 100);
}

PVectord coord2params(double x, double y) {
  return new PVectord((((double)x)/width - 0.5) * 2 * Math.PI, (((double)y)/height - 0.5) * 2 * Math.PI);
}

PVectord initDir(double phi, double theta) {
  PVectord dir = normal(R(phi), r(phi, theta), dRdphi(phi), drdphi(phi, theta), drdtheta(phi, theta), phi, theta);
  double phidir = Math.atan2(dir.y, dir.x);
  dir.rotateZ(-phidir);
  double thetadir = Math.atan2(dir.x, dir.z);
  
  dir.set(0, 0, 1);
  
  double sliderphi = slider1.getValueF();
  double slidertheta = slider2.getValueF();
  
  dir.rotateX(sliderphi);
  dir.rotateY(slidertheta);
  
  dir.rotateY(thetadir);
  dir.rotateZ(phidir);
  
  dir.normalize();
  return dir;
}

void mousePressed() {
  
}

PVectord angles(PVectord x) {
  double phi = Math.atan2(x.y, x.x);
  double theta = Math.atan2(x.z, Math.sqrt(x.x*x.x + x.y*x.y) - R(phi));
  return new PVectord(phi, theta);
}

PVectord normal(double R, double r, double dRdphi, double drdphi, double drdtheta, double phi, double theta) {
  double fac1 = -r * Math.sin(theta) + drdtheta * Math.cos(theta);
  PVectord dtheta = new PVectord(
        fac1 * Math.cos(phi),
        fac1 * Math.sin(phi),
        r * Math.cos(theta) + drdtheta * Math.sin(theta));
  double fac2 = dRdphi + drdphi * Math.cos(theta);
  double fac3 = R + r * Math.cos(theta);
  PVectord dphi = new PVectord(
        fac2 * Math.cos(phi) - fac3 * Math.sin(phi),
        fac2 * Math.sin(phi) + fac3 * Math.cos(phi),
        drdphi * Math.sin(theta));
  PVectord n = cross(dtheta, dphi);
  n.normalize();
  return n;
}

double distance(PVectord x) {
  PVectord angs = angles(x);
  double phi = angs.x;
  double theta = angs.y;
  double dist = Math.sqrt(x.x*x.x+x.y*x.y) - R(phi);
  double rhat = Math.sqrt(x.z*x.z + dist*dist);
  return rhat - r(phi, theta);
}

PVectord toruspoint(double phi, double theta) {
  double rphitheta = r(phi, theta);
  double fac = R(phi) + rphitheta * Math.cos(theta);
  return new PVectord(fac * Math.cos(phi),
                      fac * Math.sin(phi),
                      rphitheta * Math.sin(theta));
}

PVectord raytrace(double phi, double theta, PVectord dir) {
  PVectord x = toruspoint(phi, theta);
  PVectord x0 = new PVectord(0, 0);
  double dist = distance(x);
  double dist0 = 0;
  PVectord dir0 = new PVectord(0, 0);
  while (true) {
    x0.set(x);
    double step = Math.max(Math.abs(dist)/2, MIN_STEP);
    dir0.set(dir);
    dir0.mul(step);
    x.add(dir0);
    dist0 = dist;
    dist = distance(x);
    if (dist > 0) {
      break;
    }
  }
  
  PVectord xopt = new PVectord(0, 0);
  while (true) {
    xopt.set(x);
    xopt.add(x0);
    xopt.mul(0.5);
    dist0 = distance(xopt);
    if (dist0 < TOLERANCE) {
      break;
    }
    if (dist0 < 0) {
      x0.set(xopt);
    } else {
      x.set(xopt);
    }
  }
  return angles(xopt);
}

void initial_cond(double[][] params, double phi, double theta, PVectord dir, int bounces) {
  for (int i=0; i<bounces; i++) {
    PVectord param = raytrace(phi, theta, dir);
    phi = param.x;
    theta = param.y;
    params[0][i] = phi;
    params[1][i] = theta;
    PVectord n = normal(R(phi), r(phi, theta), dRdphi(phi), drdphi(phi, theta), drdtheta(phi, theta), phi, theta);
    PVectord x = toruspoint(phi, theta);
    PVectord angmom = cross(x, dir);
    params[2][i] = angmom.z;
    //println("n: " + n.toString());
    double comp = dot(n, dir);
    n.mul(-2 * comp);
    dir.add(n);
    dir.normalize();
    //println("dir after reflection: " + dir.toString());
    //println();
  }
}