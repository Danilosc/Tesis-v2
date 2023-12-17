%% Procesamiento de datos
%% Designación días
diasemana = ["dom", "lun", "mar", "mie", "jue", "vie", "sab"];
diasmes = [31 28 31 30 31 30 31 31 30 31 30 31];
dia = zeros(8760*3,1);
tipodia = string(zeros(8760*3,1));
mes = zeros(8760*3,1);
anual = zeros(8760*3,1);
hora = zeros(8760*3,1);
diaaux = 1;
mesaux = 1;
anualaux = 2017;
horaaux = 1;
for i = 1:1:8760*3
    hora(i) = horaaux;
    if hora(i)<= 24
         dia(i) = diaaux;
         mes(i) = mesaux;
         anual(i) = anualaux;
    else
        horaaux = 1;
        hora(i) = horaaux;
        diaaux = diaaux +1;
        dia(i) = diaaux;
        mes(i) = mesaux;
        anual(i) = anualaux;
        if dia(i) > diasmes(mesaux)
            mesaux = mesaux + 1;
            mes(i) = mesaux;
            diaaux = 1;
            dia(i) = diaaux;
            horaaux = 1;
            hora(i) = horaaux;
            anual(i) = anualaux;
            if mes(i) > 12
                mesaux = 1;
                diaaux = 1;
                horaaux = 1;
                anualaux = anualaux +1;
                mes(i) = mesaux;
                anual(i) = anualaux;
                dia(i) = diaaux;
                hora(i) = horaaux;
            end
        end 
    end
    horaaux = horaaux + 1;   
end
horaaux = 1;
diaaux = 1;
for i = 1:1:8760*3
    if horaaux > 24
        diaaux = diaaux + 1;
        horaaux = 1;
        if diaaux > 7
            diaaux = 1;
            tipodia(i) = diasemana(diaaux);
        else
            tipodia(i) = diasemana(diaaux);
        end
        horaaux = horaaux + 1;
    else
        tipodia(i) = diasemana(diaaux);
        horaaux = horaaux + 1;
    end
end
matrizcompleta = [tipodia hora dia mes anual];
%% Exportar datos de demandas
subestaciones = ["San Cristobal", "Macul", "Lo Valledor", "La Reina", "Club Hipico", "Brasil", "Alonso de Cordova"];
matriz_demanda = [];
for i = 1:1:length(subestaciones)
    datos = exportararchivo(subestaciones(i));
    if length(datos)>8760*3
        datos(26281:26282,:) = [];
    end
    matriz_demanda(:,i) = datos;
end 
%% Matdem MWh
matdemmwh = matriz_demanda./1000;
plot(matdemmwh(:,6),'b')
axis([0 26280 0 100])
xlabel('Horizonte horario [H]')
ylabel('Demanda [MWh]')
title('Demanda horaria subestación Brasil (Enero 2017 a Diciembre 2019)')
%% ordenar datos
matriz_demanda = matriz_demanda./1000;
capacidadesSSEE = [175 150 100 170 125 150 150]; %Info de planos de SSEE (trafos de 12 - 12.5 kV)
matriz_normal = matriz_demanda./capacidadesSSEE;
ma1 = reshape(matriz_normal(:,1),[8760,3]);
ma2 = reshape(matriz_normal(:,2),[8760,3]);
ma3 = reshape(matriz_normal(:,3),[8760,3]);
ma4 = reshape(matriz_normal(:,4),[8760,3]);
ma5 = reshape(matriz_normal(:,5),[8760,3]);
ma6 = reshape(matriz_normal(:,6),[8760,3]);
ma7 = reshape(matriz_normal(:,7),[8760,3]);
%% ajuste de días (crear perfiles consistentes con la semana)
%ssee1
maux1 = ma1(:,1);
maux2 = ma1(:,2);
maux2(8737:8760) = [];
maux2 = [maux1(1:24); maux2];
maux3 = ma1(:,3);
maux3(1:24) = [];
maux3(8689:8736) = [];
maux3 = [maux2(1:72); maux3];
ma1 = [maux1 maux2 maux3];
%ssee2
maux1 = ma2(:,1);
maux2 = ma2(:,2);
maux2(8737:8760) = [];
maux2 = [maux1(1:24); maux2];
maux3 = ma2(:,3);
maux3(1:24) = [];
maux3(8689:8736) = [];
maux3 = [maux2(1:72); maux3];
ma2 = [maux1 maux2 maux3];
%ssee3
maux1 = ma3(:,1);
maux2 = ma3(:,2);
maux2(8737:8760) = [];
maux2 = [maux1(1:24); maux2];
maux3 = ma3(:,3);
maux3(1:24) = [];
maux3(8689:8736) = [];
maux3 = [maux2(1:72); maux3];
ma3 = [maux1 maux2 maux3];
%ssee4
maux1 = ma4(:,1);
maux2 = ma4(:,2);
maux2(8737:8760) = [];
maux2 = [maux1(1:24); maux2];
maux3 = ma4(:,3);
maux3(1:24) = [];
maux3(8689:8736) = [];
maux3 = [maux2(1:72); maux3];
ma4 = [maux1 maux2 maux3];
%ssee5
maux1 = ma5(:,1);
maux2 = ma5(:,2);
maux2(8737:8760) = [];
maux2 = [maux1(1:24); maux2];
maux3 = ma5(:,3);
maux3(1:24) = [];
maux3(8689:8736) = [];
maux3 = [maux2(1:72); maux3];
ma5 = [maux1 maux2 maux3];
%ssee6
maux1 = ma6(:,1);
maux2 = ma6(:,2);
maux2(8737:8760) = [];
maux2 = [maux1(1:24); maux2];
maux3 = ma6(:,3);
maux3(1:24) = [];
maux3(8689:8736) = [];
maux3 = [maux2(1:72); maux3];
ma6 = [maux1 maux2 maux3];
%ssee7
maux1 = ma7(:,1);
maux2 = ma7(:,2);
maux2(8737:8760) = [];
maux2 = [maux1(1:24); maux2];
maux3 = ma7(:,3);
maux3(1:24) = [];
maux3(8689:8736) = [];
maux3 = [maux2(1:72); maux3];
ma7 = [maux1 maux2 maux3];
matriz_demanda_normal = [ma1 ma2 ma3 ma4 ma5 ma6 ma7];
%% Generador de perfiles 
perfil_demanda_nodos = zeros(8760,32);
for i = 1:1:32
    perfil_demanda_nodos(:,i) = matriz_demanda_normal(:,randi([1 21]));
