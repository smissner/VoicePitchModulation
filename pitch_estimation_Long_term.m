function [pitch_period,gain] = pitch_estimation_Long_term(sp)
n=length(sp);
%Establish upper and lower pitch search limits
pmin=30; pmax=200;
sp2=sp.^2;% pre-calculate to save time
for pitch_period=pmin:pmax
    e_del=sp(1:n-pitch_period);
    e=sp(pitch_period+1:n);
    e2=sp2(pitch_period+1:n);
    E(1+pitch_period-pmin)=sum((e_del.*e).^2)/sum(e2);
end
%Find pitch_period, the optimum pitch period
[i, pitch_period]=max(E);
pitch_period=pitch_period+pmin;
%Find gain, the pitch gain
e_del=sp(1:n-pitch_period);
e=sp(pitch_period+1:n);
e2=sp2(pitch_period+1:n);
gain=sum(e_del.*e)/sum(e2);

end