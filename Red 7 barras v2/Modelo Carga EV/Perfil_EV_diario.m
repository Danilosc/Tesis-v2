%función que se encarga de entregar la información diaria del estado de
%carga  del vehiculo, la energía cargada y el SoC final del día.
function [Soc_EV,Carga_EV,Soc_Fin,info_dia_ev, Carga_EV_domicilio, flag_dom,vector_viaje,matriz_resumen_anual] = Perfil_EV_diario(Soc_ini, viajesxdia, user_EV, eficiencia_carga, Bateriakwh, Bateriautil, Autonomiakm,PotMaximaCargakw,P_carga_dom, flag_dom_ant)

%% Vectores de SoC y Hora
Soc_EV = zeros(26,1);
Carga_EV = zeros(26,1);
Carga_EV_domicilio = zeros(26,1);
vector_viaje = zeros(24,1);
P_carga_dom = P_carga_dom/100;
%viajesxdia(:,3) = viajesxdia(:,3)./60; %transformar a horas
%% juntar viajes muy cercanos
c2 = [round(viajesxdia(:,1)), viajesxdia(:,4),viajesxdia(:,3)]; %si hay viajes muy cercanos entre si, se unen en uno solo por simplicidad de calculo ej: 8:30 + 9:15
for i = 1:1:size(c2,1) %convierte horas 0 a 24 (para el calculo)
    if c2(i,1) == 0
        c2(i,1) = 24;
    end
end
c2_unico = unique(c2(:,1));
for i=1:1:length(c2_unico)
    sum_var = 0;
    tem_var = 0;
    xindice = find(c2_unico(i)==c2(:,1));
    for j = 1:1:length(xindice)
        sum_var = sum_var + c2(xindice(j),2);
        tem_var = tem_var + c2(xindice(j),3);
    end
    c2_unico(i,2) = sum_var;
    c2_unico(i,3) = tem_var;
end
%Matriz_resumen = [hora_ini, kilometros, duracion, energia]
matriz_resumen = [c2_unico(:,1), c2_unico(:,2), c2_unico(:,3), zeros(length(c2_unico(:,1)),1)]; %resumen de las operaciones hechas. Juntar viajes cercanos y corregir tiempos de viaje
%% Calculo de energía x viaje EV
% Entrega información tecnica de los EVs en función del que posee el
% usuario
for i = 1:1:length(matriz_resumen(:,1))
    if user_EV == "Nissan Leaf V1"
        E_km = Bateriakwh(1)/Autonomiakm(1); %energia x km
        matriz_resumen(i,4) = matriz_resumen(i,2)*E_km; %energia x viaje
        Soc_min = 0.2;
        bateria_util = Bateriakwh(1); %Capacidad real de batería
        Potmax = PotMaximaCargakw(1); %Potencia máxima de carga
    elseif user_EV == "Nissan Leaf V2"
        E_km = Bateriakwh(2)/Autonomiakm(2);
        matriz_resumen(i,4) = matriz_resumen(i,2)*E_km;
        Soc_min = 0.2;
        bateria_util = Bateriakwh(2);
        Potmax = PotMaximaCargakw(2);
    elseif user_EV == "Hyundai Ioniq EV"
        E_km = Bateriakwh(3)/Autonomiakm(3);
        matriz_resumen(i,4) = matriz_resumen(i,2)*E_km;
        Soc_min = 0.2;
        bateria_util = Bateriakwh(3);
        Potmax = PotMaximaCargakw(3);
    elseif user_EV == "BMW i3"
        E_km = Bateriakwh(4)/Autonomiakm(4);
        matriz_resumen(i,4) = matriz_resumen(i,2)*E_km;
        Soc_min = 0.2;
        bateria_util = Bateriakwh(4);
        Potmax = PotMaximaCargakw(4);
    elseif user_EV == "Renault Zoe"
        E_km = Bateriakwh(5)/Autonomiakm(5);
        matriz_resumen(i,4) = matriz_resumen(i,2)*E_km;
        Soc_min = 0.2;
        bateria_util = Bateriakwh(5);
        Potmax = PotMaximaCargakw(5);
    end
