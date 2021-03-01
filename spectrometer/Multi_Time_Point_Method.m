classdef Multi_Time_Point_Method < Polarization_Method
    
    properties
        t2_array;
        
        nScans_array;
        nScans_Para_array;
        nScans_Perp_array;
        
        hFig;
        hChildren;
        
        t2s_rand;
        nScans_rand;
        nScans_Para_rand;
        nScans_Perp_rand;
        
        current_t2;
        current_nScans;
        current_nScans_Para;
        current_nScans_Perp;
        
        temp_t2_array;
        temp_nScans_array;
        temp_nScans_Para_array;
        temp_nScans_Perp_array;
    end
    
    properties (Abstract)
        scanMethod;
    end
    
    properties (Access=private)
        colNames = {'t2', 'nScans'};
    end
    
    methods
        function Scan(obj)
            obj.ScanIsRunning = true;
            obj.fileSystem.InitializeLocalOutputFile();
            
            t2s = obj.t2_array;
            nScans = obj.nScans_array;
            nScans_Para = obj.nScans_Para_array;
            nScans_Perp = obj.nScans_Perp_array;
            
            permIndex = randperm(length(t2s));
            obj.t2s_rand = t2s(permIndex);
            obj.nScans_rand = nScans(permIndex);
            obj.nScans_Para_rand = nScans_Para(permIndex);
            obj.nScans_Perp_rand = nScans_Perp(permIndex);
            
            for ii = 1:length(t2s)
                if obj.ScanIsStopping == false && ~isempty(obj.t2s_rand{ii})
