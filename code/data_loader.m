function [csi_trace] = data_loader(read_root_path,files)
    
    read_path = strcat(read_root_path,files.name); 
    csi_trace = read_bf_file(read_path);
    csi_trace(cellfun(@isempty,csi_trace))=[];  









    