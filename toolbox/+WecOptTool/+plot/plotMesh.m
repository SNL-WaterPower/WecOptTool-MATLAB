function plotMesh(input, newFig)
    % Plot a mesh
    
    arguments
        input
        newFig = true
    end

    n = size(input.panels, 1);
    
    X = zeros(4, n);
    Y = zeros(4, n);
    Z = zeros(4, n);
    
    for i = 1:n
        X(:, i) = input.nodes(input.panels(i, :), :).x;
        Y(:, i) = input.nodes(input.panels(i, :), :).y;
        Z(:, i) = input.nodes(input.panels(i, :), :).z;
    end
    
    if newFig
        figure
    end
    
    fill3(X, Y, Z, 'r')
    xlabel("x")
    ylabel("y")
    zlabel("z")
    
    axis image
    
    if ~input.xzSymmetric
        return
    end
    
    for i = 1:n
        Y(:, i) = -input.nodes(input.panels(i, :), :).y;
    end
    
    hold on
    fill3(X, Y, Z, 'r')
    
end