end
%% Vector de viajes x dia
vector_energia = zeros(24,1);
vector_tiempo = zeros(24,1);
x = 1;
f = 1;
for i = 1:1:24
    if matriz_resumen(x,1) == i && f == 1
        if matriz_resumen(x,3)<=1
            vector_viaje(matriz_resumen(x,1)) = 1; %El vector viaje indica si existe viaje en la hora indicada
            vector_energia(matriz_resumen(x,1)) = matriz_resumen(x,4); %El vector energía indica la energía consumida en la hora de viaje
            vector_tiempo(matriz_resumen(x,1)) = matriz_resumen(x,3); 
        elseif matriz_resumen(x,3)>1 && matriz_resumen(x,3)<=2
            for j = 0:1:1
                vector_viaje(matriz_resumen(x,1)+j) = 1; %si el viaje dura más de una hora, se pone un 1 por cada hora de viaje aproximada en el vector
                vector_energia(matriz_resumen(x,1)+j) = matriz_resumen(x,4)/2; %La energía total del viaje se reparte en partes iguales a las hora de viaje
                vector_tiempo(matriz_resumen(x,1)+j) = matriz_resumen(x,3)/2; 
            end
        elseif matriz_resumen(x,3)>2 && matriz_resumen(x,3)<=3
            for j = 0:1:2
                vector_viaje(matriz_resumen(x,1)+j) = 1;
                vector_energia(matriz_resumen(x,1)+j) = matriz_resumen(x,4)/3;
                vector_tiempo(matriz_resumen(x,1)+j) = matriz_resumen(x,3)/3; 
            end
        elseif matriz_resumen(x,3)>3 && matriz_resumen(x,3)<=4
            for j = 0:1:3
                vector_viaje(matriz_resumen(x,1)+j) = 1;
                vector_energia(matriz_resumen(x,1)+j) = matriz_resumen(x,4)/4;
                vector_tiempo(matriz_resumen(x,1)+j) = matriz_resumen(x,3)/4; 
            end   
        elseif matriz_resumen(x,3)>4 && matriz_resumen(x,3)<=5
            for j = 0:1:4
                vector_viaje(matriz_resumen(x,1)+j) = 1;
                vector_energia(matriz_resumen(x,1)+j) = matriz_resumen(x,4)/5;
                vector_tiempo(matriz_resumen(x,1)+j) = matriz_resumen(x,3)/5; 
            end  
        elseif matriz_resumen(x,3)>5 && matriz_resumen(x,3)<=6
            for j = 0:1:5
                vector_viaje(matriz_resumen(x,1)+j) = 1;
                vector_energia(matriz_resumen(x,1)+j) = matriz_resumen(x,4)/6;
                vector_tiempo(matriz_resumen(x,1)+j) = matriz_resumen(x,3)/6; 
            end  
         elseif matriz_resumen(x,3)>6 && matriz_resumen(x,3)<=7
            for j = 0:1:6
                vector_viaje(matriz_resumen(x,1)+j) = 1;
                vector_energia(matriz_resumen(x,1)+j) = matriz_resumen(x,4)/7;
                vector_tiempo(matriz_resumen(x,1)+j) = matriz_resumen(x,3)/7; 
            end  
             elseif matriz_resumen(x,3)>7 && matriz_resumen(x,3)<=8
            for j = 0:1:7
                vector_viaje(matriz_resumen(x,1)+j) = 1;
                vector_energia(matriz_resumen(x,1)+j) = matriz_resumen(x,4)/8;
                vector_tiempo(matriz_resumen(x,1)+j) = matriz_resumen(x,3)/8; 
            end  
        elseif matriz_resumen(x,3)>8 && matriz_resumen(x,3)<=9
            for j = 0:1:8
                vector_viaje(matriz_resumen(x,1)+j) = 1;
                vector_energia(matriz_resumen(x,1)+j) = matriz_resumen(x,4)/9;
                vector_tiempo(matriz_resumen(x,1)+j) = matriz_resumen(x,3)/9; 
            end  
         elseif matriz_resumen(x,3)>9 && matriz_resumen(x,3)<=10
            for j = 0:1:9
                vector_viaje(matriz_resumen(x,1)+j) = 1;
                vector_energia(matriz_resumen(x,1)+j) = matriz_resumen(x,4)/10;
                vector_tiempo(matriz_resumen(x,1)+j) = matriz_resumen(x,3)/10; %el maximo de horas de viaje encontrada son 10
            end 
        end
        x = x+1;
        if x > size(matriz_resumen,1)
            f = 0;
            x = size(matriz_resumen,1);
        end
    else
        if vector_viaje(i) ~= 1
            vector_viaje(i) = 0;
            vector_energia(i) = 0;
            vector_tiempo(i) = 0;  
        end
    end
