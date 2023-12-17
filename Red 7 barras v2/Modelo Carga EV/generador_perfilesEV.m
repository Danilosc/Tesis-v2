% Generador de perfiles de carga de vehiculos eléctricos. solo considera
% los metodos de carga rápida de hasta 50kW, teniendo en consideración
% asignación aleatoria de vehiculos a usuarios de la red y los datos de la
% encuesta origen-destino de Santiago para cuantificar la cantidad de
% viajes x persona al día, los tiempos de viaje y las distancias
% recorridas.
%% Configuración de usuario
clear all
Nevs = input('Cantidad de EVs en la red (aprox 4000): ');
P_carga_dom = input('Probabilidad de carga domiciliaria [%] ?: '); %porcentaje de carga domiciliaria
[Info_viajes, Datos_viajes] = Filtro_datos_EOD(10,0.1,50,1,100,1,'s');%Función filtro EOD (Tmax(h), Tmin(h), Vmax (km/h), Vmin(km/h), Dmax(km), Dmin(km), guardar ('s' o 'n') 
dataviajes_aux = [Info_viajes(:,5) Info_viajes(:,6) Info_viajes(:,7) Info_viajes(:,4)];
%% Exportar datos tipos EVs
% se consideran ciertos modelos de EVs con distintas capacidades de
% batería, autonomias, pero todas con potencias de carga de al menos 50kW.
[~, ~, raw] = xlsread('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Modelo Carga EV\datosEV.xlsx','Sheet1','A2:E6');
stringVectors = string(raw(:,1));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[2,3,4,5]);
data = reshape([raw{:}],size(raw));
datosEV = table;
datosEV.ModeloEV = stringVectors(:,1);
datosEV.Bateriakwh = data(:,1);
datosEV.Bateriautil = data(:,2);
datosEV.Autonomiakm = data(:,3);
datosEV.PotMaximaCargakw = data(:,4);
clearvars data raw stringVectors;
%% Asignar tipo de vehiculo a usuarios
user_EV = string([]);
for i = 1:1:Nevs
    user_EV(i) = string(datosEV.ModeloEV(random('Discrete Uniform',height(datosEV)))); %se asigna un vehiculo aleatorio (uniforme discreto) de la lista a cada usuario
end
%% Asignar SoC inicial a cada vehiculo (se puede imponer un valor o se puede asignar aleatoriamente)
for i=1:1:Nevs
    x= 1 - random('Half Normal',0,0.2);
    if x > 1
        Soc_ini(i) = 1;
    elseif x < 0.2
        Soc_ini(i) = 0.2;
    else
        Soc_ini(i) = x;
    end
end
Soc_comprobacion_ini = Soc_ini;
clearvars x i j k 
%Soc_ini = ones(1,Nevs); %se impone soc inicial del 100% para el modelo
%% Asignar cantidad de viajes x vehiculo
%se asigna de una cantidad de viajes a cada usuario al día. Estos datos se
%escogen aleatoriamente (discreta uniforme) de la matriz origen destino,
%pero la distribución real es cercana a un valor extremo en 2 viajes.
semana = ["dom" "lun" "mar" "mie" "jue" "vie" "sab" "dom"];
k = 1;
for i = 1:1:365
    if k > 7
        k = 1;
        dianual(i) = semana(k);
        k = k+1;
    else
        dianual(i) = semana(k);
        k = k+1;
    end
end
%%
for i = 1:1:Nevs
    for j = 1:1:365
        if dianual(j) == "sab" || dianual(j) == "dom"
            ViajexEV(j,i) = Datos_viajes(random('Discrete Uniform',size(Datos_viajes,1)),2)-1;
            if ViajexEV(j,i) > 10
                ViajexEV(j,i) = 10;
            end
        else
            ViajexEV(j,i) = Datos_viajes(random('Discrete Uniform',size(Datos_viajes,1)),2);
            if ViajexEV(j,i) > 10
                ViajexEV(j,i) = 10;
            end
        end
    end
end
%% 
data_viajes = dataviajes_aux;
data_viajes(:,1) = round(data_viajes(:,1));
data_viajes(data_viajes==0) = 24;
data_viajes(:,2) = data_viajes(:,1)+data_viajes(:,3);
k = 1;
for i = 1:1:size(data_viajes,1)
    if data_viajes(i,2) < 24
        data_viajes1(k,:) = data_viajes(i,:);
        k = k+1;
    end
