%% Fitness function
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
%% Zona de pruebas
% x = [3 4 2 18 22 20 20 22] %sol aleatorio caso 1;
%x = [2 2 2 18 22 21 22 22] %sol caso 1 pobl inicial
%x = [2 2 2 2 22 22 22 22];
%% Definición de costos
%Valor dolar $920, valor cambio de empalme = 1.682.922
dolar = 920;
costo_cambioEVSE = 1829;
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
if x(5) == x (6) && x(6) == x(7) && x(7) == x(8)
    costocambioTc2 = costo_cambioEVSE;
elseif (x(5) == x (6) && x(6) == x(7)) || (x(6) == x(7) && x(7) == x(8))
    costocambioTc2 = 2*costo_cambioEVSE;
elseif x(5) == x(6) || x(6) == x(7) || x(7) == x(8)
    costocambioTc2 = 3*costo_cambioEVSE;
else
    costocambioTc2 = 4*costo_cambioEVSE;
end
costocambio = costocambioTc1 + costocambioTc2;
%costocambio = 0;
%% Transformación real a entero del GA
% x = round(x);
% cotainf = [2 2 2 2 19 19 19 19];
% cotasup = [18 18 18 18 33 33 33 33];
% for i = 1:1:length(x)
%     if x(i)>cotasup(i) || x(i)<cotainf(i)
%         costo = 10^9;
%         return
%     end
% end
%% Vectores de cargadores Tc
Tc1 = [x(1) x(2) x(3) x(4)];
Tc2 = [x(5) x(6) x(7) x(8)];
%% Función calculo perfiles de carga rápida para los cargadores en función de posición de EVs en la red
%[perfil_EVSET1_1, perfil_EVSET1_2, perfil_EVSET1_3, perfil_EVSET1_4, perfil_EVSET2_1, perfil_EVSET2_2, perfil_EVSET2_3, perfil_EVSET2_4, perfil_noservido, flagcambioevse, cliente_EVSET1, cliente_EVSET2, cliente_noserv] = funcion_dist(Tc1, Tc2, suma_clientes_ev, distancia_real, perfil_nodoEVGA_rapido, posicion_EV);  
[perfil_EVSETc1, perfil_EVSETc2, perfil_EVSET1_adicional, perfil_EVSET2_adicional, perfil_noservido, flagcambioevse, cliente_EVSET1, cliente_EVSET2, cliente_noserv] = funcion_dist(Tc1, Tc2, suma_clientes_ev, distancia_real, perfil_nodoEVGA_rapido, posicion_EV, max_evse1, max_evse2);  
%perfil_EVSETc1 = [perfil_EVSET1_1, perfil_EVSET1_2, perfil_EVSET1_3, perfil_EVSET1_4];
%perfil_EVSETc2 = [perfil_EVSET2_1, perfil_EVSET2_2, perfil_EVSET2_3, perfil_EVSET2_4];
costo_noserv = sum(sum(perfil_noservido))/1000*96;
costo_tiempo_perdido = 0;
costo_cambioevse = flagcambioevse*costo_tiempo_perdido;
%% Iniciar OPENDSS
    DSSobj = actxserver ('OpenDSSEngine.DSS');
if ~DSSobj.Start(0)
    disp('Unable to start DSS');
    return
end
%% Control OPENDSS %%DSSText = DSSobj.Text;
datapath = "C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 33 v4\Datos DSS";
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
    DSSText.Command= 'new storage.EV1_'+string(i)+' bus1='+string(Tc1(i))+'.1.2.3 phases=3 conn=wye kV=12.6 kWrated=40 kvar=0 model=1 yearly=perfilbatt'+string(i)+' dispmode=follow %Charge=100 %Discharge=100 %EffCharge=90 %EffDischarge=90 %reserve=20 kwhrated=240 enable=yes '; 
end
for i=1:1:length(Tc2)
    DSSText.Command= 'new load.LoadEV2_'+string(i)+' bus1='+string(Tc2(i))+'.1.2.3 phases=3 conn=wye kV=12.6 kW=1 kvar=0 model=1 yearly=perfilEVCS'+ string(4+i)+' status=variable'; 
    DSSText.Command= 'new storage.EV2_'+string(i)+' bus1='+string(Tc2(i))+'.1.2.3 phases=3 conn=wye kV=12.6 kWrated=40 kvar=0 model=1 yearly=perfilbatt'+string(4+i)+' dispmode=follow %Charge=100 %Discharge=100 %EffCharge=90 %EffDischarge=90 %reserve=20 kwhrated=240 enable=yes  '; 
