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
carpeta = "C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 33 v4\Creación Información de Nodos\";
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
Iamps = xlsread('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 33 v4\Datos DSS\Imax.xlsx','Hoja1');
posicion_EV = csvread(carpetacaso + '\posicion_EV'+casopen+'.csv');
tipo_EV = csvread(carpetacaso + '\idvehiculo'+casopen+'.csv');
distancia_real =  xlsread(carpeta + '\distancia_real'+caso+'.xlsx','Hoja1');
perfil_nodoEVGA_rapido = csvread(carpetacaso + '\perfil_nodoEVGA_rapido'+casopen+'.csv');
perfil_nodoEVGA_dom = csvread(carpetacaso + '\perfil_nodoEVGA_dom'+casopen+'.csv');
suma_clientes_ev = csvread(carpetacaso + '\suma_clientes_ev'+casopen+'.csv');
Perfiles_carga = csvread('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 33 v4\Datos DSS\Perfiles_carga.csv');
max_evse1 = 500;
max_evse2 = 500;
csvwrite('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 33 v4\Datos DSS\Perfiles_EVGA_dom.csv',perfil_nodoEVGA_dom);
%csvwrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Red 33 v4\Datos DSS\Perfiles_carga.csv',Perfiles_carga);
%xlswrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Red 33 v4\Datos DSS\Perfiles_carga.xlsx',Perfiles_carga);
%% pruebas
potnom = xlsread('potnom.xlsx');
potnom = potnom([2:33],:);
for i = 1:1:32
    kwnodo(:,i) = Perfiles_carga(:,i).*potnom(i,1);
    kvarnodo(:,i) = Perfiles_carga(:,i).*potnom(i,2);
end
% csvwrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Red 33 v4\Datos DSS\Perfiles_cargaP.csv',kwnodo);
% csvwrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Red 33 v4\Datos DSS\Perfiles_cargaQ.csv',kvarnodo);
demtot = kwnodo + perfil_nodoEVGA_dom;
%% Algoritmo Genetico
tic
fun = @fitnesentero;
%poblacion = [2 2 2 2 25 25 25 25; 2 2 2 2 33 33 33 33; 2 2 2 2 22 22 22 22; 18 18 18 18 25 25 25 25; 18 18 18 18 33 33 33 33; 18 18 18 18 22 22 22 22; 18 2 2 18 25 22 22 25; 18 2 2 18 33 26 26 33; 18 2 2 18 22 19 19 22; 2 2 2 2 32 33 33 19; 18 18 18 18 33 33 33 33];
ub = [18 18 18 18 33 33 33 33];
%poblacion = [2 2 2 2 2 2 2 2; 2 2 2 2 2 2 2 2; 2 2 2 2 2 2 2 2; 2 2 2 2 2 2 2 2; 2 2 2 2 2 2 2 2; 2 2 2 2 2 2 2 2; 2 2 2 2 2 2 2 2; 2 2 2 2 2 2 2 2; 2 2 2 2 2 2 2 2; 2 2 2 2 2 2 2 2];
lb = [2 2 2 2 19 19 19 19];
intcon = [1 2 3 4 5 6 7 8];
% @gaplotgenealogy,@gaplotscorediversity,@gaplotscores,@gaplotdistance,@gaplotselection,@gaplotbestf,}@gaplotbestindiv,@gaplotexpectation,@gaplotrange,
% @gaplotscores, @gaplotgenealogy, @gaplotbestf, @gaplotselection, @gaplotrange}
%'UseParallel', true, 'UseVectorized', false,
options = optimoptions('ga', 'OutputFcn', @gacustom, 'NonlinearConstraintAlgorithm', 'Penalty', 'CrossoverFcn', @crossoverscattered,'UseParallel', false, 'UseVectorized', false, 'PopulationSize', 150, 'SelectionFcn', @selectiontournament, 'PlotFcn', {@gaplotbestf, @gaplotgenealogy, @gaplotscores, @gaplotrange}, 'MaxGenerations', 10, 'Display', 'iter' );
[x,fval,exitflag,output,population,scores] = ga(fun,8,[],[],[],[],lb,ub,[],intcon,options);
toc
%% guardar espacio de trabajo
save("C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 33 v4\"+casopen)