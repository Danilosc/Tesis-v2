%% Fitness function 7barras
%function [perdidas, maxvol, minvol, maxcorr, costo] = fitnes(x)
%function costo = fitnesentero(x)
clear all
nperfiles = input('Número de perfiles originales EV: ');
porcperfdom = input('Porcentaje perfiles EV domiciliario (%): ');
porcEV = input('Porcentaje de penetración EV en la red (%): ');
distribucion = input('Distribución de los vehiculos (AL / UN): ');
caso = '_Nev'+string(nperfiles)+'_Pdom'+string(porcperfdom);
if distribucion == 'AL'
    casopen = caso + '_EVAL'+string(porcEV);
else
    casopen = caso + '_EV'+string(porcEV);
end
carpeta = "C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Creación Información de Nodos\";
carpetacaso = carpeta + casopen;
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
x = [5 5 5 5];
%% importar coordenadas
coordenadas = xlsread(carpeta + '\coordenadas'+caso+'.xlsx','Hoja1');
Iamps = xlsread('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Datos DSS\Imax.xlsx','Hoja1');
posicion_EV = csvread(carpetacaso + '\posicion_EV'+casopen+'.csv');
tipo_EV = csvread(carpetacaso + '\idvehiculo'+casopen+'.csv');
distancia_real =  xlsread(carpeta + '\distancia_real'+caso+'.xlsx','Hoja1');
perfil_nodoEVGA_rapido = csvread(carpetacaso + '\perfil_nodoEVGA_rapido'+casopen+'.csv');
perfil_nodoEVGA_dom = csvread(carpetacaso + '\perfil_nodoEVGA_dom'+casopen+'.csv');
suma_clientes_ev = csvread(carpetacaso + '\suma_clientes_ev'+casopen+'.csv');
Perfiles_carga = csvread('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Datos DSS\Perfiles_carga.csv');
max_evse1 = 500;
max_evse2 = 500;
csvwrite('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Datos DSS\Perfiles_EVGA_dom.csv',perfil_nodoEVGA_dom);
%csvwrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Red 33 v4\Datos DSS\Perfiles_carga.csv',Perfiles_carga);
%xlswrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Red 33 v4\Datos DSS\Perfiles_carga.xlsx',Perfiles_carga);

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
%     name = 'perfilbatt'+string(i);
%     DSSLoadshape.name = name;
%     tempshape1 = zeros(1,8760);
%     tempshape1(1,str2num(char(intervalo(i)))) = perfilbasebatt1(1,str2num(char(intervalo(i))));
%     tempshape1 = transpose(tempshape1);
%     feature('COM_SafeArraySingleDim',1);
%     DSSLoadshape.Pmult = tempshape1;
%     feature('COM_SafeArraySingleDim',0);
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
%% Obtener voltajes de secuencia
DSSMonitors = DSSCircuit.Monitors;
idmonitor = DSSMonitors.allNames;
conmonitor = contains(idmonitor,'volpolar');
j=1;
for i=1:1:length(conmonitor)
    if conmonitor(i) == 1
        DSSMonitors.Name = string(idmonitor(i));
        matrizvolPol0(:,j) = DSSMonitors.Channel(1);
        matrizvolPolmas(:,j) = DSSMonitors.Channel(3);
        matrizvolPolmenos(:,j) = DSSMonitors.Channel(5);
        j = j+1;
    end
end
%desbalances por nodo
desbalance = (matrizvolPolmenos./matrizvolPolmas).*100;
%% Determinar horas con sobrevoltaje y con bajo voltaje
matovA = zeros(8760,6);
matovB = zeros(8760,6);
matovC = zeros(8760,6);
matuvA = zeros(8760,6);
matuvB = zeros(8760,6);
matuvC = zeros(8760,6);
for j = 1:1:6
    for i = 1:1:8760
        if matrizvolA(i,j)>1.06
            matovA(i,j) = 1;
        end
        if matrizvolA(i,j)<0.94
            matuvA(i,j) = 1;
        end
        if matrizvolB(i,j)>1.06
            matovB(i,j) = 1;
        end
        if matrizvolB(i,j)<0.94
            matuvB(i,j) = 1;
        end
        if matrizvolC(i,j)>1.06
            matovC(i,j) = 1;
        end
        if matrizvolC(i,j)<0.94
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
%costo = costopotanual+costov+costoI+costocambio;4
costo = costodemanda+costoI+costov+costocambio+costo_noserv+costo_cambioevse;%% Graficos de resultados importantes
carpe = "C:\Users\danil\OneDrive\Escritorio\Resultados\Red 7 barras\Pdom50_EV75_400GD_NC\";
%% Tensiones
%%Media, max y min de voltajes por barra
vol_medi_barr = (matrizvolA(:,(1:6))+matrizvolB(:,(1:6))+matrizvolC(:,(1:6)))./3;
minimo_vol_bar = min(vol_medi_barr);
maximo_vol_bar = max(vol_medi_barr);
media_vol_bar = mean(vol_medi_barr);

