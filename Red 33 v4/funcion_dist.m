function [perfil_EVSET1, perfil_EVSET2, perfil_EVSET1_adicional, perfil_EVSET2_adicional, perfil_noservido, flagcambioevse, cliente_EVSET1, cliente_EVSET2, cliente_noserv] = funcion_dist(Tc1, Tc2, suma_clientes_ev, distancia_real, perfil_nodoEVGA, posicion_EV, max_evse1, max_evse2)
%% Calculo de distancias
%Tc1 = [1 2 3 4];
%Tc2 = [5 6 7 8];
distanciasTc1 = [];
distanciasTc2 = [];
%perfil_nodoEVGA = perfil_nodoEVGA_rapido;
%%
% for i = 1:1:suma_clientes_ev
%     for j = 1:1:365
%         if j > 0 && j < 92
%            tc1_index = find(Tc1 == distancia_real(:,1));
% %            matriz_distancias1(j,i) = );
% %            matriz_distancias2(j,i) = );
%         elseif j > 91 && j < 183
%            ind1 = find(Tc1(2)==coordenadas(:,1));
%            ind2 = find(Tc2(2)==coordenadas(:,1));
%            dist_Tc1 = coordenadas(ind1,1:2);
%            dist_Tc2 = coordenadas(ind2,1:2);
%            posEv = find(coordenadas(:,1)==posicion_EV(j,i));
%            dist_ev = coordenadas(posEv,1:2);
%            matriz_distancias1(j,i) = pdist2(dist_ev,dist_Tc1,'euclidean');
%            matriz_distancias2(j,i) = pdist2(dist_ev,dist_Tc2,'euclidean'); 
%         elseif j > 182 && j < 274
%            ind1 = find(Tc1(3)==coordenadas(:,1));
%            ind2 = find(Tc2(3)==coordenadas(:,1));
%            dist_Tc1 = coordenadas(ind1,1:2);
%            dist_Tc2 = coordenadas(ind2,1:2);
%            posEv = find(coordenadas(:,1)==posicion_EV(j,i));
%            dist_ev = coordenadas(posEv,1:2);
%            matriz_distancias1(j,i) = pdist2(dist_ev,dist_Tc1,'euclidean');
%            matriz_distancias2(j,i) = pdist2(dist_ev,dist_Tc2,'euclidean');
%         elseif j > 273 && j < 366
%            ind1 = find(Tc1(4)==coordenadas(:,1));
%            ind2 = find(Tc2(4)==coordenadas(:,1));
%            dist_Tc1 = coordenadas(ind1,1:2);
%            dist_Tc2 = coordenadas(ind2,1:2);
%            posEv = find(coordenadas(:,1)==posicion_EV(j,i));
%            dist_ev = coordenadas(posEv,1:2);


%            matriz_distancias1(j,i) = pdist2(dist_ev,dist_Tc1,'euclidean');
%            matriz_distancias2(j,i) = pdist2(dist_ev,dist_Tc2,'euclidean');   
%         end
%     end
% end

