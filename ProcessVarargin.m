function obj = ProcessVarargin(varargin)

obj = ProcessArgs;  % default object

if nargin>0

    is_still_positional = true;
    
    for V=varargin
        v = V{1};
        if is_strchar(v)
            v = convertStringsToChars(v);
            if is_named(v)
                is_still_positional = false;
                [n,p] = get_named(v);
                obj.names{end+1} = n;
                obj.values{end+1} = p;
                obj.num_named = obj.num_named + 1;
            else
                if ~is_still_positional
                    error('Positional value occurs after named value')
                else
                    obj.positional{end+1} = v;
                    obj.num_pos = obj.num_pos + 1;
                end
                
            end
        else
            if ~is_still_positional
                error('Positional value occurs after named value')
            else
                obj.positional{end+1} = v;
                obj.num_pos = obj.num_pos + 1;
            end
            
        end
        
        obj.num_args = obj.num_args + 1;
        
    end

end

end

function tf = is_named(v)
tf = ~isempty(regexp(v,'^([a-zA-Z][a-zA-Z0-9_]*)=(.+)$','ONCE'));
end

function [n,p] = get_named(v)
tokens = regexp(v, '^([a-zA-Z][a-zA-Z0-9_]*)=(.+)$', 'tokens');
n = tokens{1}{1};
p = tokens{1}{2};
end

function tf = is_strchar(v)
tf = ischar(v) || isstring(v);
end

% Copyright (c) 2024, Kerry S. Martin, martin@wild-wood.net