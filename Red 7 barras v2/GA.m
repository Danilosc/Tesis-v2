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
%% variables globales del algoritmo
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
%% Algoritmo Genetico
tic
fun = @fitnesentero;
ub = [7 7 7 7];
lb = [2 2 2 2];
intcon = [1 2 3 4];
options = optimoptions('ga', 'OutputFcn', @gacustom, 'NonlinearConstraintAlgorithm', 'Penalty', 'CrossoverFcn', @crossoverscattered,'UseParallel', false, 'UseVectorized', false, 'PopulationSize', 50, 'SelectionFcn', @selectiontournament, 'PlotFcn', {@gaplotbestf, @gaplotgenealogy, @gaplotscores, @gaplotrange}, 'MaxGenerations', 10, 'Display', 'iter' );
[x,fval,exitflag,output,population,scores] = ga(fun,4,[],[],[],[],lb,ub,[],intcon,options);
toc
%% guardar espacio de trabajo
save("C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 33 v4\"+casopen)

%% Graficar resultados
save('GA_Dom_50_75EV_400GD')