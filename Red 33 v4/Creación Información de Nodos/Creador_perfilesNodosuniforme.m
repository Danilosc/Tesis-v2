%% Creador perfiles de carga de nodos
clear all
%% Info de nodos
[~, ~, raw] = xlsread('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 33 v4\Datos DSS\Feeder_Data.xlsx','Nodes','C2:C34');
PotenciakW = reshape([raw{:}],size(raw));
clearvars raw
%% Info perfiles Crest
% PerfilesCRESTAnual = importar_perfiles('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Origen-destinoV2\Perfiles Crest\Perfiles_CREST_Anual.csv');

%% Info perfiles EV
Nevs = input('Caso Nevs para perfiles?: ');
%Nevs = 4000; %% de carpeta de origen de perfiles totales sacados (no es igual a los perfiles que se busca reflejar por % de penetracion)
P_carga_dom = input('Caso Pcarga_domiciliaria?: ');
%P_carga_dom = 0; %% de carpeta de origen de perfiles totales sacados (no es igual a los perfiles que se busca reflejar por % de penetracion)
caso = '_Nev' + string(Nevs) + '_Pdom' + string(P_carga_dom);
PerfilesEVAnual_rapido = importar('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Origen-destino\Modelo Carga EV\Casos\Perfiles_EV_rapido' + caso + '.csv',1,8760);
PerfilesEVAnual_domicilio = importar('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Origen-destino\Modelo Carga EV\Casos\Perfiles_EV_domiciliario' + caso + '.csv',1,8760);
user_EV = importar('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Origen-destino\Modelo Carga EV\Casos\user_EV' + caso + '.csv',1,1);
porc_ev = [25 50 75]/100;
a1 = input('Guardar datos (s/n) ','s');
%% distancias coordenadas
[~, ~, raw] = xlsread('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 33 v4\Datos DSS\coordenadas.xlsx','Hoja1','A2:C34');
coordenadas = reshape([raw{:}],size(raw));
var_aux = coordenadas;
clearvars raw;
k = 0;
j = 1;
x = 1;
for i = 1:1:size(var_aux,1)
    for j = x:1:size(var_aux,1)
        distancias(j+k,:) = [i,j,pdist2(coordenadas(i,2:3),coordenadas(j,2:3),'euclidean')]; 
    end
    k = k + j;
    x = x + 1;
end  
% global distancia_real
distancia_real = [];
k = 1;
for i=1:1:size(distancias,1)
    if distancias(i,1) ~= 0
        distancia_real(k,:) = distancias(i,:);
        k = k+1;
    end
end
xlswrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\coordenadas'+caso+'.xlsx',coordenadas);
xlswrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\distancia_real'+caso+'.xlsx',distancia_real);  
%% ploteo Red
plot(coordenadas(1:18,2),coordenadas(1:18,3),'-or')
hold on
plot(coordenadas(19:22,2),coordenadas(19:22,3),'-*b')
plot([coordenadas(2,2) coordenadas(19,2)],[coordenadas(2,3) coordenadas(19,3)],'-*g')
plot(coordenadas(23:25,2),coordenadas(23:25,3),'-xk')
plot(coordenadas(26:33,2),coordenadas(26:33,3),'-sm')
plot([coordenadas(3,2) coordenadas(23,2)],[coordenadas(3,3) coordenadas(23,3)],'-*g')
plot([coordenadas(6,2) coordenadas(26,2)],[coordenadas(6,3) coordenadas(26,3)],'-*g')
for i = 1:1:33
    text(coordenadas(i,2),coordenadas(i,3),string(coordenadas(i,1)))
end
%% EVs x nodos caso 100%
filename = 'C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Datos DSS\N_clientes.csv';
delimiter = ',';
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
clientes_nodos = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;
suma_clientes = sum(clientes_nodos);
clientes_aux = clientes_nodos;
nodo_origenEV = zeros(1,suma_clientes);
i = 1;
j = 1;
while j < 33
    if clientes_aux(j) > 0
        nodo_origenEV(i) = 1+j; %establece el origen de los evs en la red considerando 100% penetración EV
        clientes_aux(j) = clientes_aux(j)-1;
        i = i+1;
    else
        j = j+1;
    end
end
%% Posicion de los EV diaria caso 100%
posicion_EV100 = zeros(365,suma_clientes);
for i = 1:1:suma_clientes
    for x = 1:1:365
        y = round(random('Normal',nodo_origenEV(i),5));
        if y < 2
            y = 2;
        elseif y > 33
            y = 33;
        end
    posicion_EV100(x,i) = y; %posicion de los EVs en el día (se usa en GA para calcular distancia)
    end
