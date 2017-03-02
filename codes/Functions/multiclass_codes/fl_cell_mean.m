function m = fl_cell_mean(Cell)
%function m = fl_cell_mean(Cell,dim)
%
% Average across elements of vector array, 1D
% Important: the function does not make an internal copy of the cell
% variable. Critical for large data sets

% Author: Dimitrios Pantazis

N = length(Cell);

m = Cell{1};
for i = 2:N
    m = m + Cell{i};
end
m = m/N;
    
  