end
for i = 1:1:32
    for j = 1:1:8760
        if perfil_demanda_nodos(j,i)<0
            perfil_demanda_nodos(j,i) = perfil_demanda_nodos(j,i)*-1;
        end
    end
end
%% Datos de potencia de red
[~, ~, raw] = xlsread('C:\Users\danil\OneDrive\Escritorio\Version Definitiva\Origen-destino\Modelo de carga domicilairia\potnom.xlsx','Hoja1','A2:B33');
data = reshape([raw{:}],size(raw));
P = data(:,1);
Q = data(:,2);
clearvars data raw;
%% Curvas P,Q,S
S = sqrt(P.^2+Q.^2);
S_tot = sum(S);
P_red = perfil_demanda_nodos.*transpose(P);
Q_red = perfil_demanda_nodos.*transpose(Q);
for i = 1:1:32
    for j = 1:1:8760
        if P_red(j,i) < 0
            P_red(j,i) = P_red(j,i)*-1;
        end
        if Q_red(j,i) < 0
           Q_red(j,i) = Q_red(j,i)*-1;
        end
    end
end
S_red = sqrt(P_red.^2+Q_red.^2);
S_tot_diario = sum(S_red,2);
P_tot_diario = sum(P_red,2);
%% Demandas para analisis
j = 1;
k = 24;
for i = 1:1:365
    P_diario(i) = sum(P_tot_diario(j:k));
    j = j + 24;
    k = k + 24;
end
j = 1;
k = 0;
for i = 1:1:12
    k = k + diasmes(i);
    P_mensual(i) = sum(P_diario(j:k));
    j = k+1 ;
