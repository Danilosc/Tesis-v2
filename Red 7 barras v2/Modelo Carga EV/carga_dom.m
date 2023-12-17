%% Función de evaluación de carga vehiculos eléctricos domiciliario y rápido emergencia
function [Soc_EV,Carga_EV,Carga_EV_domicilio,Flag_dom,Soc_fin] = carga_dom(Soc_ini, Eficiencia_rapida, Eficiencia_dom, bateria_util, Soc_min, vector_viaje, vector_energia, Emax_dom, Emax_carga, tiempo_carga, flag_anterior)
%% Vectores iniciales
Soc_EV = zeros(26,1);
Carga_EV = zeros(26,1);
Carga_EV_domicilio = zeros(26,1);
Soc_EV(1) = Soc_ini;
%% Inicio comparación de casos
% Caso 1: señal de que la carga del vehiculo inicio el día anterior
% Flag_anterior = 1
Flag_dom = flag_anterior; %Flag indicador de si hubo carga el día anterior
if Flag_dom == 1
    for i = 2:1:26
        Soc_EV(i) = Soc_EV(i-1);
        if vector_viaje(i) == 1
            Flag_dom = 0; %Indica que se desactiva la condición de carga domiciliaria
            Soc_EV(i) = Soc_EV(i) - vector_energia(i)/bateria_util; %Soc post- viaje
            if Soc_EV(i) < Soc_min %condicion soc minimo --> cargar rápido
                Delta_soc = Soc_min - Soc_EV(i);
                carga_aux = Emax_carga(i);
                Soc_aux = Soc_min + carga_aux*Eficiencia_rapida/bateria_util;
                if Soc_aux > 1
                    Soc_EV(i) = 1 - Delta_soc;
                    Carga_EV(i) = (1 - Soc_min)*bateria_util/Eficiencia_rapida;
                else
                   Soc_EV(i) = Soc_aux - Delta_soc;
                   Carga_EV(i) = carga_aux;
                end
            else
                Carga_EV(i) = 0;
            end
        elseif vector_viaje(i) == 0
            if i <= 9 && Flag_dom == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                end
            else
                Soc_EV(i) = Soc_EV(i-1);
                Carga_EV_domicilio(i) = 0;
            end
        end
    end
% Caso 2: Flag anterior = 0, se prmite carga domiciliaria en horas de la
% tarde- noche desde las 20 horas.
else %% Se permite carga domiciliaria en la tarde
    y = find(vector_viaje,1,'last');
    x = max(19,y);
    for i = 2:1:26
        Soc_EV(i) = Soc_EV(i-1);
        if i <= x
            if vector_viaje(i) == 1 %Existe viaje antes de las 19
                Soc_EV(i) = Soc_EV(i) - vector_energia(i)/bateria_util; %Soc post- viaje
                if Soc_EV(i) < Soc_min %condicion soc minimo --> cargar rápido
                    Delta_soc = Soc_min - Soc_EV(i);
                    carga_aux = Emax_carga(i);
                    Soc_aux = Soc_min + carga_aux*Eficiencia_rapida/bateria_util;
                    Flag_dom = 0;
                    if Soc_aux > 1
                        Soc_EV(i) = 1 - Delta_soc;
                        Carga_EV(i) = (1 - Soc_min)*bateria_util/Eficiencia_rapida;
                    else
                        Soc_EV(i) = Soc_aux - Delta_soc;
                        Carga_EV(i) = carga_aux;
                    end
                else
                    Carga_EV(i) = 0;
                end
            else %vector_viaje(i) == 0 No existe viaje 
                Soc_EV(i) = Soc_EV(i-1);
            end
        elseif (i > x) && (Flag_dom == 1)
            carga_aux = Emax_dom;
            Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
            if Soc_aux > 1
                Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                Soc_EV(i) = 1;
                Flag_dom = 0;
            else
                Soc_EV(i) = Soc_aux;
                Carga_EV_domicilio(i) = carga_aux;
                Flag_dom = 1;
            end    
        elseif (i > x) && (Flag_dom == 0)
            if (Soc_EV(i)<= 0.25)
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end    
            elseif (0.25 < Soc_EV(i)) && (Soc_EV(i)<= 0.3)
            prob_carg = random('Binomial',1,0.90);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.3 < Soc_EV(i)) && (Soc_EV(i)<= 0.35)
            prob_carg = random('Binomial',1,0.80);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.35 < Soc_EV(i)) && (Soc_EV(i)<= 0.4)
            prob_carg = random('Binomial',1,0.70);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.4 < Soc_EV(i)) && (Soc_EV(i)<= 0.45)
            prob_carg = random('Binomial',1,0.60);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.45 < Soc_EV(i)) && (Soc_EV(i)<= 0.5)
            prob_carg = random('Binomial',1,0.55);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.5 < Soc_EV(i)) && (Soc_EV(i)<= 0.55)
            prob_carg = random('Binomial',1,0.5);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.55 < Soc_EV(i)) && (Soc_EV(i)<= 0.6)
            prob_carg = random('Binomial',1,0.45);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.6 < Soc_EV(i)) && (Soc_EV(i)<= 0.650)
            prob_carg = random('Binomial',1,0.4);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.650 < Soc_EV(i)) && (Soc_EV(i)<= 0.7)
            prob_carg = random('Binomial',1,0.35);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.7 < Soc_EV(i)) && (Soc_EV(i)<= 0.75)
            prob_carg = random('Binomial',1,0.3);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.75 < Soc_EV(i)) && (Soc_EV(i)<= 0.8)
            prob_carg = random('Binomial',1,0.25);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.8 < Soc_EV(i)) && (Soc_EV(i)<= 0.85)
            prob_carg = random('Binomial',1,0.2);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.85 < Soc_EV(i)) && (Soc_EV(i)<= 0.9)
            prob_carg = random('Binomial',1,0.15);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.9 < Soc_EV(i)) && (Soc_EV(i)<= 0.95)
            prob_carg = random('Binomial',1,0.10);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            elseif (0.95 < Soc_EV(i)) && (Soc_EV(i)<= 1)
            prob_carg = random('Binomial',1,0.05);
            if prob_carg == 1
                carga_aux = Emax_dom;
                Soc_aux = Soc_EV(i) + Emax_dom*Eficiencia_dom/bateria_util;
                if Soc_aux > 1
                    Carga_EV_domicilio(i) = (1 - Soc_EV(i))*bateria_util/Eficiencia_dom;
                    Soc_EV(i) = 1;
                    Flag_dom = 0;
                else
                    Soc_EV(i) = Soc_aux;
                    Carga_EV_domicilio(i) = carga_aux;
                    Flag_dom = 1;
                end 
            else
                Carga_EV(i) = 0;
            end
            end
        else
            Soc_EV(i) = Soc_EV(i-1);
        end
    end
end
Soc_fin = Soc_EV(25);                  
end
            
