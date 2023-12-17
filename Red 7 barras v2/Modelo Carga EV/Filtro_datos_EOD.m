%% Importar datos de la encuesta origen-destino
function [viaje_vel,cantidad_viajes]   = Filtro_datos_EOD(tmax,tmin,vmax,vmin,dmax,dmin,save)
%% Importar datos EOD filtrados
[~, ~, raw] = xlsread('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Red 7 barras v2\Modelo Carga EV\Datos_viajes_EOD.xlsx','Viaje','A2:L113079');
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
I = any(cellfun(@(x) isempty(x) || (ischar(x) && all(x==' ')),raw),2); % Find row with blank cells
raw(I,:) = [];
I = ~all(cellfun(@(x) isnumeric(x) || islogical(x),raw),2); % Find rows with non-numeric cells
raw(I,:) = [];
Viaje = reshape([raw{:}],size(raw));
clearvars raw I;

%% Calculo distancia Manhattan
% Estructura [Hogar Usuario Viaje Distancia Horaini Horafin Duración km/h]
viajeaux = [Viaje(:,1) Viaje(:,2) Viaje(:,3) zeros(size(Viaje,1),1) Viaje(:,8) Viaje(:,9) Viaje(:,11) zeros(size(Viaje,1),1)] ;
for i = 1:1:size(Viaje,1)
    viajeaux(i,4) = (abs(Viaje(i,4)-Viaje(i,6))+abs(Viaje(i,5)-Viaje(i,7)))/1000;
    viajeaux(i,7) = viajeaux(i,7)/60;
    viajeaux(i,8) = viajeaux(i,4)/viajeaux(i,7);
end
%% Filtro datos (distancia mayor a dmax km, distancia menor a dmin km y tiempo de viaje tmax y tmin)
j = 1;
k = 1;
for i = 1:1:size(Viaje,1)
    if viajeaux(i,4) > dmax || viajeaux(i,4) < dmin || viajeaux(i,7) > tmax || viajeaux(i,7) < tmin
        viaje_lar(j,:) = viajeaux(i,:);
        j = j+1;
    else
        viaje_def(k,:) = viajeaux(i,:);
        k = k+1;
    end
end
viaje_def(:,[5 6]) = viaje_def(:,[5 6]).*24;
j = 1;
k = 1;
%% Filtro para velocidades mayores a 50kmh y menores a 1 kmh
for i = 1:1:size(viaje_def,1)
    if viaje_def(i,8) < vmin || viaje_def(i,8) > vmax
        viaje_vel_max(j,:) = viaje_def(i,:);
        j = j+1;
    else
        viaje_vel(k,:) = viaje_def(i,:);
        k = k+1;
    end
end
clearvars viaje_vel_max viaje_def viaje_lar i j k Viaje viajeaux

%% Guardar datos de viajes filtrados origen-destino
if save == 's'
    xlswrite('Datos_filtrados_EOD.xlsx',viaje_vel)
end
[C ia ic] = unique(viaje_vel(:,2));
conteos = accumarray(ic,1);
cantidad_viajes = [C, conteos]; %entrega matriz de cantidad de viajes por usuario y los datos de cada uno de los viajes probables
return 

