import g4p_controls.*;

import interfascia.*;

import java.lang.Math.*;

static final double MIN_STEP = 1e-4;
static final double TOLERANCE = 1e-9;
static final int bounces = 1000;
static final int nres = 64;
static final int mres = 16;
static final int scale = 40;


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
double R(double phi) {
  return 2;
}
double r(double phi, double theta) {
  return 1 + 0.5 * Math.cos(8 * phi);
}
double dRdphi(double phi) {
  return 0;
}
double drdphi(double phi, double theta) {
  return -4 * Math.sin(8 * phi);
}
double drdtheta(double phi, double theta) {
  return 0;
}

GWindow window;
GCustomSlider slider1;
GCustomSlider slider2;

GWindow preview;
PVectord[] pts;

float rot;

void setup() {
  rot = 0;
  noSmooth();
  size(500,500);
  ellipseMode(CENTER);
  pts = toruspoints(nres, mres);
  window = GWindow.getWindow(this, "Controls", 100, 50, 500, 100, JAVA2D);
  preview = GWindow.getWindow(this, "Preview", 600, 50, 200, 200, P3D);
  //preview.translate(preview.width/2.0, preview.height/2.0, 100);
  //preview.stroke(0);
  preview.addDrawHandler(this, "previewDraw");
  window.addDrawHandler(this, "windowDraw");
  slider1 = new GCustomSlider(window, 50, 10, 400, 50, "grey_blue");
  slider2 = new GCustomSlider(window, 50, 50, 400, 50, "grey_blue");
  slider1.setLimits(0, -PI/2, PI/2);
  slider1.setShowValue(true);
  slider1.setShowLimits(true);
  slider2.setLimits(0, -PI/2, PI/2);
  slider2.setShowValue(true);
  slider2.setShowLimits(true);
  
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

public void previewDraw(PApplet app, GWinData data) {
  rot += PI/512;
  app.rectMode(CENTER);
  app.pushMatrix();
  app.translate(app.width/2.0, app.height/2.0, -100);
  app.rotateX(PI/4);
  app.rotateZ(rot);
  app.background(255);
  app.stroke(0, 0, 0, 100);
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
  
  PVectord param = coord2params(mouseX, mouseY);
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
  
  app.popMatrix();
}

public void windowDraw(PApplet app, GWinData data) {
  app.background(255);
}

void draw() {
  
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
  PVectord params0 = coord2params(mouseX, mouseY);
  double phi0 = params0.x;
  double theta0 = params0.y;
  
  PVectord dir = initDir(phi0, theta0);
  PVectord[] params = initial_cond(phi0, theta0, dir, bounces);
  
  noStroke();
  fill(random(255), random(255), random(255));
  for (int i=0; i<bounces; i++) {
    double phi = params[i].x;
    double theta = params[i].y;
    double posX = (phi/(2*Math.PI) + 0.5) * width;
    double posY = (theta/(2*Math.PI) + 0.5) * height;
    
    ellipse((float)posX, (float)posY, 3, 3);
    //println();
    //println(params[i].x);
    //println(params[i].y);
  }
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

PVectord[] initial_cond(double phi, double theta, PVectord dir, int bounces) {
  PVectord[] params = new PVectord[bounces];
  for (int i=0; i<bounces; i++) {
    PVectord param = raytrace(phi, theta, dir);
    phi = param.x;
    theta = param.y;
    params[i] = param;
    PVectord n = normal(R(phi), r(phi, theta), dRdphi(phi), drdphi(phi, theta), drdtheta(phi, theta), phi, theta);
    //println("n: " + n.toString());
    double comp = dot(n, dir);
    n.mul(-2 * comp);
    dir.add(n);
    dir.normalize();
    //println("dir after reflection: " + dir.toString());
    //println();
  }
  
  return params;
}