end
%% Promedio trimestral y diario (potencia total SSEE)
horas_sem = 24*[(31+28+31) (30+31+30) (31+31+30) (31+30+31)];
horas_semestre = [horas_sem(1) horas_sem(1)+horas_sem(2) horas_sem(1)+horas_sem(2)+horas_sem(3) horas_sem(1)+horas_sem(2)+horas_sem(3)+horas_sem(4)];
dem_tr1 = P_tot_diario(1:horas_semestre(1));
dem_tr2 = P_tot_diario(horas_semestre(1)+1:horas_semestre(2));
dem_tr3 = P_tot_diario(horas_semestre(2)+1:horas_semestre(3));
dem_tr4 = P_tot_diario(horas_semestre(3)+1:horas_semestre(4));
dem_tr1_diario = reshape(dem_tr1,[24,90]);
dem_tr2_diario = reshape(dem_tr2,[24,91]);
dem_tr3_diario = reshape(dem_tr3,[24,92]);
dem_tr4_diario = reshape(dem_tr4,[24,92]);
media_tr1 = mean(dem_tr1_diario,2);
media_tr2 = mean(dem_tr2_diario,2);
media_tr3 = mean(dem_tr3_diario,2);
media_tr4 = mean(dem_tr4_diario,2);
%% Promedio diario nodal
P_media_diaria_anual = mean(P_red,2);
P_dem_diaria_tr1 = P_media_diaria_anual(1:horas_semestre(1));
P_dem_diaria_tr2 = P_media_diaria_anual(horas_semestre(1)+1:horas_semestre(2));
P_dem_diaria_tr3 = P_media_diaria_anual(horas_semestre(2)+1:horas_semestre(3));
P_dem_diaria_tr4 = P_media_diaria_anual(horas_semestre(3)+1:horas_semestre(4));
P_dem_tr1_diario = reshape(P_dem_diaria_tr1,[24,90]);
P_dem_tr2_diario = reshape(P_dem_diaria_tr2,[24,91]);
P_dem_tr3_diario = reshape(P_dem_diaria_tr3,[24,92]);
P_dem_tr4_diario = reshape(P_dem_diaria_tr4,[24,92]);    
P_media_tr1 = mean(P_dem_tr1_diario,2);
P_media_tr2 = mean(P_dem_tr2_diario,2);
P_media_tr3 = mean(P_dem_tr3_diario,2);
P_media_tr4 = mean(P_dem_tr4_diario,2);    
%% Promedio diario (curva diaria)
potenciaxdia = reshape(P_media_diaria_anual,[24,365]);
Potencia_media_diaria = mean(potenciaxdia,2);
%% calculo de clientes por nodo
% Energia anual x cliente 2077 kWh/año (fuente estudio uso energia hogares
% en chile)
P_tot_nodo_anual = sum(P_red);
clientes_tot = round(P_tot_nodo_anual/2077);
%% Gráficas
% demanda media total x trimestre
figure(1)
subplot(2,2,1)
plot(media_tr1,'r')
xlim([1 24])
xlabel('Tiempo [H]')
ylabel('Demanda [kWh]')
title('Total de Demanda media diaria [Ene - Mar]')
subplot(2,2,2)
plot(media_tr2,'r')
xlim([1 24])
xlabel('Tiempo [H]')
ylabel('Demanda [kWh]')
title('Total de Demanda media diaria [Abr - Jun]')
subplot(2,2,3)
plot(media_tr3,'r')
xlim([1 24])
xlabel('Tiempo [H]')
ylabel('Demanda [kWh]')
title('Total de Demanda media diaria [Jul - Sep]')
subplot(2,2,4)
plot(media_tr4,'r')
xlim([1 24])
xlabel('Tiempo [H]')
ylabel('Demanda [kWh]')
title('Total de Demanda media diaria [Oct - Dic]')
% Demanda media nodal x trimestre
figure(2)
subplot(2,2,1)
plot(P_media_tr1)
xlim([1 24])
xlabel('Tiempo [H]')
ylabel('Demanda [kWh]')
title('Demanda nodal media diaria  [Ene - Mar]')
subplot(2,2,2)
plot(P_media_tr2)
xlim([1 24])
xlabel('Tiempo [H]')
ylabel('Demanda [kWh]')
title('Demanda nodal media diaria [Abr - Jun]')
subplot(2,2,3)
plot(P_media_tr3)
xlim([1 24])
xlabel('Tiempo [H]')
ylabel('Demanda [kWh]')
title('Demanda nodal media diaria [Jul - Sep]')
subplot(2,2,4)
plot(P_media_tr4)
xlim([1 24])
xlabel('Tiempo [H]')
ylabel('Demanda [kWh]')
title('Demanda nodal media diaria [Oct - Dic]')
% Demanda diaria total
figure(3)
bar(P_diario./1000)
ylim([18 40])
xlabel('Día')
ylabel('Demanda [MWh]')
title('Demanda Total Diaria')
%% promedio demanda diaria (todos los datos)
maximo_diario = max(transpose(potenciaxdia));
minimo_diario = min(transpose(potenciaxdia));
figure(4)
plot(maximo_diario,'r')
hold on
plot(Potencia_media_diaria,'g')
plot(minimo_diario,'b')
legend('Máximo', 'Media', 'Mínimo')
xlabel('Tiempo [H]')
ylabel('Demanda [kWh]')
xlim([1 24])
title('Demanda Nodal Diaria')
%% Guardar datos
%file = "C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Datos DSS\Perfiles_carga.csv";
%filex = "C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Datos DSS\Perfiles_carga.xlsx";
%filey = "C:\Users\dany_\Desktop\New tesis\Simulaciones Tesis\Version Definitiva\Red 33 v4\Datos DSS\N_clientes.csv";
%csvwrite(file,perfil_demanda_nodos)
%xlswrite(filex,perfil_demanda_nodos)
%csvwrite(filey,clientes_tot)