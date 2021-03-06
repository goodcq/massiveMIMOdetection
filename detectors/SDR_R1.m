% =========================================================================
% -- Part of "Data Detection in Massive MU-MIMO" Simulator
% -------------------------------------------------------------------------
% -- (c) 2020 Christoph Studer and Oscar Castañeda
% -- e-mail: studer@ethz.ch and caoscar@ethz.ch
% =========================================================================

%% detection via exact SemiDefinite Relaxation (SDR) with rank-1 approx
%  You need to install CVX to use this
% -- Zhi-Quan Luo, Wing-Kin Ma, Anthony Man-Cho So, Yinyu Ye, and
% -- Shuzhong Zhang, "Semidefinite Relaxation of Quadratic Optimization
% -- Problems," IEEE Signal Processing Magazine,
% -- vol. 27, no. 3, pp. 20-34, May 2010
function shat = SDR_R1(par,H,y)

  switch par.mod
    case 'QPSK'
      % -- convert to real domain
      yR = [ real(y) ; imag(y) ];
      HR = [ real(H) -imag(H) ; imag(H) real(H) ];   
      % -- preprocessing for SDR  
      T = [HR'*HR , -HR'*yR ; -yR'*HR yR'*yR ];
      N = 2*par.MT+1; 
    case 'BPSK'
      % -- convert to real domain
      yR = [ real(y) ; imag(y) ];
      HR = [ real(H) ; imag(H) ];  
      % -- preprocessing for SDR  
      T = [HR'*HR , -HR'*yR ; -yR'*HR yR'*yR ];
      N = par.MT+1; 
    otherwise
      error('modulation type not supported')
  end  
  
  % -- solve SDP via CVX
  cvx_begin quiet
    variable S(N,N) symmetric;
    S == semidefinite(N);       
    minimize( trace( T*S ) );
    diag(S) == 1;              
  cvx_end
  
  % -- post processing
  [V,U] = eig(S);
  root = V*sqrt(U);
  
  sRhat = sign(root(:,end));  
  switch par.mod
    case 'QPSK'
      shat = sRhat(1:par.MT,1)+1i*sRhat(par.MT+1:end-1,1);
    case 'BPSK'  
      shat = sRhat(1:par.MT,1);
    otherwise
      error('modulation type not supported')
  end
  
end