end
DSSText.command= 'compile "'+datapathns+'\monitores"';
for i=1:1:length(Tc1)
    DSSText.Command= 'new monitor.monitorvolEV1_'+string(i)+' element=load.LoadEV1_'+string(i)+ ' Terminal=1 mode=0 ppolar=no ';
    DSSText.Command= 'new monitor.monitorpowEV1_'+string(i)+' element=load.LoadEV1_'+string(i)+ ' Terminal=1 mode=1 ppolar=no ';
    DSSText.Command= 'new monitor.monitorvolbatt1_'+string(i)+' element=storage.EV1_'+string(i)+ ' Terminal=1 mode=0 ppolar=no ';
    DSSText.Command= 'new monitor.monitorpowbatt1_'+string(i)+' element=storage.EV1_'+string(i)+ ' Terminal=1 mode=1 ppolar=no ';
    DSSText.Command= 'new monitor.monitorstatebatt1_'+string(i)+' element=storage.EV1_'+string(i)+ ' Terminal=1 mode=7 ppolar=no ';
end
for i=1:1:length(Tc2)
    DSSText.Command= 'new monitor.monitorvolEV2_'+string(i)+' element=load.LoadEV2_'+string(i)+ ' Terminal=1 mode=0 ppolar=no ';
    DSSText.Command= 'new monitor.monitorpowEV2_'+string(i)+' element=load.LoadEV2_'+string(i)+ ' Terminal=1 mode=1 ppolar=no ';
    DSSText.Command= 'new monitor.monitorvolbatt2_'+string(i)+' element=storage.EV2_'+string(i)+ ' Terminal=1 mode=0 ppolar=no ';
    DSSText.Command= 'new monitor.monitorpowbatt2_'+string(i)+' element=storage.EV2_'+string(i)+ ' Terminal=1 mode=1 ppolar=no ';
    DSSText.Command= 'new monitor.monitorstatebatt2_'+string(i)+' element=storage.EV2_'+string(i)+ ' Terminal=1 mode=7 ppolar=no ';
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
    name = 'perfilbatt'+string(i);
    DSSLoadshape.name = name;
    feature('COM_SafeArraySingleDim',1);
    DSSLoadshape.Pmult = zeros(8760,1);
    feature('COM_SafeArraySingleDim',0);
end
%% Perfiles por periodo
intervalo = ["1:2190" "2191:4380" "4381:6570" "6571:8760"]; 
for i = 1:1:length(Tc1)
    name = 'perfilevcs'+string(i);
    DSSLoadshape.name = name;
    feature('COM_SafeArraySingleDim',1);
    DSSLoadshape.Pmult = perfil_EVSETc1(:,i)+perfil_EVSET1_adicional(:,i);
    feature('COM_SafeArraySingleDim',0);
    name = 'perfilbatt'+string(i);
    DSSLoadshape.name = name;
    tempshape1 = zeros(1,8760);
    tempshape1(1,str2num(char(intervalo(i)))) = perfilbasebatt1(1,str2num(char(intervalo(i))));
    tempshape1 = transpose(tempshape1);
    feature('COM_SafeArraySingleDim',1);
    DSSLoadshape.Pmult = tempshape1;
    feature('COM_SafeArraySingleDim',0);
end
%%
for i = 1:1:length(Tc2)
    name = 'perfilevcs'+string(4+i);
    DSSLoadshape.name = name;
    tempshape2 = zeros(1,8760);
    tempshape2(1,str2num(char(intervalo(i)))) = perfilbaseev2(1,str2num(char(intervalo(i))));
    tempshape2 = transpose(tempshape2);
    feature('COM_SafeArraySingleDim',1);
    DSSLoadshape.Pmult = perfil_EVSETc2(:,i) +perfil_EVSET2_adicional(:,i);
    feature('COM_SafeArraySingleDim',0);
    name = 'perfilbatt'+string(4+i);
    DSSLoadshape.name = name;
%     if sum(DSSLoadshape.Pmult)>0
%         tempshape2 = DSSLoadshape.Pmult;
%     else
    tempshape2 = zeros(1,8760);
%     end
    tempshape2(1,str2num(char(intervalo(i)))) = perfilbasebatt2(1,str2num(char(intervalo(i))));
    tempshape2 = transpose(tempshape2);
%     perfilescreados(i) = tempshape;
    feature('COM_SafeArraySingleDim',1);
    DSSLoadshape.Pmult = tempshape2;
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
% maxdem = max(sumpot);
% for i = 1:1:size(sumpot,2)
%     if sumpot(i)>0
%         costopot(i) = 81.799*(sumpot(i)/1000); %% Precio nudo promedio enel 81.799usd/mwh
%     else
%         costopot(i) = 0;
%     end
% end
% costopotanual = sum(costopot);

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
matovA = zeros(8760,33);
matovB = zeros(8760,33);
matovC = zeros(8760,33);
matuvA = zeros(8760,33);
matuvB = zeros(8760,33);
matuvC = zeros(8760,33);
for j = 1:1:33
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
%costo = costopotanual+costov+costoI+costocambio;
costo = costodemanda+costoI+costov+costocambio+costo_noserv+costo_cambioevse;
return
    