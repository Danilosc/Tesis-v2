 function [state,options,changed,str] = gacustom(options,state,flag)
        best_score = 'SaveBest.mat';  % Name File
        poblaciontotal = 'populationtotal.mat';
        puntajes = 'puntajes.mat';
        if strcmp(flag,'init')
            Mejor_score = state.Population;
            Poblacion_total = state.Population;
            Scores_total = state.Score;
            save(best_score, 'Mejor_score')       
            save(poblaciontotal, 'Poblacion_total')  
            save(puntajes, 'Scores_total') % Write ‘Best Individual’ To File
        elseif strcmp(flag,'iter')
            ibest = state.Best(end);
            ibest = find(state.Score == ibest,1,'last');
            bestx = state.Population(ibest,:);
            previous = load('SaveBest.mat');
            previous2 = load('populationtotal.mat');
            previous3 = load('puntajes.mat');
            Mejor_score = [previous.Mejor_score; bestx];  % Read Previous Results, Append New Value
            Poblacion_total = [previous2.Poblacion_total; state.Population];
            Scores_total = [previous3.Scores_total; state.Score];
            save(best_score, 'Mejor_score') % Write ‘Best Individual’ To File
            save(poblaciontotal, 'Poblacion_total')
            save(puntajes, 'Scores_total')
        end
        changed = true;                                                 % Necessary For Cide, Use  App
    end