function [distTc1, dist] = obtener_dist(Tc1, dia_ev, num_ev, distancia_real, posicion_EV)
tc1_index1 = distancia_real(:,1) == Tc1;
ev_index1 = distancia_real(:,2) == posicion_EV(dia_ev,num_ev);
x1 = find(tc1_index1 == 1 & ev_index1 == 1);
tc1_index2 = distancia_real(:,2) == Tc1;
ev_index2 = distancia_real(:,1) == posicion_EV(dia_ev,num_ev);
x2 = find(tc1_index2 == 1 & ev_index2 == 1);
if isempty(x1) ~= 1 
    distTc1 = distancia_real(x1,3);
else
    distTc1 = distancia_real(x2,3);
end
dist = distTc1;