end
%% Perfiles de carga rápida y domiciliaria caso 100%
perfil_nodoEVGA100 = zeros(8760,suma_clientes);
perfiles_usados_dom = zeros(8760,suma_clientes);
idvehiculo100 = zeros(1,suma_clientes);
for i = 1:1:suma_clientes
    ranid = random('Discrete Uniform', size(PerfilesEVAnual_domicilio,2));
    vect_ranid(i) = ranid; % posicion en la matriz de datos
    perfil_nodoEVGA100(:,i) = PerfilesEVAnual_rapido(:,ranid); % perfiles aleatorios carga rápida
    %perfiles_usados_dom(:,i) = PerfilesEVAnual_domicilio(:,ranid);
    idvehiculo100(1,i) = user_EV(ranid);
end
%% Por simplicidad, se rellenan los perfiles en orden a partir del vector nodo_origenEV
perfil_nodoEV_domGA100 = zeros(8760,32);
for i = 1:1:length(vect_ranid)
    Perfil_aux_dom(:,i) = PerfilesEVAnual_domicilio(:,vect_ranid(i));
end
j = 2;
i = 1;
for k = 1:1:length(vect_ranid)
    if nodo_origenEV(k) == j
        perfil_nodoEV_domGA100(:,i) =  perfil_nodoEV_domGA100(:,i)+ Perfil_aux_dom(:,k);

    else
        i = i + 1;
        perfil_nodoEV_domGA100(:,i) =  perfil_nodoEV_domGA100(:,i)+ Perfil_aux_dom(:,k);
        j = j+1;
    end
    perfiles_usados_dom(:,k) = Perfil_aux_dom(:,k);
end

%% adaptación datos en función del porcentaje

%% Obtener datos para cada caso
for x = 1:1:length(porc_ev) %contador casos de probabilidad penetracion
    clientes_ev = round(porc_ev(x).*clientes_nodos);
    sum_clientes_ev = sum(clientes_ev);
    perfil_nodoEV_domGA = zeros(8760,32);
    perfil_nodoEVGA = zeros(8760,sum_clientes_ev);
    posicion_EV = zeros(365,sum_clientes_ev);
    idvehiculo = zeros(1,sum_clientes_ev);
    k = 1; %contador que recorre los perfiles de 100%
    n = 0; %indicador de máximo valor de perfiles 100% 
    for i = 1:1:32
        for j = 1:1:clientes_ev(i)
            perfil_nodoEVGA(:,k) = perfil_nodoEVGA100(:,j+n);
            perfil_nodoEV_domGA(:,i) = perfil_nodoEV_domGA(:,i)+perfiles_usados_dom(:,j+n);
            posicion_EV(:,k) = posicion_EV100(:,j+n);
            idvehiculo(1,k) = idvehiculo100(1,j+n);
            k = k + 1;
        end
        n = n + clientes_nodos(i);
    end
    if a1 == 's' 
        casostr = caso + '_EV' + string(porc_ev(x)*100);
        mkdir(char(casostr))
        %xlswrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\'+ casostr+ '\coordenadas'+caso+'_EV'+string(porc_ev)+'.xlsx',coordenadas);
        csvwrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\'+ casostr+ '\posicion_EV'+caso+'_EV'+string(porc_ev(x)*100)+'.csv',posicion_EV);
        %xlswrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\'+ casostr+ '\distancia_real'+caso+'_EV'+string(porc_ev)+'.xlsx',distancia_real);
        csvwrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\'+ casostr+ '\perfil_nodoEVGA_rapido'+caso+'_EV'+string(porc_ev(x)*100)+'.csv',perfil_nodoEVGA);
        csvwrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\'+ casostr+ '\perfil_nodoEVGA_dom'+caso+'_EV'+string(porc_ev(x)*100)+'.csv',perfil_nodoEV_domGA);
        csvwrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\'+ casostr+ '\suma_clientes_ev'+caso+'_EV'+string(porc_ev(x)*100)+'.csv',sum_clientes_ev);
        %xlswrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\'+ casostr+ '\Perfiles_carga'+caso+'_EV'+string(porc_ev)+'.xlsx',dem_norm);
        csvwrite('C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Creación Información de Nodos\'+ casostr+ '\idvehiculo'+caso+'_EV'+string(porc_ev(x)*100)+'.csv',idvehiculo);
    end  
end 


