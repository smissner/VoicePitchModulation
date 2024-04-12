function [pitch_shifted_signal] = psola(sp,pitch_period,new_pitch_period)

% [sp , Fs] = audioread("parham.wav");
% %sp=sp(2293:2293+441);
% n=length(sp);
% %Establish upper and lower pitch search limits
% pmin=30; pmax=200;
% sp2=sp.^2;% pre-calculate to save time
% for pitch_period=pmin:pmax
%     e_del=sp(1:n-pitch_period);
%     e=sp(pitch_period+1:n);
%     e2=sp2(pitch_period+1:n);
%     E(1+pitch_period-pmin)=sum((e_del.*e).^2)/sum(e2);
% end
% %Find pitch_period, the optimum pitch period
% [i, pitch_period]=max(E);
% pitch_period=pitch_period+pmin;
% %Find B, the pitch gain
% e_del=sp(1:n-pitch_period);
% e=sp(pitch_period+1:n);
% e2=sp2(pitch_period+1:n);
% B=sum(e_del.*e)/sum(e2);
 
%%
%
% according to the specs of the problem, if the new pitch period is more
% than 10 then it is multiplied to the original pitch (speeding the 
M2=new_pitch_period;
if new_pitch_period<10
    M2=round(pitch_period*new_pitch_period);
end
win=hamming(1,2*pitch_period);
N=floor(length(sp)/pitch_period);
pitch_shifted_signal=zeros(N*M2+pitch_period,1);
for n = 1:N-1 
    fr1=1+(n-1)*pitch_period;
    to1=n*pitch_period+pitch_period;
    seg=sp(fr1:to1).*win;
    fr2=1+(n-1)*M2-pitch_period;
    to2=(n-1)*M2+pitch_period;
    fr2b=max([1,fr2]);
    pitch_shifted_signal(fr2b:to2)=pitch_shifted_signal(fr2b:to2)+seg(1+fr2b-fr2:2*pitch_period);
end
 
% figure()
% plot(sp)
% figure 
% plot(out)

end
