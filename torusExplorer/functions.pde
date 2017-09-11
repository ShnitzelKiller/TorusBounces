/* EDIT THESE FUNCTIONS TO MODIFY PARAMETRIZATION (Derivatives must be correct) 
 * You may use adjustable parameters a, b, and c in your expressions.
 */

int turns = 3;

double R(double phi) {
  return 2;
}
double r(double phi, double theta) {
  return b/(a*a) / (1 - a * Math.cos(theta + c * Math.sin(turns * phi)));
}
double dRdphi(double phi) {
  return 0;
}
double drdphi(double phi, double theta) {
  return -b/a * Math.sin(theta + c * Math.sin(turns * phi)) * c * turns * Math.cos(turns * phi) / sqr(1-a*Math.cos(theta + c * Math.sin(turns * phi)));
}
double drdtheta(double phi, double theta) {
  return -b/a * Math.sin(theta + c * Math.sin(turns * phi)) / sqr(1-a*Math.cos(theta + c * Math.sin(turns * phi)));
}

/* END EDIT */