end
%% Creacion de perfiles
eficiencia = [0.836 0.872] ; %eficiencia de carga de los [Eff domiciliaria, eficiencia rápida] EV
matriz_SoC = zeros(8760,Nevs);
matriz_carga = zeros(8760,Nevs);
matriz_carga_dom = zeros(365,Nevs);
matriz_km_hora = zeros(8760,Nevs);
matriz_E_hora = zeros(8760,Nevs);
matriz_viaje_anual = zeros(8760,Nevs);
flag_ant = 0;
for i = 1:1:Nevs %cantidad de perfiles Nevs
    horai = 1;
    horaj = 24;
    for j = 1:1:365 %dias del año
        matriz_viaje = generador_matriz_dias(ViajexEV(j,i),data_viajes1); %entrega info de cantidad, duración y distancia de viaje del usuario i para el dia j
        [SocEV, CargaEV, SoC_Fin, info_dia_ev, CargaEV_dom, flag_dom,vector_viaje,matriz_resumen_anual] = Perfil_EV_diario(Soc_ini(i),matriz_viaje,user_EV(i),eficiencia,datosEV.Bateriakwh, datosEV.Bateriautil,datosEV.Autonomiakm,datosEV.PotMaximaCargakw,P_carga_dom,flag_ant);
        matriz_SoC(horai:horaj,i) = SocEV;
        matriz_carga(horai:horaj,i) = CargaEV;
        matriz_km_hora(horai:horaj,i) = info_dia_ev(:,1);
        matriz_E_hora(horai:horaj,i) = info_dia_ev(:,2);
        matriz_viaje_anual(horai:horaj,i) = vector_viaje;
        matriz_carga_dom(horai:horaj,i) = CargaEV_dom;
        %resumen_anual(horai:horaj,:) = matriz_resumen_anual;
        Soc_ini(i) = SoC_Fin;
        flag_ant = flag_dom;
        horai = horai + 24;
        horaj = horaj + 24;
        contadori = i
        contadorj = j
    end
end
%% Comprobacion y errores energía
E_anual_cargada = sum(matriz_carga_dom).*eficiencia(1,1)+sum(matriz_carga).*eficiencia(1,2);
E_anual_consumida = sum(matriz_carga_dom)+sum(matriz_carga);
E_anual_viajes = sum(matriz_E_hora);
Delta_E = E_anual_cargada - E_anual_viajes;
Delta_SoC = Soc_comprobacion_ini(1,:) - matriz_SoC(8760,:);
for i = 1:1:length(Delta_E)
    if user_EV(i) == "Nissan Leaf V1"
        delta_soc_E(i) = Delta_SoC(i)*40;
    elseif user_EV(i) == "Nissan Leaf V2"
        delta_soc_E(i) = Delta_SoC(i)*62;
    elseif user_EV(i) == "Hyundai Ioniq EV"
        delta_soc_E(i) = Delta_SoC(i)*40.4;
    elseif user_EV(i) == "BMW i3"
        delta_soc_E(i) = Delta_SoC(i)*42.2;
    elseif user_EV(i) == "Renault Zoe"
        delta_soc_E(i) = Delta_SoC(i)*54.7;
    end
end
comprobacion = Delta_E + delta_soc_E;
errores = length(find(comprobacion>0.01));
maxerror = max(comprobacion);
%% Elimincación de errores
k = 1;
x = 1;
ind = find(comprobacion>0.01);
matriz_carga_def = matriz_carga;
matriz_carga_def(:,ind) = [];
matriz_carga_dom_def = matriz_carga_dom;
matriz_carga_dom_def(:,ind) = [];
matriz_SoC_def = matriz_SoC;
matriz_SoC_def(:,ind) = [];
matriz_km_hora_def = matriz_km_hora;
matriz_km_hora_def(:,ind) = [];
matriz_E_hora_def = matriz_E_hora;
matriz_E_hora_def(:,ind) = [];
matriz_viaje_anual_def = matriz_viaje_anual;
matriz_viaje_anual_def(:,ind) = [];
user_EV_def = user_EV;
user_EV_def(:,ind) = [];
%% Transformar tipo EV a codigo numerico 
%Nissan Leaf V1 = 1, Nissan Leaf V2 = 2, Hyundai = 3, BMW = 4, Renault = 5
for i = 1:1:length(user_EV_def)
    if user_EV_def(i) == 'Nissan Leaf V1'
        user_id(i) = 1;
    elseif user_EV_def(i) == 'Nissan Leaf V2'
        user_id(i) = 2;
    elseif user_EV_def(i) == 'Hyundai Ioniq EV'
        user_id(i) = 3;
    elseif user_EV_def(i) == 'BMW i3'
        user_id(i) = 4;
    else
        user_id(i) = 5;
    end
end
%% Post proceso
% xlswrite('Perfiles_EV_Anual.xlsx',matriz_carga);
% xlswrite('matriz_SoC_anual.xlsx',matriz_SoC);
caso = '_Nev' + string(Nevs) + '_Pdom' + string(P_carga_dom);
csvwrite('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Modelo Carga EV\Casos\Perfiles_EV_rapido' + caso + '.csv',matriz_carga_def);
csvwrite('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Modelo Carga EV\Casos\Perfiles_EV_domiciliario' + caso + '.csv',matriz_carga_dom_def);
csvwrite('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Modelo Carga EV\Casos\matriz_SoC_anual' + caso + '.csv',matriz_SoC_def);
csvwrite('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Modelo Carga EV\Casos\matriz_E_dia' + caso + '.csv',matriz_E_hora_def);
csvwrite('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Modelo Carga EV\Casos\matriz_km_dia' + caso + '.csv',matriz_km_hora_def);
csvwrite('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Modelo Carga EV\Casos\user_EV' + caso + '.csv',user_id);


