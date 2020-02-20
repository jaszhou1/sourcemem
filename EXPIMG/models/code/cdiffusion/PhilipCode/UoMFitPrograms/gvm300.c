/* ==========================================================================
%  Circular diffusion model 300-step C version. Generalized von Mises
%  No drift norm variability.
%
%  [T, Gt, Theta, Ptheta, Mt] = gvm300(P, tmax, badix);
%   P = [nunorm, kappa, phi, rho, sigma, a]
% 
%  Building: mex gvm300.c -lgsl  -lgslcblas -lm

% ===========================================================================
*/

#include <mex.h>
#include <math.h>
#include <gsl/gsl_sf_bessel.h>

#define kmax 50  /* Maximum number of eigenvalues in dhamana */
#define nw 50    /* Number of steps on circle */
#define nwplus1 51    /* Close the domain */
#define sz 300   /* Number of time steps */
#define nwplus1_sz (nwplus1*300) 
#define NP 6     /* Number of input parameters */
#define njsteps 21 /* Number of steps in drift angle distribution */

const double pi = 3.141592653589793, eps = 1e-15;

double Pmt[nwplus1], J0k[kmax], J0k_squared[kmax], J1k[kmax], Commonscale[sz], Gt0[sz],
       Gti[nwplus1_sz], Pthetai[nw], Mti[nw];

void dhamana(double *T, double *Gt0, double *P0, double h, int badix) {
    /* 
      ---------------------------------------------------------------
       First-passage-time density for Bessel process.
       Computes roots of J0 using Gnu GSL library.
      ----------------------------------------------------------------
    */
     
    double a, a2, sigma, sigma2, scaler; 
    int i, k;

    a = P0[0];
    sigma = P0[1];
    sigma2 = sigma * sigma;
    a2 = a * a;
    scaler = sigma2 / a2;
    
    T[0] = 0;
    Gt0[0] = 0;

    /* Roots of J0k */
    for (k = 0; k < kmax; k++) { 
        J0k[k] = gsl_sf_bessel_zero_J0(k+1);
    }

    /* Evaluate Bessel function at the roots */
    for (k = 0; k < kmax; k++) {
        J0k_squared[k] = J0k[k] * J0k[k];
        /* J1k[k] = j1(J0k[k]); */  /* besselj in Gnu library */
        J1k[k] = gsl_sf_bessel_J1(J0k[k]); /* GSL library */
    }
    for (i = 1; i < sz; i++) {    
        T[i] = i * h;
        Gt0[i] = 0;
        for (k = 0; k < kmax; k++) {
            Gt0[i] += J0k[k] * exp(-J0k_squared[k] * sigma2 * T[i] / (2.0 * a2)) / J1k[k]; 
        }
        Gt0[i] *= scaler;
        if (i <= badix) {
            Gt0[i] = 0;
        }
    }
}; /* dhamana */