tamano=get(0,'ScreenSize');
figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)])
hold on
bar((1:6),maximo_vol_bar(:,(1:6)),'y')
bar((1:6),media_vol_bar(:,(1:6)),'g')
bar((1:6),minimo_vol_bar(:,(1:6)),'r')
hold off
axis([0.5 6.5 0.94 1.02])
title('Perfiles de tensiones registrados rama principal')
xlabel('Linea')
ylabel('Nivel de tensión (p.u.)')
saveas(gcf,carpe+"Tesnsiones_ramas_UN_Dom50_EV75_GD_BESS.jpg")
%% desbalance de voltaje
desbalance_lineas = desbalance(:,1:6);
max_desb = max(desbalance_lineas);
tamano=get(0,'ScreenSize');
figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)])
bar((1:6),max_desb(:,(1:6)),'b')
%axis([0.5 12.5 0.90 1])
title('Máximo desbalance de tensión rama principal')
xlabel('Linea')
ylabel('Porcentaje de desbalance (%)')
%saveas(gcf,carpe+"Desbalances_UN_Dom50_EV75_GD_BESS.jpg")
%% Potencia por transformador
pot_tot = powtrafofase1+powtrafofase2+powtrafofase3;
energia = sum(pot_tot);
nivel_ocupacion = pot_tot./1000.*100;
max_nivel_ocupacion = max(nivel_ocupacion);
mes_max_ocup = round(find(max_nivel_ocupacion==nivel_ocupacion)/8760*12);
tamano=get(0,'ScreenSize');
figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)])
bar(nivel_ocupacion)
title('Nivel de ocupación del transformador principal')
xlabel('Hora')
ylabel('Porcentaje de ocupación (%)')
%saveas(gcf,carpe+"Ocupacion_trafo_UN_Dom50_EV75_GD_BESS.jpg")
%% Corrientes por lineas
ocupacion_lineaA = maxcurrA(1:6)./maxconductores(1:6).*100;
ocupacion_lineaB = maxcurrB(1:6)./maxconductores(1:6).*100;
ocupacion_lineaC = maxcurrC(1:6)./maxconductores(1:6).*100;
tamano=get(0,'ScreenSize');
figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)])
bar(ocupacion_lineaA,'r')
hold on
bar(ocupacion_lineaB,'b')
bar(ocupacion_lineaC,'y')
title('Máxima ocupación anual de las líneas')
xlabel('Línea')
ylabel('Porcentaje de ocupación (%)')
legend('Fase A', 'Fase B', 'Fase C')
%saveas(gcf,carpe+"Ocupacion_lineas_UN_Dom50_EV75_GD_BESS.jpg")
%% Perdidas del sistema
energia_sistema_MW = Total_demanda/1000
perdidas_sistema_MW = Total_perdidas/1000
demanda_EV_MW = sum(sum(perfil_EVSETc1))/1000
demanda_EV_adicional_MW = sum(sum(perfil_EVSET1_adicional))/1000
Energia_noserv = sum(perfil_noservido,2);
Total_noserv_MW = sum(Energia_noserv)/1000
tamano=get(0,'ScreenSize');
figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)])
bar(Energia_noserv/1000)
title('Energía no suministrada por sobrecupo EV')
xlabel('Día')
ylabel('Energía (MW)')
%saveas(gcf,carpe+"Energia_noEV_UN_Dom50_EV75_GD_BESS.jpg")
%% Guardar datos pricipales
mat_guardar = ["demanda_EV_adicional_MW", "demanda_EV_MW", "energia_sistema_MW", "horasov", "max_desb", "horasuv", "max_nivel_ocupacion", "maxde", "perdidas", "perdidas_sistema_MW", "Total_noserv_MW", 'x1','x2','x3','x4';demanda_EV_adicional_MW, demanda_EV_MW, energia_sistema_MW, horasov, max(max_desb),horasuv, max_nivel_ocupacion, maxdem, perdidas, perdidas_sistema_MW, Total_noserv_MW, x];
xlswrite('Datos.xlsx',mat_guardar)
