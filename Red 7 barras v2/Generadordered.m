%% Inicialización %%
clear all
format long
%datapath = string(input('Insertar Datapath: ', 's'));
datapath = '"'+datapath+'"';
datapathns = "C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Red 7 barras";
%% Importar perfiles de generacion solar
[~, ~, raw] = xlsread(datapathns+'\Perfiles_solares.xlsx','Sheet1'); %% cambiar si se agregan más generadores
PV = raw;
Ngenpv = size(raw,2);
clearvars raw R;
%% Importar perfiles de carga
[~, ~, raw] = xlsread(datapathns+'\Perfiles_carga.xlsx','conductores');
Load = raw;
Ncargas = size(raw,2);
clearvars data raw;

%% Importar perfiles de EV
[~, ~, raw] = xlsread(datapathns+'\Perfiles_EVCS.xlsx');
EVload = cell2mat(raw);
NcargasEV = size(raw,2);
clearvars data raw;
%% Importar conductores
dimcol = size(xlsread('conductores.xlsx'),1)+1;
col = 'A2:F'+string(dimcol);
[~, ~, raw] = xlsread(datapathns+'\conductores.xlsx','conductores',col);
stringVectors = string(raw(:,[1,2]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[3,4,5,6]);
data = reshape([raw{:}],size(raw));
NombreCd = stringVectors(:,1);
IDconductor = stringVectors(:,2);
Rohmkm = data(:,1);
Xohmkm = data(:,2);
Iamps = data(:,3);
%Smm2 = data(:,4);
clearvars data raw stringVectors dimcol col;
%% Importar datos de los nodos
[~, ~, raw] = xlsread(datapathns+'\Feeder_Data.xlsx','Nodes');
[~, ~, raw2] = xlsread(datapathns+'\Feeder_Data.xlsx','Lines');
%datos nodos
stringVectors = string(raw(:,[1,2]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[3,4]);
raw(1,:) = [];
stringVectors(1,:)=[];
data = raw;
Nodocarga = stringVectors(:,1);
tipoNodo = stringVectors(:,2);
posX = cell2mat(data(:,1));
posY = cell2mat(data(:,2));
clearvars data raw stringVectors;
%datos lineas
raw2(1,:) = [];
stringVectors = string(raw2(:,[2,3]));
stringVectors(ismissing(stringVectors)) = '';
IDlinea = cell2mat(raw2(:,1));
Nodo1 = stringVectors(:,1);
Nodo2 = stringVectors(:,2);
Tcable = string(raw2(:,5));
clearvars stringVectors raw2;
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
% clearvars data raw stringVectors;
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
%% Escritura Linecodes y loadshapes
linecodes = fopen('datosDSS.dss','wt');
for i =1:1:length(IDconductor)
    fprintf(linecodes, '%s%s %s %s%s %s%s %s \n' , 'new linecode.', string(IDconductor(i)), 'nphases=3', 'R1=', string(Rohmkm(i)), 'X1=', string(Xohmkm(i)), 'units=km');
end
for i=1:1:Ncargas
    fprintf(linecodes, '%s%s %s%s %s \n', 'new loadshape.perfilcarga',string(i),'npts=8760 interval=1 pmult=(file=Perfiles_carga.csv, col=', string(i), 'header=yes)');
end
for i=1:1:Ngenpv
    fprintf(linecodes, '%s%s %s%s %s \n', 'new loadshape.perfilgeneracion',string(i),'npts=8760 interval=1 pmult=(file=Perfiles_solares.csv, col=', string(i), 'header=yes)');
end
for i = 1:1:length(Nodocarga)
     fprintf(linecodes, '%s%s %s%s %s \n', 'new loadshape.perfilEVCS',Nodocarga(i),'npts=8760 interval=1 pmult=(file=Perfiles_EVCS.csv, col=', string(1), 'header=no)');
end
    fclose(linecodes);
%% Distancias y definición de lineas
lineas = fopen('Lineas.dss','wt');
for i=1:1:length(IDconductor)
    indA = find(Nodo1(i)== Nodocarga);
    indB = find(Nodo2(i)== Nodocarga);
    xa = posX(indA);
    ya = posY(indA);
    xb = posX(indB);
    yb = posY(indB);
    dist = (sqrt(((xa-xb)^2)+((ya-yb)^2)))/1000;
    fprintf(lineas, '%s%s %s%s %s%s %s%s %s%s\n' ,'new line.Linea', string(IDlinea(i)), 'bus1=', string(Nodo1(i)), 'bus2=', string(Nodo2(i)),'length=', string(dist), 'phases=3 units=km linecode=',string(Tcable(i)));
end
%falta definir potencia de cargas
j = 1;
k = 1;
for i=1:1:length(tipoNodo)
    if tipoNodo(i)=='consumo'
        fprintf(lineas, '%s%s %s%s %s%s %s\n','new load.Load', string(i), 'bus1=', Nodocarga(i), 'phases=3 kV=23 kW=2750 kvar=968 model=1 yearly=perfilcarga', string(j), 'status=variable');
        j = j+1;
    elseif tipoNodo(i)=='con/gen'
        fprintf(lineas, '%s%s %s%s %s%s %s\n','new load.Load', string(i), 'bus1=', Nodocarga(i), 'phases=3 kV=23 kW=2750 kvar=968 model=1 yearly=perfilcarga', string(j), 'status=variable');
        fprintf(lineas, '%s%s %s%s %s%s %s\n','new generator.generador', string(i), 'bus1=', Nodocarga(i), 'phases=3 kV=23 kW=10000 kvar=0 model=1 yearly=perfilgeneracion', string(k), 'status=variable');
        j=j+1;
        k=k+1;
    elseif tipoNodo(i)=='generador'
        fprintf(lineas, '%s%s %s%s %s%s %s\n','new generator.generador', string(i), 'bus1=', Nodocarga(i), 'phases=3 kV=23 kW=10000 kvar=0 model=1 yearly=perfilgeneracion', string(k), 'status=variable'); 
        k=k+1;
    end
   fprintf(lineas, '%s%s %s%s %s%s %s\n','new load.LoadEV', string(Nodocarga(i)), 'bus1=', Nodocarga(i), 'phases=3 kV=23 kW=500 kvar=0 model=1 yearly=perfilEVCS', string(Nodocarga(i)) , 'status=variable'); 
end
fclose(lineas);  
%% Crear Monitores %%
monitor = fopen('monitores.dss','wt');
fprintf(monitor, '%s\n','! Definición de monitores');
fprintf(monitor,'%s\n','Set controlmode = static');
fprintf(monitor,'%s\n','Set mode = yearly');
fprintf(monitor,'%s\n','Set number = 8760 !horas');
fprintf(monitor,'%s\n','Set stepsize = 1h');
fprintf(monitor, '%s\n','New EnergyMeter.meter1 element=transformer.tf1 Terminal=1');
for i=1:1:length(Nodocarga)
    if (Nodocarga(i)=='1')
        fprintf(monitor,'%s%s %s\n','New monitor.Monitortvoltrafo',string(i),'element=transformer.TF1 Terminal=1 mode=0 ppolar=no');
        fprintf(monitor,'%s%s %s\n','New monitor.Monitortpowtrafo',string(i),'element=transformer.TF1 Terminal=1 mode=1 ppolar=no');
        fprintf(monitor,'%s%s %s\n','New monitor.Monitortlosstrafo',string(i),'element=transformer.TF1 Terminal=1 mode=9 ppolar=no');
    elseif (Nodocarga(i)=='6')
        fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorpownodo',string(i),'element=generator.generador',string(Nodocarga(i)),'Terminal=1 mode=1 ppolar=no');
    else
        fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorpownodo',string(i),'element=load.Load',string(Nodocarga(i)),'Terminal=1 mode=1 ppolar=no');
        
    end
    end
for i=1:1:length(IDlinea)
    fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorvollin',string(i),'element=line.Linea',string(IDlinea(i)),'Terminal=1 mode=0 ppolar=no');
    fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorlosslin',string(i),'element=line.Linea',string(IDlinea(i)),'Terminal=1 mode=9 ppolar=no');
end
for i=1:1:length(Nodocarga)
    fprintf(monitor,'%s%s %s%s %s\n','New monitor.MonitorpowEV',string(i),'element=load.LoadEV',string(i),'Terminal=1 mode=1 ppolar=no');
    fprintf(monitor,'%s%s %s%s %s\n','New monitor.Monitorvolnodo',string(i),'element=load.LoadEV',string(i),'Terminal=1 mode=0 ppolar=no');
end
    fclose(monitor);
%% Juntar en un archivo para OpenDSS
reddss = fopen('RedDSS7barras.dss','wt');
inicia = importdata('InicializaciónDSS.dss');
trafos = importdata('trafos.dss');
datosDSS = importdata('datosDSS.dss');
lineas = importdata('Lineas.dss');
monitores = importdata('monitores.dss');
fprintf(reddss, '%s \n', string(inicia));
fprintf(reddss, '%s \n', string(trafos));
fprintf(reddss, '%s \n', string(datosDSS));
fprintf(reddss, '%s \n', string(lineas));
fprintf(reddss, '%s \n', string(monitores));
fclose(reddss);
clearvars inicia trafos datosDSS lineas monitors









