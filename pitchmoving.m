
function [pitch_shifted_signal] = psola(sp)

% [sp , Fs] = audioread("parham.wav");
% %sp=sp(2293:2293+441);
% n=length(sp);
% %Establish upper and lower pitch search limits
% pmin=30; pmax=200;
% sp2=sp.^2;% pre-calculate to save time
% for M=pmin:pmax
%     e_del=sp(1:n-M);
%     e=sp(M+1:n);
%     e2=sp2(M+1:n);
%     E(1+M-pmin)=sum((e_del.*e).^2)/sum(e2);
% end
% %Find M, the optimum pitch period
% [i, M]=max(E);
% M=M+pmin;
% %Find B, the pitch gain
% e_del=sp(1:n-M);
% e=sp(M+1:n);
% e2=sp2(M+1:n);
% B=sum(e_del.*e)/sum(e2);
 
%%
[M,B]=pitch_estimation_Long_term(sp);
sc=2;
M2=round(M*sc);
 
win=hamming(1,2*M);
N=floor(length(sp)/M);
pitch_shifted_signal=zeros(N*M2+M,1);
for n = 1:N-1 
    fr1=1+(n-1)*M;
    to1=n*M+M;
    seg=sp(fr1:to1).*win;
    fr2=1+(n-1)*M2-M;
    to2=(n-1)*M2+M;
    fr2b=max([1,fr2]);
    pitch_shifted_signal(fr2b:to2)=pitch_shifted_signal(fr2b:to2)+seg(1+fr2b-fr2:2*M);
end
 
% figure()
% plot(sp)
% figure 
% plot(out)

end