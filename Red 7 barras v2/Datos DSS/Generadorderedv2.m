%% Inicialización %%
clear all
format long
% datapath = string(input('Ingresar Datapath: ', 's'));
datapath = "C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Datos DSS";
datapathns = datapath;
datapath = '"'+datapath+'"';
%% Importar perfiles de generacion solar
[~, ~, raw] = xlsread(datapathns+'\Perfiles_solares.xlsx','Sheet1'); 
Perfil_PV = raw; %Loadshape de generadores PV
Perfil_PV(1,:) = [];
N_genpv = size(raw,2);
clearvars raw R;
%% Importar perfiles de carga
[~, ~, raw] = xlsread(datapathns+'\Perfiles_carga.xlsx');
Perfil_cargas = raw; %Loadshape de cargas
Perfil_cargas(1,:) = [];
N_cargas = size(raw,2);
clearvars data raw;

%% Importar perfiles de EV
[~, ~, raw] = xlsread(datapathns+'\Perfiles_EVCS.xlsx');
Perfil_EV = cell2mat(raw); %Loadshapes de EV
N_perfilesEV = size(raw,2);
clearvars data raw;
%% Importar perfiles Batt
[~, ~, raw] = xlsread(datapathns+'\Perfil_batt.csv');
Perfil_batt = cell2mat(raw); %Loadshapes de EV
N_perfilesbatt = size(raw,2);
clearvars data raw;
%% Importar conductores
[~, ~, raw] = xlsread(datapathns+'\conductores.xlsx','conductores');
raw(1,:)=[];
stringVectors = string(raw(:,[1,2]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[3,4,5]);
data = raw;
Nombre_Conductor = stringVectors(:,1);
ID_conductor = stringVectors(:,2);
Rohm_km = data(:,1);
Xohm_km = data(:,2);
% R0ohm_km = data(:,3);
% X0ohm_km = data(:,4);
% global Iamps
Iamps = data(:,3);
clearvars data raw stringVectors dimcol col;
%% Importar datos de los nodos
[~, ~, raw] = xlsread(datapathns+'\Feeder_Data.xlsx','Nodes');
[~, ~, raw2] = xlsread(datapathns+'\Feeder_Data.xlsx','Lines');
raw(1,:) = [];
raw2(1,:) = [];
stringVectors = string(raw(:,[1,2]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[3,4,5,6,7,8]);
Nodo_carga = stringVectors(:,1);
Tipo_Nodo = stringVectors(:,2);
kw_nom = cell2mat(raw(:,1));
kvar_nom = cell2mat(raw(:,2));
fasesn = raw(:,3);
conn = raw(:,4);
confas = raw(:,5);
kvnom = raw(:,6);
clearvars data raw stringVectors;
% datos lineas
stringVectors = string(raw2(:,[2,3]));
stringVectors(ismissing(stringVectors)) = '';
IDlinea = cell2mat(raw2(:,1));
Nodo1 = stringVectors(:,1);
Nodo2 = stringVectors(:,2);
Tcable = string(raw2(:,5));
dist = raw2(:,6);
clearvars stringVectors raw2;
xlswrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\potnom.xlsx',[kw_nom kvar_nom]);
%% Importar datos de transformadores
[~, ~, raw] = xlsread(datapathns+'\Transformadores.xlsx','conductores');
raw(1,:)=[];
stringVectors = string(raw(:,[1,4,5,6]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[2,3,7,8,9,10,11,12]);
data = raw;
IDtrafo = stringVectors(:,1);
fases = cell2mat(data(:,1));
devanados = cell2mat(data(:,2));
bus1 = stringVectors(:,2);
bus2 = stringVectors(:,3);
construccion = stringVectors(:,4);
vprimario = cell2mat(data(:,3));
vsecundario = cell2mat(data(:,4));
Pprimario = cell2mat(data(:,5));
Psecundario = cell2mat(data(:,6));
perdidas = cell2mat(data(:,7));
Xtrado = cell2mat(data(:,8));
clearvars data raw stringVectors;
%% Escritura de codigo base (lineas N1)
monitor = fopen('InicializaciónDSS.dss','wt');
fprintf(monitor, '%s\n %s\n %s%s \n', 'Set DefaultBaseFrequency=50', 'clear', 'Set datapath=', string(datapath), 'New circuit.redprueba basekV=132 pu=1.0 angle=0 frequency=50 phases=3');
fclose(monitor);
%% Escritura info trafos
textrafos=fopen('trafos.dss','wt');
for i=1:1:length(IDtrafo)
    fprintf(textrafos, '%s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s %s%s \n' , 'new transformer.', string(IDtrafo(i)), 'phases=', string(fases(i)), 'windings=', string(devanados(i)), 'buses=', '('+bus1(i)+', '+bus2(i)+')', 'conns=', string(construccion(i)), 'kvs=', '('+string(vprimario(i))+', '+string(vsecundario(i))+')','kvas=', '('+string(Pprimario(i))+', '+string(Psecundario(i))+')', '%loadloss=', string(perdidas(i)),'xhl=', string(Xtrado(i)));
end
fclose(textrafos);
clearvars vprimario vsecundario Pprimario Psecundario perdidas Xtrado bus1 bus2 construccion fases devanados
%% Escritura Linecodes y loadshapes
linecodes = fopen('datosDSS.dss','wt');
for i =1:1:length(ID_conductor)
    fprintf(linecodes, '%s%s %s %s%s %s%s %s \n' , 'new linecode.', string(ID_conductor(i)), 'nphases=3', 'R1=', string(Rohm_km(i)), 'X1=', string(Xohm_km(i)), 'units=km');
end
for i=1:1:N_cargas
    % fprintf(linecodes, '%s%s %s%s %s %s%s %s \n', 'new loadshape.perfilcarga',string(i),'npts=8760 interval=1 pmult=(file=Perfiles_cargaP.csv, col=', string(i), 'header=yes)',' qmult=(file=Perfiles_cargaQ.csv, col=', string(i), 'header=yes)');
    fprintf(linecodes, '%s%s %s%s %s \n', 'new loadshape.perfilcarga',string(i),'npts=8760 interval=1 pmult=(file=Perfiles_carga.csv, col=', string(i), 'header=no)');
end
for i=1:1:N_cargas
    fprintf(linecodes, '%s%s %s%s %s \n', 'new loadshape.perfilEVdomiciliario',string(i),'npts=8760 interval=1 pmult=(file=Perfiles_EVGA_dom.csv, col=', string(i), 'header=no)');
end
for i=1:1:N_genpv
    fprintf(linecodes, '%s%s %s%s %s \n', 'new loadshape.perfilgeneracion',string(i),'npts=8760 interval=1 pmult=(file=Perfiles_solares.csv, col=', string(i), 'header=no)');
end
j = 1;
for i = 1:1:4*N_perfilesEV
    if j < 5
        k=1;
    else
        k=2;
    end
    fprintf(linecodes, '%s%s %s%s %s \n', 'new loadshape.perfilEVCS',string(i),'npts=8760 interval=1 pmult=(file=Perfiles_EVCS.csv, col=', string(k), 'header=no)');     
    j = j+1;
end
j=1;
k=1;
for i = 1:1:4*N_perfilesbatt
    if j < 5
        k=1;
    else
        k=2;
    end
    fprintf(linecodes, '%s%s %s%s %s \n', 'new loadshape.perfilbatt',string(i),'npts=8760 interval=1 pmult=(file=Perfil_batt.csv, col=', string(k), 'header=no)');
    j = j+1;
end
fclose(linecodes);
%% Distancias y definición de lineas
lineas = fopen('Lineas.dss','wt');
for i=1:1:length(ID_conductor)
    fprintf(lineas, '%s%s %s%s %s%s %s%s %s%s \n' ,'new line.Linea', string(IDlinea(i)), 'bus1=', string(Nodo1(i)), 'bus2=', string(Nodo2(i)),'length=', string(dist(i)), 'phases=3 units=m linecode=', string(Tcable(i)));
end
j = 1;
k = 1;
for i=1:1:length(Tipo_Nodo)
    if Tipo_Nodo(i)=='consumo'
        fprintf(lineas, '%s%s %s%s%s%s %s%s %s%s %s%s %s%s %s%s %s%s %s\n','new load.Load', string(i), 'bus1=', Nodo_carga(i),'.',string(confas(i)), 'phases=', string(fasesn(i)), 'conn=', string(conn(i)),'kV=',string(kvnom(i)),'kW=', string(kw_nom(i)), 'kvar=', string(kvar_nom(i)), 'model=1 yearly=perfilcarga', string(j), 'status=variable');
        fprintf(lineas, '%s%s %s%s%s%s %s%s %s%s %s%s %s%s %s%s %s%s %s\n','new load.LoadEVdom', string(i), 'bus1=', Nodo_carga(i),'.',string(confas(i)), 'phases=', string(fasesn(i)), 'conn=', string(conn(i)),'kV=',string(kvnom(i)),'kW=', string(1), 'kvar=', string(0), 'model=1 yearly=perfilEVdomiciliario', string(j), 'status=variable');
        j = j+1;
    elseif Tipo_Nodo(i)=='generador'
        fprintf(lineas, '%s%s %s%s%s%s %s%s %s%s %s%s %s%s %s%s %s\n','new generator.generador', string(Nodo_carga(i)), 'bus1=', Nodo_carga(i),'.', string(confas(i)),'phases=', string(fasesn(i)), 'conn=', string(conn(i)), 'kV=12.6 kW=', string(kw_nom(i)), 'kvar=', string(kvar_nom(i)),'model=1 yearly=perfilgeneracion', string(k), 'status=variable'); 
        k=k+1;
    end
   
end
fprintf(lineas, '%s\n', 'new swtcontrol.switch1 action=open delay=0 switchedObj=line.Linea33');
fprintf(lineas, '%s\n', 'new swtcontrol.switch2 action=open delay=0 switchedObj=line.Linea34');
fprintf(lineas, '%s\n', 'new swtcontrol.switch3 action=open delay=0 switchedObj=line.Linea35');
fprintf(lineas, '%s\n', 'new swtcontrol.switch4 action=open delay=0 switchedObj=line.Linea36');
fprintf(lineas, '%s\n', 'new swtcontrol.switch5 action=open delay=0 switchedObj=line.Linea37');
fprintf(lineas, '%s\n %s\n', 'set voltagebases=12.66', 'calcvoltagebases');


fclose(lineas); 
clearvars Evid Tcable texttrafos Rohm_km Xohm_km j k i fp_nom dist lineas linecodes kw_nom
 
%% Crear Monitores %%
monitor = fopen('monitores.dss','wt');
fprintf(monitor, '%s\n','! Definición de monitores');
fprintf(monitor,'%s\n','set controlmode = static');
fprintf(monitor,'%s\n','set mode = yearly');
fprintf(monitor,'%s\n','set number = 8760 !horas');
fprintf(monitor,'%s\n','set stepsize = 1h');
fprintf(monitor, '%s\n','New EnergyMeter.meter1 element=transformer.tf1 Terminal=1');
for i=1:1:length(IDlinea)
    fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorvollin',string(i),'element=line.Linea',string(IDlinea(i)),'Terminal=1 mode=0 ppolar=no');
%     fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorlosslin',string(i),'element=line.Linea',string(IDlinea(i)),'Terminal=1 mode=9 ppolar=no');
end
for i=1:1:length(Tipo_Nodo)
    if (Tipo_Nodo(i) == 'nodo')
        fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitortvolnodotf',string(Nodo_carga(i)),'element=transformer.', string(IDtrafo(i)), 'Terminal=1 mode=0 ppolar=no');
        fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitortpownodotf',string(Nodo_carga(i)),'element=transformer.', string(IDtrafo(i)), 'Terminal=1 mode=1 ppolar=no');
        fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitortlossnodotf',string(Nodo_carga(i)),'element=transformer.', string(IDtrafo(i)), 'Terminal=1 mode=9 ppolar=no');
    elseif (Tipo_Nodo(i)=='generador')
        fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorpowgen',string(Nodo_carga(i)),'element=generator.generador',string(Nodo_carga(i)),'Terminal=1 mode=1 ppolar=no');
        fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorvolgen',string(Nodo_carga(i)),'element=generator.generador',string(Nodo_carga(i)),'Terminal=1 mode=0 ppolar=no');
    elseif (Tipo_Nodo(i)=='consumo')
        fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorpownodo',string(Nodo_carga(i)),'element=load.Load',string(Nodo_carga(i)),'Terminal=1 mode=1 ppolar=no');
        fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorvolnodo',string(Nodo_carga(i)),'element=load.Load',string(Nodo_carga(i)),'Terminal=1 mode=0 ppolar=no');
     end
end

fclose(monitor);
%% Juntar en un archivo para OpenDSS
reddss = fopen('RedDSS.dss','wt');
inicia = importdata('InicializaciónDSS.dss');
trafos = importdata('trafos.dss');
datosDSS = importdata('datosDSS.dss');
lineas = importdata('Lineas.dss');
monitors = importdata('monitores.dss');
fprintf(reddss, '%s \n', string(inicia));
fprintf(reddss, '%s \n', string(trafos));
fprintf(reddss, '%s \n', string(datosDSS));
fprintf(reddss, '%s \n', string(lineas));
fprintf(reddss, '%s \n', string(monitors));
fclose(reddss);
clearvars inicia trafos datosDSS lineas monitors
%% Guardar Iamps
a = input('Numero simulacion archivo Imax: ');
xlswrite('Imax'+string(a)+'.xlsx',Iamps);