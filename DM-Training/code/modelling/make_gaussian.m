function gaussian_profile = make_gaussian(x0,y0,sigma_x,sigma_y,g_size)       

        for theta = 0:pi/360:pi
            a = cos(theta)^2/2/sigma_x^2 + sin(theta)^2/2/sigma_y^2;
            b = -sin(2*theta)/4/sigma_x^2 + sin(2*theta)/4/sigma_y^2 ;
            c = sin(theta)^2/2/sigma_x^2 + cos(theta)^2/2/sigma_y^2;
        end       
        
        x_space = linspace( - round(g_size/2), round(g_size/2),g_size);
        [X, Y] = meshgrid(x_space, x_space);
        gaussian_profile = exp( - (a*(X-x0).^2 + 2*b*(X-x0).*(Y-y0) + c*(Y-y0).^2)) ;
        gaussian_profile = gaussian_profile ./ max(max(gaussian_profile));    
end
    