void dcircle300(double *T, double *Gt, double *Theta, double *Ptheta, double *Mt, 
              double *P, double tmax, int badix) {
   /* ----------------------------------------------------------------------------------------
      First-passage-time density and response probabilities for circular diffusion process
     ---------------------------------------------------------------------------------------- */
    
    double P0[2];
    double w, two_pi, h, mu1, mu2, sigma, a, munorm, sigma1_2, sigma2_2, mt, 
           commonscale_multiplier, mtscale, densityscale;
    int i, k;

    two_pi = 2.0 * pi;
    w = 2.0 * pi / nw;
  
    /* Parameters */
    h = tmax / sz; 
    mu1 = P[0];
    mu2 = P[1];
    sigma = P[2];
    a = P[3];
    munorm = sqrt(mu1 * mu1 + mu2 * mu2);
    /* mexPrintf("w = %6.4f h =%6.4f \n", w, h);*/
    /* mexPrintf("mu1 = %6.4f mu2 =%6.4f sigma = %6.4f a = %6.4f\n", mu1, mu2, sigma, a); */

    /* Assume same diffusion in both directions */
    sigma1_2 = sigma * sigma;
    sigma2_2 = sigma * sigma;  
    P0[0] = a;
    P0[1] = sigma;

    /* Density of zero-drift process */
    dhamana(T, Gt0, P0, h, badix); 
    
    /* Response circle (1 x nw) - close the domain */
    Theta[0] = -pi;
    for (i = 1; i <= nw; i++) {
        Theta[i] = Theta[i-1] + w;
    }

    /* Girsanov transformation (1 x nw) */     
    for (i = 0; i <= nw; i++) {
        Pmt[i] = exp(a * cos(Theta[i]) * mu1 / sigma1_2 + a * sin(Theta[i]) * mu2 / sigma2_2);
    }

    /* Scaling term for RT distribution (1 x sz) */
    commonscale_multiplier = 0.5 * ((mu1 * mu1)/sigma1_2 + (mu2 * mu2)/sigma2_2);
    for (k = 0; k < sz; k++) {
        Commonscale[k] = exp(-commonscale_multiplier * T[k]);   
    }

    /*  Integral of K(|mu|) * G0(t) */
    densityscale = 0;
    for (k = 1; k < sz; k++) {
        densityscale += ((Commonscale[k] * Gt0[k]) + (Commonscale[k-1] * Gt0[k-1]));
    }
    densityscale *= h / 2.0; /* Simpson's rule integral */
    /*mexPrintf("density scale = %6.4f h = %6.4f \n", densityscale, h);*/

   /* Joint RT distribution (nw * sz) - make Matlab conformant */
   for (k = 0; k < sz; k++) {
        for (i = 0; i < nw; i++) {
            mtscale = Pmt[i] * Commonscale[k];
            Gt[nwplus1 * k + i] = mtscale * Gt0[k] / two_pi; /* put density on 2d scale */
        }
       /* Close the domain */
        Gt[nwplus1 * k + nw] = Gt[nwplus1 * k];
    }
          
    /* Hitting probabilities (1 x nw) */
    for (i = 0; i < nw; i++) {
        Ptheta[i] = Pmt[i] * densityscale / two_pi;
    }
   /* Close the domain but don't double-count the mass */
   Ptheta[nw] = Ptheta[0];
   /* Mean RT */

   mt = a * gsl_sf_bessel_I1(a * munorm/(sigma * sigma)) 
            / gsl_sf_bessel_I0(a * munorm/(sigma * sigma)) / munorm; 
   for (i = 0; i <= nw; i++) {
     Mt[i] = mt;
   }
} /* dcircle300 */


void gvm300(double *T, double *Gt, double *Theta, double *Ptheta, double *Mt, 
              double *P, double tmax, int badix) {
    /* ----------------------------------------------------------------------------
       Power of cosine distance drift rate variability
       ---------------------------------------------------------------------------- */
    double Pj[4],  ThetaMu[njsteps], ProbMu[njsteps];
    double v1, v2, phi, nunorm, kappa, sigma, a, rho, beta, gama, 
           inc, sumprob, thetaj, mu1, mu2, sumrj;
    int i, j, k, r, l;

    nunorm= P[0];
    kappa = P[1];
    phi = P[2];
    rho = P[3];
    sigma = P[4];
    a = P[5];

    /*mexPrintf("nunorm = %6.3f kappa = %4.3f  phi = %6.3f rho = %6.3f, sigma = %6.3f, a = %6.3f\n", 
    nunorm, kappa, phi, rho, sigma, a); */


    /* Across trial variability in phase angle, drift norm is constant. */
    inc = 2 * pi / njsteps;
    sumprob = 0;
    for (j = 0; j < njsteps; j++) {
       ThetaMu[j] = -pi + inc / 2 + j * inc;
       ProbMu[j] = exp(-kappa * pow(1 - cos(ThetaMu[j]), rho));
       sumprob += ProbMu[j];
       /*mexPrintf("%6d %6.3f %6.3f \n", j, ThetaMu[j], ProbMu[j]); */
    }    


    /* Normalize the gvm mass */
    for (j = 0; j < njsteps; j++) {
       ProbMu[j] /= sumprob; 
    } 
    /* mexPrintf("sumprob = %6.3f\n", sumprob); */
 
   /* Initialize the output structures */
    for (k = 0; k <= nw; k++) {
         Ptheta[k] = 0; 
         Mt[k] = 0;       
         for (i = 0; i < sz; i++) {   
             Gt[nwplus1 * k + i] = 0;
         }
     }   
     /* Mix */
     Pj[2] = sigma;
     Pj[3] = a;

     /* Step across phase angles */
     for (j = 0; j < njsteps; j++) {
         thetaj = ThetaMu[j] + phi;
         mu1 = nunorm * cos(thetaj);
         mu2 = nunorm * sin(thetaj); 
         /*mexPrintf("j =  %4d  mu1 = %6.3f mu2 = %4.3f sigma = %4.3f  a = %4.3f\n", j, mu1, mu2, sigma, a);  */
         Pj[0] = mu1;
         Pj[1] = mu2;
         dcircle300(T, Gti, Theta, Pthetai, Mti, Pj, tmax, badix);
         sumrj = 0; 
         for (l = 0; l < nw; l++) {
             sumrj += Pthetai[l];
         }
         /*mexPrintf("sumrj = %6.3f\n", sumrj);*/ 
         for (i = 0; i < nw; i++) {
              Ptheta[i] += ProbMu[j] * Pthetai[i]; 
              Mt[i] += ProbMu[j] * Pthetai[i] * Mti[i];
              for (k = 0; k < sz; k++) {       
                  Gt[nwplus1 * k + i] += ProbMu[j] * Gti[nwplus1 * k + i];
              }
         }
     }
     /* Average */ 
     for (i = 0; i < nw; i++) {
         Mt[i] /= (Ptheta[i] + eps);
     }
     /* Close the domain */
     Mt[nw] = Mt[0];
     Ptheta[nw] = Ptheta[0];
}; /* gvm300 8*/


   
 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
 /*
     =======================================================================
     Matlab gateway routine.
     =======================================================================
 */
 