end
vector_viaje = [0 ; vector_viaje ; 0];
vector_energia = [0; vector_energia ; 0];
vector_tiempo = [0; vector_tiempo ; 0];
%% Establecer energías máximas de carga y tiempos de carga.
tiempo_carga = ones(1,26);
Emax_carga = ones(1,26);
j = 1;
for i =  1:1:26
    if vector_viaje(i) == 1
        tiempo_carga(i) = (1 - vector_tiempo(i))*0.9;
        Emax_carga(i) = tiempo_carga(i)*Potmax; 
        j = j+1;
    else
        tiempo_carga(i) = tiempo_carga(i)*0.9; %Se establece un tiempo menor de carga para coonsiderar el tiempo de viaje aprox hacia el cargador.
        Emax_carga(i) = tiempo_carga(i)*Potmax; 
    end
end
%% Decidir si es carga domiciliaria o carga rápida.
p = random('binomial',1,P_carga_dom);
%p = 1;
Emax_dom = 3.3;
eff_carga_dom = eficiencia_carga(1,1);
eficiencia_carga_rapida = eficiencia_carga(1,2);
%% Carga Domiciliaria
flagcarga = flag_dom_ant;
if p == 1
    [Soc_EV,Carga_EV,Carga_EV_domicilio,flag_dom,Soc_Fin] = carga_dom(Soc_ini, eficiencia_carga_rapida, eff_carga_dom, bateria_util, Soc_min, vector_viaje, vector_energia, Emax_dom, Emax_carga, tiempo_carga, flagcarga);
else
    [Soc_EV,Carga_EV,Soc_Fin,Carga_EV_domicilio] = carga_rapida(Soc_ini, eficiencia_carga_rapida, bateria_util, Soc_min, vector_viaje, vector_energia, Emax_carga, tiempo_carga);
    flag_dom = 0;
end
Carga_EV(26) = [];
Carga_EV(1) = [];
Soc_EV(26) = [];
Soc_EV(1) = [];
Carga_EV_domicilio(26) = [];
Carga_EV_domicilio(1) = [];
vector_viaje(26) = [];
vector_viaje(1) = [];
%%
info_km = zeros(24,1);
info_E = zeros(24,1);
matriz_resumen_anual = zeros(24,4);
j = 1;
for i = 1:1:24
    if i == matriz_resumen(j,1)
        info_km(i) = matriz_resumen(j,2);
        info_E(i) = matriz_resumen(j,4);
        matriz_resumen_anual(i,:) = matriz_resumen(j,:);
        
        j = j+1;
        if j > size(matriz_resumen,1)
            j = size(matriz_resumen,1);
        end
    else
        info_km(i) = 0;
        info_E(i) = 0;
        matriz_resumen_anual(i,:) = zeros(1,4);
    end
end
info_dia_ev = [info_km, info_E];

return

