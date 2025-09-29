% loopindtest
clc; clear; close all


test = [1 2 3]; 
no_test = length(test);
criteria = [.1 .01 .001 .0001];
no_crit = length(criteria);

no_data = no_test*no_crit;

results = zeros(no_test,no_crit);

for i = 1:no_data
    row = idivide(i-1,uint8(no_crit)) + 1;
    col = i - ((row-1)*no_crit);
    
    results(row,col) = test(row)*criteria(col);
    
end

results