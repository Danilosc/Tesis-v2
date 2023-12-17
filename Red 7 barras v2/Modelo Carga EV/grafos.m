%% Calculo promedios diarios
promedioh_carga = mean(matriz_carga,2);
promedioh_carga_dom = mean(matriz_carga_dom,2);
a = reshape(promedioh_carga,[24,365]);
b = reshape(promedioh_carga_dom,[24,365]);
promedio1 = mean(a,2);
promedio2 = mean(b,2);
figure(1)
plot(promedio1)
figure(2)
plot(promedio2)
%% Comprobacion energía
E_anual_cargada1 = sum(matriz_carga_dom_def).*eficiencia(1,1)+sum(matriz_carga_def).*eficiencia(1,2);
E_anual_consumida1 = sum(matriz_carga_dom_def)+sum(matriz_carga_def);
E_anual_viajes1 = sum(matriz_E_hora_def);
Delta_E1 = E_anual_cargada1 - E_anual_viajes1;
Delta_SoC1 = matriz_SoC_def(1,:) - matriz_SoC_def(8760,:);
%% Soc a energia x vehiculo
for i = 1:1:length(Delta_E1)
    if user_EV_def(i) == "Nissan Leaf V1"
        delta_soc_E1(i) = Delta_SoC1(i)*40;
    elseif user_EV_def(i) == "Nissan Leaf V2"
        delta_soc_E1(i) = Delta_SoC1(i)*62;
    elseif user_EV_def(i) == "Hyundai Ioniq EV"
        delta_soc_E1(i) = Delta_SoC1(i)*40.4;
    elseif user_EV_def(i) == "BMW i3"
        delta_soc_E1(i) = Delta_SoC1(i)*42.2;
    elseif user_EV_def(i) == "Renault Zoe"
        delta_soc_E1(i) = Delta_SoC1(i)*54.7;
    end
end
comprobacion1 = Delta_E1 + delta_soc_E1;
errores1 = length(find(comprobacion1>0.01));
%% Plotvarios
yyaxis right
plot(matriz_carga(:,1));
hold on
plot(matriz_carga_dom(:,1));
yyaxis left
plot(matriz_SoC(:,1));