%% Construir perfiles EVSE
perfil_EVSET1_1 = zeros(8760,1);
perfil_EVSET2_1 = zeros(8760,1);
perfil_EVSET1_2 = zeros(8760,1);
perfil_EVSET2_2 = zeros(8760,1);
perfil_EVSET1_3 = zeros(8760,1);
perfil_EVSET2_3 = zeros(8760,1);
perfil_EVSET1_4 = zeros(8760,1);
perfil_EVSET2_4 = zeros(8760,1);
perfil_EVSET1_1_adicional = zeros(8760,1);
perfil_EVSET1_2_adicional = zeros(8760,1);
perfil_EVSET1_3_adicional = zeros(8760,1);
perfil_EVSET1_4_adicional = zeros(8760,1);
perfil_EVSET2_1_adicional = zeros(8760,1);
perfil_EVSET2_2_adicional = zeros(8760,1);
perfil_EVSET2_3_adicional = zeros(8760,1);
perfil_EVSET2_4_adicional = zeros(8760,1);
perfil_noservido = zeros(8760,1);
cliente_EVSET1 = zeros(365,suma_clientes_ev);
cliente_EVSET2 = zeros(365,suma_clientes_ev);
cliente_noserv = zeros(365,suma_clientes_ev);
flagcambioevse = 0;
promkwkmori = 0.1622;
%matriztipoEV = xlsread('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Origen-destinoV2\Modelo Carga EV\datosEV');
for i = 1:1:suma_clientes_ev %recorre vehiculos
    k = 1; %recorre hora inicio
    m = 24; %recorre hora termino
    for j = 1:1:365 %recorre días del año
        if j > 0 && j < 92 %periodo 1 del año, asumiendo que es verano
            [distanciasTc1, distanciasTc2, dist] = obtener_dist(Tc1(1),Tc2(1),j,i,distancia_real,posicion_EV); % evaluacion de distancias entre Ev y cargadores
            if distanciasTc1 < distanciasTc2 %si ladistancia a Tc1 es menor entonces -->
                promkwkm = zeros(24,1);
                promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
                if max(perfil_EVSET1_1(k:m,1)) < max_evse1 %si el cargador no est lleno -->
                    perfil_EVSET1_1(k:m,1) = perfil_EVSET1_1(k:m,1) + perfil_nodoEVGA(k:m,i); %el perfil del cargador sera el anterior más el nuevo vehiculo
                    perfil_EVSET1_1_adicional(k:m,1) = perfil_EVSET1_1_adicional(k:m,1) + promkwkm.*distanciasTc1/1000; %se agrega la energía adicional de conducir al punto de carga
                    cliente_EVSET1(j,i) = 1;
                elseif max(perfil_EVSET1_1(k:m,1)) > max_evse1 && max(perfil_EVSET2_1(k:m,1)) < max_evse2  %en caso de que el cargador este lleno, se va hacia el otro
                    perfil_EVSET2_1(k:m,1) = perfil_EVSET2_1(k:m,1) + perfil_nodoEVGA(k:m,i);  %se agrega el nuevo vehiculo al perfil anterior
                    perfil_EVSET2_1_adicional(k:m,1) = perfil_EVSET2_1_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000+dist/1000); % se agrega una penalización adicional debido a recorrer la distancia al cargador 1 y luego al 2.
                    if max(promkwkm)>0
                        flagcambioevse = flagcambioevse + 1;
                    end
                    cliente_EVSET2(j,i) = 1;
                elseif max(perfil_EVSET1_1(k:m,1)) > max_evse1 && max(perfil_EVSET2_1(k:m,1)) > max_evse2  %si ambos cargadores estan llenos, el vehiculo no carga y se presenta como perfil no servido.
                    perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                    cliente_noserv(j,i) = 1;
                end
                k = k + 24;
                m = m + 24;    
            else
                promkwkm = zeros(24,1);
                promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
                if  max(perfil_EVSET2_1(k:m,1)) < max_evse2
                    perfil_EVSET2_1(k:m,1) = perfil_EVSET2_1(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET2_1_adicional(k:m,1) = perfil_EVSET2_1_adicional(k:m,1) + promkwkm.*distanciasTc2/1000;
                    cliente_EVSET2(j,i) = 1;
                elseif max(perfil_EVSET2_1(k:m,1)) > max_evse2 && max(perfil_EVSET1_1(k:m,1)) < max_evse1
                    perfil_EVSET1_1(k:m,1) = perfil_EVSET1_1(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET1_1_adicional(k:m,1) = perfil_EVSET1_1_adicional(k:m,1) + promkwkm.*(distanciasTc2/1000+dist/1000);
                    if max(promkwkm)>0
                        flagcambioevse = flagcambioevse + 1;
                    end
                    cliente_EVSET1(j,i) = 1;
                elseif max(perfil_EVSET1_1(k:m,1)) > max_evse1 && max(perfil_EVSET2_1(k:m,1)) > max_evse2
                    perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                    cliente_noserv(j,i) = 1;
                end
                k = k + 24;
                m = m + 24;
            end
        elseif j > 91 && j < 183
            [distanciasTc1, distanciasTc2, dist] = obtener_dist(Tc1(2),Tc2(2),j,i,distancia_real,posicion_EV);
            if distanciasTc1 < distanciasTc2
                promkwkm = zeros(24,1);
                promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
                if max(perfil_EVSET1_2(k:m,1)) < max_evse1
                    perfil_EVSET1_2(k:m,1) = perfil_EVSET1_2(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET1_2_adicional(k:m,1) = perfil_EVSET1_2_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000);
                    cliente_EVSET1(j,i) = 1;
                elseif max(perfil_EVSET1_2(k:m,1)) > max_evse1 && max(perfil_EVSET2_2(k:m,1)) < max_evse2
                    perfil_EVSET2_2(k:m,1) = perfil_EVSET2_2(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET2_2_adicional(k:m,1) = perfil_EVSET2_2_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000+dist/1000);
                    if max(promkwkm)>0
                        flagcambioevse = flagcambioevse + 1;
                    end
                    cliente_EVSET2(j,i) = 1;
                elseif max(perfil_EVSET1_2(k:m,1)) > max_evse1 && max(perfil_EVSET2_2(k:m,1)) > max_evse2
                    perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                    cliente_noserv(j,i) = 1;
                end
                k = k + 24;
                m = m + 24;    
            else
                promkwkm = zeros(24,1);
                promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
                if max(perfil_EVSET2_2(k:m,1)) < max_evse2
                    perfil_EVSET2_2(k:m,1) = perfil_EVSET2_2(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET2_2_adicional(k:m,1) = perfil_EVSET2_2_adicional(k:m,1) + promkwkm.*(distanciasTc2/1000);
                    cliente_EVSET2(j,i) = 1;
                elseif max(perfil_EVSET2_2(k:m,1)) > max_evse2 && max(perfil_EVSET1_2(k:m,1)) < max_evse1
                    perfil_EVSET1_2(k:m,1) = perfil_EVSET1_2(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET1_2_adicional(k:m,1) = perfil_EVSET1_2_adicional(k:m,1) + promkwkm.*(distanciasTc2/1000+dist/1000);
                    if max(promkwkm)>0
                        flagcambioevse = flagcambioevse + 1;
                    end
                    cliente_EVSET1(j,i) = 1;
                elseif max(perfil_EVSET1_2(k:m,1)) > max_evse1 && max(perfil_EVSET2_2(k:m,1)) > max_evse2
                    perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                    cliente_noserv(j,i) = 1;
                end
                k = k + 24;
                m = m + 24;
            end
        elseif j > 182 && j < 274
            [distanciasTc1, distanciasTc2, dist] = obtener_dist(Tc1(3),Tc2(3),j,i,distancia_real,posicion_EV);
            if distanciasTc1 < distanciasTc2
                promkwkm = zeros(24,1);
                promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
                if max(perfil_EVSET1_3(k:m,1)) < max_evse1
                    perfil_EVSET1_3(k:m,1) = perfil_EVSET1_3(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET1_3_adicional(k:m,1) = perfil_EVSET1_3_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000);
                    cliente_EVSET1(j,i) = 1;
                elseif max(perfil_EVSET1_3(k:m,1)) > max_evse1 && max(perfil_EVSET2_3(k:m,1)) < max_evse2
                    perfil_EVSET2_3(k:m,1) = perfil_EVSET2_3(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET2_3_adicional(k:m,1) = perfil_EVSET2_3_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000+dist/1000);
                    if max(promkwkm)>0
                        flagcambioevse = flagcambioevse + 1;
                    end
                    cliente_EVSET2(j,i) = 1;
                elseif max(perfil_EVSET1_3(k:m,1)) > max_evse1 && max(perfil_EVSET2_3(k:m,1)) > max_evse2
                    perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                    cliente_noserv(j,i) = 1;
                end
                k = k + 24;
                m = m + 24;    
            else
                promkwkm = zeros(24,1);
                promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
                if max(perfil_EVSET2_3(k:m,1)) < max_evse2
                    perfil_EVSET2_3(k:m,1) = perfil_EVSET2_3(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET2_3_adicional(k:m,1) = perfil_EVSET2_3_adicional(k:m,1) + promkwkm.*(distanciasTc2/1000);
                    cliente_EVSET2(j,i) = 1;
                elseif max(perfil_EVSET2_3(k:m,1)) > max_evse2 && max(perfil_EVSET1_3(k:m,1)) < max_evse1
                    perfil_EVSET1_3(k:m,1) = perfil_EVSET1_3(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET1_3_adicional(k:m,1) = perfil_EVSET1_3_adicional(k:m,1) + promkwkm.*(distanciasTc2/1000+dist/1000);
                    if max(promkwkm)>0
                        flagcambioevse = flagcambioevse + 1;
                    end
                    cliente_EVSET1(j,i) = 1;
                elseif max(perfil_EVSET1_3(k:m,1)) > max_evse1 && max(perfil_EVSET2_3(k:m,1)) > max_evse2
                    perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                    cliente_noserv(j,i) = 1;
                end
                k = k + 24;
                m = m + 24;
            end
        elseif j > 273 && j < 366
            [distanciasTc1, distanciasTc2, dist] = obtener_dist(Tc1(4),Tc2(4),j,i,distancia_real,posicion_EV);
            if distanciasTc1 < distanciasTc2
                promkwkm = zeros(24,1);
                promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
                if max(perfil_EVSET1_4(k:m,1)) < max_evse1
                    perfil_EVSET1_4(k:m,1) = perfil_EVSET1_4(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET1_4_adicional(k:m,1) = perfil_EVSET1_4_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000);
                    cliente_EVSET1(j,i) = 1;
                elseif max(perfil_EVSET1_4(k:m,1)) > max_evse1 && max(perfil_EVSET2_4(k:m,1)) < max_evse2
                    perfil_EVSET2_4(k:m,1) = perfil_EVSET2_4(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET2_4_adicional(k:m,1) = perfil_EVSET2_4_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000+dist/1000);
                    if max(promkwkm)>0
                        flagcambioevse = flagcambioevse + 1;
                    end
                    cliente_EVSET2(j,i) = 1;
                elseif max(perfil_EVSET1_4(k:m,1)) > max_evse1 && max(perfil_EVSET2_4(k:m,1)) > max_evse2
                    perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                    cliente_noserv(j,i) = 1;
                end
                k = k + 24;
                m = m + 24;    
            else
                promkwkm = zeros(24,1);
                promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
                if max(perfil_EVSET2_4(k:m,1)) < max_evse2
                    perfil_EVSET2_4(k:m,1) = perfil_EVSET2_4(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET2_4_adicional(k:m,1) = perfil_EVSET2_4_adicional(k:m,1) + promkwkm.*(distanciasTc2/1000);
                    cliente_EVSET2(j,i) = 1;
                elseif max(perfil_EVSET2_4(k:m,1)) > max_evse2 && max(perfil_EVSET1_4(k:m,1)) < max_evse1
                    perfil_EVSET1_4(k:m,1) = perfil_EVSET1_4(k:m,1) + perfil_nodoEVGA(k:m,i);
                    perfil_EVSET1_4_adicional(k:m,1) = perfil_EVSET1_4_adicional(k:m,1) + promkwkm.*(distanciasTc2/1000+dist/1000);
                    if max(promkwkm)>0
                        flagcambioevse = flagcambioevse + 1;
                    end
                    cliente_EVSET1(j,i) = 1;
                elseif max(perfil_EVSET1_4(k:m,1)) > max_evse1 && max(perfil_EVSET2_4(k:m,1)) > max_evse2
                    perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                    cliente_noserv(j,i) = 1;
                end
                k = k + 24;
                m = m + 24;
            end
        end
    end
end
perfil_EVSET1 = [perfil_EVSET1_1, perfil_EVSET1_2, perfil_EVSET1_3, perfil_EVSET1_4];
perfil_EVSET2 = [perfil_EVSET2_1, perfil_EVSET2_2, perfil_EVSET2_3, perfil_EVSET2_4];
perfil_EVSET1_adicional = [perfil_EVSET1_1_adicional, perfil_EVSET1_2_adicional, perfil_EVSET1_3_adicional, perfil_EVSET1_4_adicional];
perfil_EVSET2_adicional = [perfil_EVSET2_1_adicional, perfil_EVSET2_2_adicional, perfil_EVSET2_3_adicional, perfil_EVSET2_4_adicional];