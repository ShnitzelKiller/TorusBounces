/* EDIT THESE FUNCTIONS TO MODIFY PARAMETRIZATION (Derivatives must be correct) 
 * You may use adjustable parameters a, b, and c in your expressions.
 */

double R(double phi) {
  return c * 4;
}
double r(double phi, double theta) {
  return b * 2 + a * Math.sin(phi);
}
double dRdphi(double phi) {
  return 0;
}
double drdphi(double phi, double theta) {
  return a * Math.cos(phi);
}
double drdtheta(double phi, double theta) {
  return 0;
}

/* END EDIT */