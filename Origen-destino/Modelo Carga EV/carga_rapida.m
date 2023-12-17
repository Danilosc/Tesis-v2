%%  Carga rápida de EVs 
function [Soc_EV,Carga_EV,Soc_fin, Carga_EV_domicilio] = carga_rapida(Soc_ini, Eficiencia_rapida, bateria_util, Soc_min, vector_viaje, vector_energia, Emax_carga, tiempo_carga)
% Crea el vector diario de estado  de carga y si se ejecuta o no una carga
Soc_EV = zeros(26,1);
Carga_EV = zeros(26,1);
Carga_EV_domicilio = zeros(26,1);
Soc_EV(1) = Soc_ini;
flagcarga = 0;  %max de cargas x dia = 2
j = 1;
k = 1;
for i = 2:1:26
    Soc_EV(i) = Soc_EV(i-1); %Soc inicial i igual al soc anterior
    if vector_viaje(i)== 0 %si no existe viaje, entonces el Soc de la hora es igual al Soc de la hora anterior
        Carga_EV(i) = 0; %No se efectua carga si no existe viaje
    else %vector_viaje(i) == 1
        %Inicia evaluación de casos. Caso 1: Soc_EV es menor al Soc min
        Soc_EV(i) = Soc_EV(i) - (vector_energia(i)/bateria_util);
        if Soc_EV(i) < Soc_min %Soc < 20% --> carga inmediata
                Delta_soc = Soc_min - Soc_EV(i);
                Soc_EV(i) = Soc_min;
                carga_aux = Emax_carga(i);
                Soc_aux = Soc_min + carga_aux*Eficiencia_rapida/bateria_util;
                if Soc_aux > 1
                    Soc_EV(i) = 1 - Delta_soc;
                    Carga_EV(i) = (1 - Soc_min)*bateria_util/Eficiencia_rapida;
                else
                   Soc_EV(i) = Soc_aux - Delta_soc;
                   Carga_EV(i) = carga_aux;
                end
                flagcarga = flagcarga + 1;
        % Caso se hayan efectuado a lo más 2 cargas y el Soc sea mayor al minimo        
        elseif flagcarga < 2 && (Soc_EV(i) > Soc_min)
            if (Soc_EV(i)<= 0.25)
                carga_aux = Emax_carga(i);
                Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                if Soc_aux > 1
                    Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                    Soc_EV(i) = 1;
                else
                   Soc_EV(i) = Soc_aux;
                   Carga_EV(i) = carga_aux;
                end
                flagcarga = flagcarga + 1;
            elseif (0.25 < Soc_EV(i)) && (Soc_EV(i)<= 0.3)
                prob_carg = random('Binomial',1,0.90);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.3 < Soc_EV(i)) && (Soc_EV(i)<= 0.35)
                prob_carg = random('Binomial',1,0.80);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.35 < Soc_EV(i)) && (Soc_EV(i)<= 0.4)
                prob_carg = random('Binomial',1,0.70);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.4 < Soc_EV(i)) && (Soc_EV(i)<= 0.45)
                prob_carg = random('Binomial',1,0.60);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.45 < Soc_EV(i)) && (Soc_EV(i)<= 0.5)
                prob_carg = random('Binomial',1,0.55);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.5 < Soc_EV(i)) && (Soc_EV(i)<= 0.55)
                prob_carg = random('Binomial',1,0.5);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.55 < Soc_EV(i)) && (Soc_EV(i)<= 0.6)
                prob_carg = random('Binomial',1,0.45);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.6 < Soc_EV(i)) && (Soc_EV(i)<= 0.650)
                prob_carg = random('Binomial',1,0.4);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.650 < Soc_EV(i)) && (Soc_EV(i)<= 0.7)
                prob_carg = random('Binomial',1,0.35);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.7 < Soc_EV(i)) && (Soc_EV(i)<= 0.75)
                prob_carg = random('Binomial',1,0.3);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.75 < Soc_EV(i)) && (Soc_EV(i)<= 0.8)
                prob_carg = random('Binomial',1,0.25);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.8 < Soc_EV(i)) && (Soc_EV(i)<= 0.85)
                prob_carg = random('Binomial',1,0.2);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.85 < Soc_EV(i)) && (Soc_EV(i)<= 0.9)
                prob_carg = random('Binomial',1,0.15);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.9 < Soc_EV(i)) && (Soc_EV(i)<= 0.95)
                prob_carg = random('Binomial',1,0.10);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            elseif (0.95 < Soc_EV(i)) && (Soc_EV(i)<= 1)
                prob_carg = random('Binomial',1,0.05);
                if prob_carg == 1
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_EV(i) + carga_aux*Eficiencia_rapida/bateria_util;
                    flagcarga = flagcarga + 1;
                    if Soc_aux > 1
                        Carga_EV(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_rapida;
                        Soc_EV(i) = 1;
                    else
                        Soc_EV(i) = Soc_aux;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            end
        end
    end
end
Soc_fin = Soc_EV(26);    
end