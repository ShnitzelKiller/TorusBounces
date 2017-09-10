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