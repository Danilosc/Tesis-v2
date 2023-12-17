function [perfil_EVSET1, perfil_EVSET1_adicional, perfil_noservido, flagcambioevse, cliente_EVSET1, cliente_noserv] = funcion_dist(Tc1, suma_clientes_ev, distancia_real, perfil_nodoEVGA, posicion_EV, max_evse1)
%% Calculo de distancias
distanciasTc1 = [];
%% Construir perfiles EVSE
perfil_EVSET1_1 = zeros(8760,1);
perfil_EVSET1_2 = zeros(8760,1);
perfil_EVSET1_3 = zeros(8760,1);
perfil_EVSET1_4 = zeros(8760,1);
perfil_EVSET1_1_adicional = zeros(8760,1);
perfil_EVSET1_2_adicional = zeros(8760,1);
perfil_EVSET1_3_adicional = zeros(8760,1);
perfil_EVSET1_4_adicional = zeros(8760,1);
perfil_noservido = zeros(8760,1);
cliente_EVSET1 = zeros(365,suma_clientes_ev);
cliente_noserv = zeros(365,suma_clientes_ev);
flagcambioevse = 0;
promkwkmori = 0.1622;
%matriztipoEV = xlsread('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Origen-destinoV2\Modelo Carga EV\datosEV');
for i = 1:1:suma_clientes_ev %recorre vehiculos
    k = 1; %recorre hora inicio
    m = 24; %recorre hora termino
    for j = 1:1:365 %recorre días del año
        if j > 0 && j < 92 %periodo 1 del año, asumiendo que es verano
            [distanciasTc1, dist] = obtener_dist(Tc1(1),j,i,distancia_real,posicion_EV); % evaluacion de distancias entre Ev y cargadores
            promkwkm = zeros(24,1);
            promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
            if max(perfil_EVSET1_1(k:m,1)) < max_evse1 %si el cargador no est lleno -->
                perfil_EVSET1_1(k:m,1) = perfil_EVSET1_1(k:m,1) + perfil_nodoEVGA(k:m,i); %el perfil del cargador sera el anterior más el nuevo vehiculo
                perfil_EVSET1_1_adicional(k:m,1) = perfil_EVSET1_1_adicional(k:m,1) + promkwkm.*distanciasTc1/1000; %se agrega la energía adicional de conducir al punto de carga
                cliente_EVSET1(j,i) = 1;
            else 
                perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                cliente_noserv(j,i) = 1;
            end
            k = k + 24;
            m = m + 24;    
        elseif j > 91 && j < 183
            [distanciasTc1, dist] = obtener_dist(Tc1(2),j,i,distancia_real,posicion_EV);
            promkwkm = zeros(24,1);
            promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
            if max(perfil_EVSET1_2(k:m,1)) < max_evse1
                perfil_EVSET1_2(k:m,1) = perfil_EVSET1_2(k:m,1) + perfil_nodoEVGA(k:m,i);
                perfil_EVSET1_2_adicional(k:m,1) = perfil_EVSET1_2_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000);
                cliente_EVSET1(j,i) = 1;
            else 
                perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                cliente_noserv(j,i) = 1;
            end
            k = k + 24;
            m = m + 24;    
        elseif j > 182 && j < 274
            [distanciasTc1, dist] = obtener_dist(Tc1(3),j,i,distancia_real,posicion_EV);
            promkwkm = zeros(24,1);
            promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
            if max(perfil_EVSET1_3(k:m,1)) < max_evse1
                perfil_EVSET1_3(k:m,1) = perfil_EVSET1_3(k:m,1) + perfil_nodoEVGA(k:m,i);
                perfil_EVSET1_3_adicional(k:m,1) = perfil_EVSET1_3_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000);
                cliente_EVSET1(j,i) = 1;
            else 
                perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                cliente_noserv(j,i) = 1;
            end
            k = k + 24;
            m = m + 24;    
        elseif j > 273 && j < 366
            [distanciasTc1, dist] = obtener_dist(Tc1(4),j,i,distancia_real,posicion_EV);
            promkwkm = zeros(24,1);
            promkwkm(max(find(perfil_nodoEVGA(k:m,i)>0))) = promkwkmori;
            if max(perfil_EVSET1_4(k:m,1)) < max_evse1
                perfil_EVSET1_4(k:m,1) = perfil_EVSET1_4(k:m,1) + perfil_nodoEVGA(k:m,i);
                perfil_EVSET1_4_adicional(k:m,1) = perfil_EVSET1_4_adicional(k:m,1) + promkwkm.*(distanciasTc1/1000);
                cliente_EVSET1(j,i) = 1;
            else 
                perfil_noservido(k:m,1) = perfil_noservido(k:m,1) + perfil_nodoEVGA(k:m,i);
                cliente_noserv(j,i) = 1;
            end
            k = k + 24;
            m = m + 24;        
        end
    end
end
perfil_EVSET1 = [perfil_EVSET1_1, perfil_EVSET1_2, perfil_EVSET1_3, perfil_EVSET1_4];
perfil_EVSET1_adicional = [perfil_EVSET1_1_adicional, perfil_EVSET1_2_adicional, perfil_EVSET1_3_adicional, perfil_EVSET1_4_adicional];