%                     while obj.ScanIsRunning
%                         pause(1)
%                     end
                    
                    obj.result.polarization = '';
                    %set scans
                    obj.current_nScans = obj.nScans_rand{ii};
                    obj.current_nScans_Para = obj.nScans_Para_rand{ii};
                    obj.current_nScans_Perp = obj.nScans_Perp_rand{ii};
                    
                    set(obj.handles.editnScans, 'String', num2str(obj.current_nScans));
                    if isfield(obj.PARAMS, 'nScans_Para')
                        set(obj.handles.editnScans_Para, 'String', num2str(obj.current_nScans_Para));
                        set(obj.handles.editnScans_Perp, 'String', num2str(obj.current_nScans_Perp));
                    end
                        
                    %set t2
                    obj.current_t2 = obj.t2s_rand{ii};
                    set(obj.handles.editt2, 'String', num2str(obj.current_t2));
                    
                    
                        

    %                 Scan@Method(obj)
    
                    eval(obj.scanMethod);
                    
                    if isempty(obj.result.polarization)
                        obj.fileSystem.AppendLocalOutputFile(obj.current_nScans, obj.current_t2, obj.result.polarization);
                    end

                    pause(1)
                end
            end
            obj.fileSystem.CloseLocalOutputFile();
            obj.fileSystem.SaveOutputFile();
            
            obj.ScanIsRunning = false;
            
            obj.ScanIsStopping = false;
        end
    end
    
    methods % Load & Save Params
        function LoadT2Array(obj)
            name = 't2_array';
            d = Defaults(obj);
            d.LoadDefaults(name);
        end
        
        function SaveT2Array(obj)
            name = 't2_array';
            d = Defaults(obj);
            d.SaveDefaults(name);
        end
        
        function LoadnScansArray(obj)
            name = {'nScans_array', 'nScans_Para_array', 'nScans_Perp_array'};
            d = Defaults(obj);
            d.LoadDefaults(name);
        end
        
        function SavenScansArray(obj)
            name = {'nScans_array', 'nScans_Para_array', 'nScans_Perp_array'};
            d = Defaults(obj);
            d.SaveDefaults(name);
        end
    end
    
    methods % GUI Stuff
        function createParamsButton(obj)
            
            uicontrol(obj.hParamsPanel, 'style', 'pushbutton','Tag','pbInputButton',...
                'String', 'Set Time Points', 'Units', 'characters',...
                'Position',[2 0.4 30 1.7400],...
                'Callback', {@(eventdata, handles) pbInputButton_Callback(obj,eventdata, handles)});
                
            obj.handles = guihandles(obj.handles.figure1);
        end
        
        function createInputWindow(obj)
            obj.hFig = uifigure('Name', 'Time Point Entry', 'Position', [680 500 250 500],...
                'resize', 'off'...
                );
        end
        
        function createInputTable(obj)
            
            obj.temp_t2_array = obj.t2_array;
            obj.temp_nScans_array = obj.nScans_array;
            obj.temp_nScans_Para_array = obj.nScans_Para_array;
            obj.temp_nScans_Perp_array = obj.nScans_Perp_array;

            tbl = table(obj.t2_array, obj.nScans_array, 'VariableNames', {'t2_array', 'nScans_array'});
            
            obj.hChildren{1} = uitable(obj.hFig, 'Position', [15, 73, 220 415],...
                'Tag', 't2_nScans_uitable',...
                'ColumnName', obj.colNames, 'ColumnEditable', true, ...
                'RowName', 'numbered', 'Data', tbl ...
                );
        end
        
        function createSaveButton(obj)
            
            obj.hChildren{2} = uibutton(obj.hFig, 'push', 'Tag', 'pbSave', ...
                'Text', 'Save', 'Position', [obj.hFig.Position(3)-115 10 100 28], ...
                'ButtonPushedFcn', {@(eventdata, handles) pbSave_ButtonPushedFcn(obj,eventdata, handles)}...
                );
        end
           
        function createCancelButton(obj)
            obj.hChildren{3} = uibutton(obj.hFig, 'push', 'Tag', 'pbCancel',...
                'Text', 'Cancel', 'Position', [obj.hFig.Position(3)-235 10 100 28], ...
                'ButtonPushedFcn', {@(eventdata, handles) pbCancel_ButtonPushedFcn(obj,eventdata, handles)}...
                );
        end
            
        function createAddRowButton(obj)
            obj.hChildren{4} = uibutton(obj.hFig, 'push', 'Tag', 'pbAddRow',...
                'Text', '+', 'Position', [obj.hFig.Position(3)-35 50 20 20], 'ToolTip', 'Add a row',...
                'ButtonPushedFcn', {@(eventdata, handles) pbAddRow_ButtonPushedFcn(obj,eventdata, handles)}...
                );
        end
           
        function createRemoveRowButton(obj)
            obj.hChildren{5} = uibutton(obj.hFig, 'push', 'Tag', 'pbRemoveRow',...
                'Text', '-', 'Position', [obj.hFig.Position(3)-55 50 20 20], 'ToolTip', 'Remove a row',...
                'ButtonPushedFcn', {@(eventdata, handles) pbRemoveRow_ButtonPushedFcn(obj,eventdata, handles)}...
                );
        end
        
        function InitializeInputWindow(obj)
            obj.createInputWindow();
            obj.createInputTable();
            obj.createSaveButton();
            obj.createCancelButton();
            obj.createAddRowButton();
            obj.createRemoveRowButton();
        end
    end
    
    methods % Table interactions
        function ReadTable(obj)
            data = get(obj.hChildren{1}, 'Data');
            names = data.Properties.VariableNames;
            
            for ii = 1:length(names)
                obj.(['temp_' names{ii}]) = data.(names{ii});
            end
            
            obj.t2_array = obj.temp_t2_array;
            obj.nScans_array = obj.temp_nScans_array;
            obj.nScans_Para_array = obj.temp_nScans_Para_array;
            obj.nScans_Perp_array = obj.temp_nScans_Perp_array;

        end
        
        
        function UpdateTable(obj)
            tbl = table(obj.temp_t2_array, obj.temp_nScans_array, 'VariableNames', {'t2_array', 'nScans_array'});
            set(obj.hChildren{1}, 'Data', tbl);            
        end
    end
    
    methods % Callback Functions
        function pbInputButton_Callback(obj, eventdata, handles)
            obj.InitializeInputWindow();
        end
        
        function pbSave_ButtonPushedFcn(obj, eventdata, handles)
            obj.ReadTable();
            
            obj.SaveT2Array();
            obj.SavenScansArray();
            
            delete(obj.hFig);
        end
        
        function pbCancel_ButtonPushedFcn(obj, eventdata, handles)
            delete(obj.hFig)
        end
        
        function pbAddRow_ButtonPushedFcn(obj, eventdata, handles)
            obj.temp_t2_array{end+1} = [];
            obj.temp_nScans_array{end+1} = [];
            obj.temp_nScans_Para_array{end+1} = [];
            obj.temp_nScans_Perp_array{end+1} = [];
            
            obj.UpdateTable();
        end
        
        function pbRemoveRow_ButtonPushedFcn(obj, eventdata, handles)
            obj.temp_t2_array = obj.temp_t2_array(1:end-1);
            obj.temp_nScans_array = obj.temp_nScans_array(1:end-1);
            obj.temp_nScans_Para_array = obj.temp_nScans_Para_array(1:end-1);
            obj.temp_nScans_Perp_array = obj.temp_nScans_Perp_array(1:end-1);
            
            obj.UpdateTable();
        end
        
    end
end