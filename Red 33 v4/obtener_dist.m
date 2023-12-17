function [distTc1, distTc2, dist] = obtener_dist(Tc1, Tc2, dia_ev, num_ev, distancia_real, posicion_EV)
tc1_index1 = distancia_real(:,1) == Tc1;
tc2_index1 = distancia_real(:,1) == Tc2;
ev_index1 = distancia_real(:,2) == posicion_EV(dia_ev,num_ev);
x1 = find(tc1_index1 == 1 & ev_index1 == 1);
y1 = find(tc2_index1 == 1 & ev_index1 == 1);
tc1_index2 = distancia_real(:,2) == Tc1;
tc2_index2 = distancia_real(:,2) == Tc2;
ev_index2 = distancia_real(:,1) == posicion_EV(dia_ev,num_ev);
x2 = find(tc1_index2 == 1 & ev_index2 == 1);
y2 = find(tc2_index2 == 1 & ev_index2 == 1);
if isempty(x1) ~= 1 && isempty(y1) ~= 1
    distTc1 = distancia_real(x1,3);
    distTc2 = distancia_real(y1,3);
else
    distTc1 = distancia_real(x2,3);
    distTc2 = distancia_real(y2,3);
end
f = find(distancia_real(:,1)==Tc1 & distancia_real(:,2) == Tc2);
dist = distancia_real(f,3);