int badix; 

double *T, *Gt, *Theta, *Ptheta, *Mt, *P;
 
double tmax, badi;
 
unsigned n, m;

    if (nrhs != 3) {
         mexErrMsgTxt("gvm300: Requires 3 input args.");
    } else if (nlhs != 5) {
        mexErrMsgTxt("gvm300: Requires 5 output args."); 
    }

    /*
      -----------------------------------------------------------------------
      Check all input argument dimensions.
      -----------------------------------------------------------------------   
    */

    /* P */
    m = mxGetM(prhs[0]);
    n = mxGetN(prhs[0]);
    if (!mxIsDouble(prhs[0]) || !(m * n == NP)) {
        mexPrintf("P is %4d x %4d \n", m, n);
        mexErrMsgTxt("gvm300: Wrong size P");
    } else {
        P = mxGetPr(prhs[0]);
    }
    /* tmax */
    m = mxGetM(prhs[1]);
    n = mxGetN(prhs[1]);
    if (!mxIsDouble(prhs[1]) || !(m * n == 1)) {
        mexErrMsgTxt("gvm300: tmax must be a scalar");
    } else { 
        tmax = mxGetScalar(prhs[1]);
    }
    if (tmax <= 0.0) {
        mexPrintf("tmax =  %6.2f \n", tmax);
        mexErrMsgTxt("tmax must be positive");
    } 

    /* badi */
    m = mxGetM(prhs[2]);
    n = mxGetN(prhs[2]);
    if (!mxIsDouble(prhs[2]) || !(m * n == 1)) {
        mexErrMsgTxt("gvm300: badi must be a scalar");
    } else { 
        badi = mxGetScalar(prhs[2]);
        badix = (int)(badi+0.5); 
    }  
 
    /*
      -----------------------------------------------------------------------
      Create output arrays.
      -----------------------------------------------------------------------
    */
 
    /* T */
    plhs[0] = mxCreateDoubleMatrix(1, sz, mxREAL);
    T = mxGetPr(plhs[0]);
    
    /* Gt */
    plhs[1] = mxCreateDoubleMatrix(nwplus1, sz, mxREAL);
    Gt = mxGetPr(plhs[1]);
    
     /* Theta */
    plhs[2] = mxCreateDoubleMatrix(1, nwplus1, mxREAL);
    Theta = mxGetPr(plhs[2]);


    /* Ptheta */
    plhs[3] = mxCreateDoubleMatrix(1, nwplus1, mxREAL);
    Ptheta = mxGetPr(plhs[3]);

    /* Mt */
    plhs[4] = mxCreateDoubleMatrix(1, nwplus1, mxREAL);
    Mt = mxGetPr(plhs[4]);


    /*
      -----------------------------------------------------------------------
      Run the C-function.
      -----------------------------------------------------------------------
    */

    gvm300(T, Gt, Theta, Ptheta, Mt, P, tmax, badix);
}


