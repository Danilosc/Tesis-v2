%% Fitness function 7barras
%function [perdidas, maxvol, minvol, maxcorr, costo] = fitnes(x)
function costo = fitnesentero(x)
%% Definición variables globales
global Iamps
global posicion_EV
global coordenadas
global distancia_real
global perfil_nodoEVGA_rapido
global suma_clientes_ev
global perfil_nodoEVGA_dom
global Perfiles_carga
global tipo_EV
global max_evse1
global max_evse2
%x = [2 2 2 2];
%% Definición de costos
%Valor dolar $920, valor cambio de empalme = 1.682.922
dolar = 920;
costo_cambioEVSE = 0; %agregar 1829 si se considera el costo
costofalla = (500*12*63515/8760)/dolar; %% Costo de multa mensuak = 500UTM / 1 UTM = 63.515 Costo falla = 12*500UTM / 8760
if x(1) == x (2) && x(2) == x(3) && x(3) == x(4)
    costocambioTc1 = costo_cambioEVSE;
elseif (x(1) == x (2) && x(2) == x(3)) || (x(2) == x(3) && x(3) == x(4))
    costocambioTc1 = 2*costo_cambioEVSE;
elseif x(1) == x(2) || x(2) == x(3) || x(3) == x(4)
    costocambioTc1 = 3*costo_cambioEVSE;
else
    costocambioTc1 = 4*costo_cambioEVSE;
end
costocambio = costocambioTc1;
%% Conversión columna decimal
T1 = x(1);
T2 = x(2);
T3 = x(3);
T4 = x(4);
Tc1 = [T1 T2 T3 T4];
%% Función calculo perfiles de carga rápida para los cargadores en función de posición de EVs en la red
[perfil_EVSETc1, perfil_EVSET1_adicional, perfil_noservido, flagcambioevse, cliente_EVSET1, cliente_noserv] = funcion_dist(Tc1, suma_clientes_ev, distancia_real, perfil_nodoEVGA_rapido, posicion_EV, max_evse1);  
costo_noserv = sum(sum(perfil_noservido))/1000*96;
costo_tiempo_perdido = 0;
costo_cambioevse = flagcambioevse*costo_tiempo_perdido;
%% Inicio OPENDSS
%% Iniciar OPENDSS
    DSSobj = actxserver ('OpenDSSEngine.DSS');
if ~DSSobj.Start(0)
    disp('Unable to start DSS');
    return
end
%% Control OPENDSS %%DSSText = DSSobj.Text;
datapath = "C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Datos DSS";
datapathns = datapath;
datapath = '"'+datapath+'"';
DSSText = DSSobj.Text; 
DSSobj.AllowForms = false;
DSSCircuit = DSSobj.ActiveCircuit; 
DSSLines = DSSCircuit.Lines;
DSSLoads = DSSCircuit.Loads;
DSSLoadshape = DSSCircuit.LoadShapes;
DSSMonitors = DSSCircuit.Monitors;
DSSText.Command= 'compile "'+datapathns+'\InicializaciónDSS"';
DSSText.Command= 'compile "'+datapathns+'\trafos"';
DSSText.Command= 'compile "'+datapathns+'\datosDSS"';
DSSText.command= 'compile "'+datapathns+'\Lineas"';
for i=1:1:length(Tc1)
    DSSText.Command= 'new load.LoadEV1_'+string(i)+' bus1='+string(Tc1(i))+'.1.2.3 phases=3 conn=wye kV=12.6 kW=1 kvar=0 model=1 yearly=perfilEVCS'+ string(i)+' status=variable';
    %DSSText.Command= 'new storage.EV1_'+string(i)+' bus1='+string(Tc1(i))+'.1.2.3 phases=3 conn=wye kV=12.6 kW=1 kvar=0 model=1 yearly=perfilbatt'+string(i)+' dispmode=follow %Charge=100 %Discharge=100 %EffCharge=90 %EffDischarge=90 %reserve=20 kwhrated=50 enable=no '; 
end
DSSText.command= 'compile "'+datapathns+'\monitores"';
for i=1:1:length(Tc1)
    DSSText.Command= 'new monitor.monitorvolEV1_'+string(i)+' element=load.LoadEV1_'+string(i)+ ' Terminal=1 mode=0 ppolar=no ';
    DSSText.Command= 'new monitor.monitorpowEV1_'+string(i)+' element=load.LoadEV1_'+string(i)+ ' Terminal=1 mode=1 ppolar=no ';
    %DSSText.Command= 'new monitor.monitorvolbatt1_'+string(i)+' element=storage.EV1_'+string(i)+ ' Terminal=1 mode=0 ppolar=no ';
    %DSSText.Command= 'new monitor.monitorpowbatt1_'+string(i)+' element=storage.EV1_'+string(i)+ ' Terminal=1 mode=1 ppolar=no ';
    %DSSText.Command= 'new monitor.monitorstatebatt1_'+string(i)+' element=storage.EV1_'+string(i)+ ' Terminal=1 mode=7 ppolar=no ';
end

%% Obtener Perfiles originales
DSSLoadshape.name = 'perfilevcs1';
perfilbaseev1 = DSSLoadshape.Pmult;
DSSLoadshape.name = 'perfilevcs5';
perfilbaseev2 = DSSLoadshape.Pmult;
DSSLoadshape.name = 'perfilbatt1';
perfilbasebatt1 = DSSLoadshape.Pmult;
DSSLoadshape.name = 'perfilbatt5';
perfilbasebatt2 = DSSLoadshape.Pmult;
%% Reiniciar Perfiles
for i = 1:1:8
    name = 'perfilevcs'+string(i);
    DSSLoadshape.name = name;
    feature('COM_SafeArraySingleDim',1);
    DSSLoadshape.Pmult = zeros(8760,1);
    feature('COM_SafeArraySingleDim',0);
