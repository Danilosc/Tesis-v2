function x = obtenermonitor(nombremonitor,canal)
    DSSobj = actxserver ('OpenDSSEngine.DSS');
    DSSCircuit = DSSobj.ActiveCircuit;
    DSSMonitors = DSSCircuit.Monitors;
    %idmonitor = DSSMonitors.allNames;
    DSSMonitors.Name = string(nombremonitor);
    x = DSSMonitors.Channel(canal);
    plot(x)
end