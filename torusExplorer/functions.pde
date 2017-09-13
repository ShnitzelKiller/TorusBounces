/* EDIT THESE FUNCTIONS TO MODIFY PARAMETRIZATION (Derivatives must be correct) 
 * You may use adjustable parameters a, b, and c in your expressions.
 */


double R(double phi) {
  return 2;
}
double r(double phi, double theta) {
  return b/(a*a) / (1 - a * Math.cos(theta + phi * c));
}
double dRdphi(double phi) {
  return 0;
}
double drdphi(double phi, double theta) {
  return -b/a * Math.sin(theta + phi * c) * c / sqr(1-a*Math.cos(theta + c * phi));
}
double drdtheta(double phi, double theta) {
  return -b/a * Math.sin(theta + phi * c) / sqr(1-a*Math.cos(theta + c * phi));
}

/* END EDIT */