import g4p_controls.*;
import java.awt.Color;

final double MIN_STEP = 1e-4;
final double TOLERANCE = 1e-9;
final int BOUNCES = 10000;

final int nres = 64;
final int mres = 32;
final int scale = 40;
final int background_brightness = 0;
final color color1 = color(255, 0, 0);
final color color2 = color(0, 0, 255);

color currColor;
float rot;
float alt;
float zoom;
float dragPosX;
float dragPosY;
float lastRot;
float lastAlt;
float lastZoom;
boolean isDragging;
boolean needsRedraw;
int lastmouseX;
int lastmouseY;
//positions in the right window
int lastmouseX2;
int lastmouseY2;
double a;
double b;
double c;


final double[][] tdata = new double[3][BOUNCES];
final double[][] pts = new double[3][nres * mres];

PImage img1;
PImage img2;

public void setup(){
  size(1240, 500, JAVA2D);
  noSmooth();
  background(background_brightness);
  createGUI();
  customGUI();
  // Place your setup code here
  zoom = 100;
  toruspoints(pts, nres, mres);
  img1 = createImage(500, 500, RGB);
  img2 = createImage(500, 500, RGB);
  clearImages();
}

public void draw(){
  if (needsRedraw) {
    updateall();
    needsRedraw = false;
  }
}

private void recopy() {
  image(img1, 240, 0);
  image(img2, 740, 0);
}

//draw the range of points currently specified
private void drawpartial() {
  background(background_brightness);
  drawhelper(sliderstart.getValueI(), sliderend.getValueI(), true);
}

//draw the image buffers into the viewport, or draw the point range currently selected
private void updateall() {
  if (checkbox.isSelected()) {
    drawpartial();
  } else {
    recopy();
  }
  drawoverlay();
}

private void drawoverlay() {
  noStroke();
  fill(100);
  rect(0, 0, width, 20);
  stroke(100);
  line(740, 0, 740, height);
  stroke(255);
  beginShape(LINES);
  vertex(lastmouseX2 - 5, lastmouseY2);
  vertex(lastmouseX2 + 5, lastmouseY2);
  vertex(lastmouseX2 , lastmouseY2 - 5);
  vertex(lastmouseX2 , lastmouseY2 + 5);
  endShape();
}

float truncate(double x) {
  return round((float)x * 10000) / 10000f;
}

public void mouseClicked() {
  if (mouseX > 240 && mouseX <= 740) {
    PVectord params0 = coord2params(mouseX, mouseY);
    double phi0 = params0.x;
    double theta0 = params0.y;
    philabel.setText("last phi: " + truncate(phi0));
    thetalabel.setText("last theta: " + truncate(theta0));
    azilabel.setText("last azi: " + truncate(sliderphi.getValueF()));
    altlabel.setText("last alt: " + truncate(slidertheta.getValueF()));
    //labelphi.setText("phi: " + phi0);
    //labeltheta.setText("theta: " + theta0);
    
    PVectord dir = initDir(phi0, theta0);
    initial_cond(tdata, phi0, theta0, dir, BOUNCES);
    colorMode(HSB);
    currColor = color(random(255), 255, 255);
    colorMode(RGB);
    drawhelper(0, BOUNCES, false);
    updateall();
  }
}

public void mouseMoved() {
  if (mouseX > 240 && mouseX <= 740) {
    
      //redraw existing canvas
    needsRedraw = true;
    PVectord params = coord2params(mouseX, mouseY);
    double phi = params.x;
    double theta = params.y;
    
    //must un-bounce the direction backwards to be consistent with how ang momentom
    //is measured in subsequent bounces (pre-bounce)
    PVectord dir = initDir(phi, theta);
    PVectord n = normal(R(phi), r(phi, theta), dRdphi(phi), drdphi(phi, theta), drdtheta(phi, theta), phi, theta);
    PVectord x = toruspoint(phi, theta);
    double comp = dot(n, dir);
    n.mul(-2 * comp);
    dir.add(n);
    dir.normalize();
    
    PVectord angmom = cross(x, dir);

    lastmouseX2 = mouseX + 500;
    lastmouseY2 = (int) ((angmom.z/(6) + 0.5) * height);
    
    lastmouseX = mouseX;
    lastmouseY = mouseY;
  }
}

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){
  sliderstart.setLimits(0, 0, BOUNCES);
  sliderend.setLimits(BOUNCES, 0, BOUNCES);
  a = slidera.getValueF();
  b = sliderb.getValueF();
  c = sliderc.getValueF();
}

private int lerphue(float s) {
  return Color.HSBtoRGB(s * 0.66, 1, 1);
}

private void drawhelper(int start, int end, boolean direct) {
  for (int i=start; i<end; i++) {
    double phi = tdata[0][i];
    double theta = tdata[1][i];
    double momZ = tdata[2][i];

    PVectord pos = params2coord(phi, theta);
    
    int posY2 = (int) ((momZ/(6) + 0.5) * height);
    color pixcolor = direct ? lerphue(((float)i - start)/(end - start)) : currColor;
    if (direct) {
      stroke(pixcolor);
      point((int)pos.x, (int)pos.y);
      point((int)pos.x + 500, posY2);
    } else {
      img1.set((int)pos.x - 240, (int)pos.y, pixcolor);
      img2.set((int)pos.x - 240, posY2, pixcolor);
    }
    //println();
    //println(params[i].x);
    //println(params[i].y);
  }
}

private void clearImages() {
  for (int i=0; i<img1.width; i++) {
    for (int j=0; j<img1.height; j++) {
      img1.set(i, j, background_brightness);
      img2.set(i, j, background_brightness);
    }
  }
}

PVectord coord2params(double x, double y) {
  return new PVectord(((x-240)/500.0 - 0.5) * 2 * Math.PI, ((y-20)/480.0 - 0.5) * 2 * Math.PI);
}

PVectord params2coord(double phi, double theta) {
  return new PVectord((phi/(2*Math.PI) + 0.5) * 500 + 240, (theta/(2*Math.PI) + 0.5) * 480 + 20);
}

PVectord initDir(double phi, double theta) {
  PVectord dir = normal(R(phi), r(phi, theta), dRdphi(phi), drdphi(phi, theta), drdtheta(phi, theta), phi, theta);
  double phidir = Math.atan2(dir.y, dir.x);
  dir.rotateZ(-phidir);
  double thetadir = Math.atan2(dir.x, dir.z);
  
  dir.set(0, 0, 1);
  
  dir.rotateX(sliderphi.getValueF());
  dir.rotateY(slidertheta.getValueF());
  
  dir.rotateY(thetadir);
  dir.rotateZ(phidir);
  
  dir.normalize();
  return dir;
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

void toruspoints(double[][] out, int n, int m) {
  for (int i=0; i<n; i++) {
    for (int j=0; j<m; j++) {
      PVectord pt = toruspoint(2*Math.PI/n*i, 2*Math.PI/m*j);
      pts[0][i * m + j] = pt.x;
      pts[1][i * m + j] = pt.y;
      pts[2][i * m + j] = pt.z;
    }
  }
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

double sqr(double a) {
  return a * a;
}