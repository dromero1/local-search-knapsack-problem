function [X,Z] = kp_grasp(ti,n,p,m,W,A,b,alpha,dbg)
%KP_GRASP GRASP method approximation to the knapsack problem
%
%   Inputs:
%   ti - Test instance
%   n - Number of items
%   p - Number of objectives
%   m - Number of constraints
%   W - Objective coefficients
%   A - Constraint coefficients
%   b - Resource capacity
%   alpha - Best candidate percentage
%   dbg - Debug mode
%
%   Outputs:
%   X - Solutions
%   Z - Objective values

% Solutions
X = false(1,n);
Z = zeros(1,p+1);
fc = 0;

% Main loop
t0 = toc;
i = 1;
while toc - t0 <= 300
    % Randomized constructive solution
    [x,fea,~] = kp_grasp_construct_solution(n,m,W,A,b,alpha);
    if fea == 1
        % Local search
        lX = kp_grasp_local_search(x,n,m,W,A,b);
        % Save local search solutions
        ln = size(lX,1);
        for j = 1:ln
            lx = lX(j,:);
            X(i,:) = lx;
            fea = sum(A*lx' <= b)/m;
            Z(i,:) = [(W*lx')' fea];
            i = i + 1;
            if fea == 1
                fc = fc + 1;
            end
            % Display
            if dbg == true
                fprintf('GRASP Instance %d (alpha = %0.2f, ',ti,alpha);
                fprintf('rep. = %d, feas. = %0.2f)\n',i,fea);
            end
        end
    else
        % Save unfeasible solution
        X(i,:) = x;
        Z(i,:) = [(W*x)' fea];
        i = i + 1;
    end
end

% Remove duplicates
[X,ix,~] = unique(X,'rows');
Z = Z(ix,:);

% Remove infeasible solutions
if fc >= 1
    If = (Z(:,p+1)==1);
    X = X(If,:);
    Z = Z(If,:);
end

% Get non-dominated solutions
[Ipo,~] = pareto_dominance(Z);
X = X(Ipo,:);
Z = Z(Ipo,:);

end