%     name = 'perfilbatt'+string(i);
%     DSSLoadshape.name = name;
%     feature('COM_SafeArraySingleDim',1);
%     DSSLoadshape.Pmult = zeros(8760,1);
%     feature('COM_SafeArraySingleDim',0);
end
%% Perfiles por periodo
intervalo = ["1:2190" "2191:4380" "4381:6570" "6571:8760"]; 
for i = 1:1:length(Tc1)
    name = 'perfilevcs'+string(i);
    DSSLoadshape.name = name;
    feature('COM_SafeArraySingleDim',1);
    DSSLoadshape.Pmult = perfil_EVSETc1(:,i)+perfil_EVSET1_adicional(:,i);
    feature('COM_SafeArraySingleDim',0);
end

%% solve
DSSText.Command='Solve';
%% Calculo pérdidas
DSSMeters = DSSCircuit.Meters;
idmeter = DSSMeters.AllNames;
DSSMeters.Name = string(idmeter(1));
registrometer= DSSMeters.Totals;
Total_perdidas = registrometer(13);
Total_demanda = registrometer(1)+registrometer(29);
perdidas = (Total_perdidas/Total_demanda)*100;
DSSMonitors.Name = 'monitortpownodotf1';
powtrafofase1 = DSSMonitors.Channel(1);
powtrafofase2 = DSSMonitors.Channel(3);
powtrafofase3 = DSSMonitors.Channel(5);
%% Medicion de potencia x hora
sumpot = powtrafofase1+powtrafofase2+powtrafofase3;
% plot(sumpot)
maxdem = max(sumpot);
for i = 1:1:size(sumpot,2)
    if sumpot(i)>0
        costopot(i) = 81.799*(sumpot(i)/1000); %% Precio nudo promedio enel 81.799usd/mwh
    else
        costopot(i) = 0;
    end
end
costopotanual = sum(costopot);

%% Obtener voltajes de nodos
DSSMonitors = DSSCircuit.Monitors;
idmonitor = DSSMonitors.allNames;
conmonitor = contains(idmonitor,'vollin');
j=1;
for i=1:1:length(conmonitor)
    if conmonitor(i) == 1
        DSSMonitors.Name = string(idmonitor(i));
        matrizvolA(:,j) = DSSMonitors.Channel(1);
        matrizvolB(:,j) = DSSMonitors.Channel(3);
        matrizvolC(:,j) = DSSMonitors.Channel(5);
        j = j+1;
    end
end
matrizvolA = matrizvolA./(12600/sqrt(3));
matrizvolB = matrizvolB./(12600/sqrt(3));
matrizvolC = matrizvolC./(12600/sqrt(3));

%% Determinar horas con sobrevoltaje y con bajo voltaje
matovA = zeros(8760,6);
matovB = zeros(8760,6);
matovC = zeros(8760,6);
matuvA = zeros(8760,6);
matuvB = zeros(8760,6);
matuvC = zeros(8760,6);
for j = 1:1:6
    for i = 1:1:8760
        if matrizvolA(i,j)>1.1
            matovA(i,j) = 1;
        end
        if matrizvolA(i,j)<0.9
            matuvA(i,j) = 1;
        end
        if matrizvolB(i,j)>1.1
            matovB(i,j) = 1;
        end
        if matrizvolB(i,j)<0.9
            matuvB(i,j) = 1;
        end
        if matrizvolC(i,j)>1.1
            matovC(i,j) = 1;
        end
        if matrizvolC(i,j)<0.9
            matuvC(i,j) = 1;
        end
    end
end
matov = matovA + matovB + matovC;
matuv = matuvA + matuvB + matuvC;
matov(matov>1) = 1;
matuv(matuv>1) = 1;
horasov = sum(sum(matov));
horasuv = sum(sum(matuv));
%% Determinación de operacion anomala de tensión
%% costo voltajes altos y bajo
costov = costofalla*(horasov+horasuv);
%% Determinar sobrecorrientes
conmonitor = contains(idmonitor,'vollin');
j=1;
for i=1:1:length(conmonitor)
    if conmonitor(i) == 1
        DSSMonitors.Name = string(idmonitor(i));
        matrizcorrientesA(:,j) = DSSMonitors.Channel(7);
        matrizcorrientesB(:,j) = DSSMonitors.Channel(9);
        matrizcorrientesC(:,j) = DSSMonitors.Channel(11);
        j = j+1;
    end
end
maxconductores = transpose((Iamps));
maxcurrA = max(matrizcorrientesA);
maxcurrB = max(matrizcorrientesB);
maxcurrC = max(matrizcorrientesC);
costoI = 0;
for i=1:1:length(maxconductores)
    if maxcurrA(i)>maxconductores(i)
        costoI = costofalla+costoI;
    elseif maxcurrB(i)>maxconductores(i)
        costoI = costofalla+costoI;
    elseif maxcurrC(i)>maxconductores(i)
        costoI = costofalla+costoI;
    end
end
costoperdidas = Total_perdidas/1000*96;
costodemanda = Total_demanda/1000*96;
costo = costodemanda+costoI+costov+costocambio+costo_noserv+costo_cambioevse%+1829 %Si no se considera costo cambio, se agrega 1 para la colocación inicial;
return