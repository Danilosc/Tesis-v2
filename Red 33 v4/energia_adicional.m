%% Función Vector de energía adicional
function E_adicional = energia_adicional(tipoEV, km, eficiencia_carga, matriztipoEV,perfil_aux)
if tipoEV == 1
    Ekm = matriztipoEV(1,1)./matriztipoEV(1,3);
    E_adicional = km*Ekm*1/eficiencia_carga;
elseif tipoEV == 1
    Ekm = matriztipoEV(2,1)./matriztipoEV(2,3);
    E_adicional = km*Ekm*1/eficiencia_carga;
elseif tipoEV == 1
    Ekm = matriztipoEV(3,1)./matriztipoEV(3,3);
    E_adicional = km*Ekm*1/eficiencia_carga;
elseif tipoEV == 1
    Ekm = matriztipoEV(4,1)./matriztipoEV(4,3);
    E_adicional = km*Ekm*1/eficiencia_carga;
else
    Ekm = matriztipoEV(5,1)./matriztipoEV(5,3);
    E_adicional = km*Ekm*1/eficiencia_carga;
end
Matriz_E_adi = zeros(length(perfil_aux),1);
for i=1:1:lenght(perfil_aux)
    if perfil_aux(i)>0
        perfil_aux(i) = perfil_aux(i) + E_adicional;
        Matriz_E_adi(i) = E_adicional;
    end
end