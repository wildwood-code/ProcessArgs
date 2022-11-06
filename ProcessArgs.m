classdef ProcessArgs
% PROCESSARGS  process an a positional/named argument list
%   P = PROCESSARGS(varargin{:})
%   P.num_args         -> number of arguments found
%   P.num_pos          -> number of positional arguments found
%   P.num_named        -> number of named arguments found
%   P(index)           -> positional argument value
%   P(index, default)  -> positional arguments with default value
%   P(name)            -> named argument value
%   P(name, default)   -> named arguments with default value
%   P.name             -> named argument value
%   P.is_named_arg(name) -> check to see if named argument was supplied
%   P.names            -> get cell array of named arguments supplied
%     index = numeric index 1..end
%     name = string or char array name
%
% Notes:
%   Positional arguments must come before named arguments
%   Positional arguments may be of any type.
%   Named arguments are supplied as a string or char array.
%   Named arguments take the form "name=value"
%   Name must start with a letter, and contain only letters, numbers, or _
%   Value can contain any characters

% Kerry S. Martin, martin@wild-wood.net, 4/13/2019
    
    properties (SetAccess = protected)
        
        num_args
        num_pos
        num_named
        names
        
    end
    
    properties (Access = protected)
        
        positional
        values
        
    end
    
    methods (Access = public)
        
        function obj = ProcessArgs(varargin)
            if nargin>0
                obj = ProcessArgs.ProcessVarargin(varargin{:});
            else
                obj.num_args = 0;
                obj.num_pos = 0;
                obj.num_named = 0;
                obj.positional = {};
                obj.names = {};
                obj.values = {};
            end
        end
        
        function tf = is_named_arg(v)
            v = convertStringsToChars(v);
            [~,i] = find(cellfun(@(x)isequal(x, v),obj.names));
            tf = ~isempty(i);
        end
        
        function varargout = subsref(obj, S)
            switch S.type
                case '()'
                    if length(S.subs)==1
                        i = S.subs{1};
                        if isnumeric(i)
                            if i<1 || i>obj.num_pos
                                error('Invalid positional index')
                            end
                            varargout{1} = obj.positional{i};
                        elseif ischar(i) || isstring(i)
                            v = convertStringsToChars(i);
                            [~,i] = find(cellfun(@(x)isequal(x, v),obj.names));
                            if isempty(i)
                                error('Unknown named parameter')
                            end
                            varargout{1} = obj.values{i};
                        else
                            error('Invalid positional index')
                        end
                    elseif length(S.subs)==2
                        i = S.subs{1};
                        d = S.subs{2};
                        if isnumeric(i)
                            if i<1 || i>obj.num_pos
                                varargout{1} = d;
                            else
                                varargout{1} = obj.positional{1};
                            end
                        elseif ischar(i) || isstring(i)
                            v = convertStringsToChars(i);
                            [~,i] = find(cellfun(@(x)isequal(x, v),obj.names));
                            if isempty(i)
                                varargout{1} = d;
                            else
                                varargout{1} = obj.values{i};
                            end
                        else
                            error('Invalid positional index')
                        end
                    else
                        error('Invalid positional index dimension')
                    end
                    
                case '.'
                    [~,i] = find(cellfun(@(x)isequal(x, S.subs),obj.names));
                    if isempty(i)
                        error('Unknown named parameter')
                    end
                    varargout{1} = obj.values{i};
                    
                otherwise
                    [varargout{1:nargout}] = builtin('subsref',obj, S);
            end
            
        end
        
    end
    
    methods (Static = true, Access = protected)
        
        obj = ProcessVarargin(varargin);
        
    end
    
end