%% Planar Localization
% By Ismael Tahoun and Liam Weston

%% Description
% Please view the README Doc for more comprehensive review
% Code can take up to 60 seconds or longer to print


clc 
clear

format long
tic
%% Known Vairables

c_Sound = 344; %[m/sec] speed of sound

% angle1 = 0:900;
% angle2 = 901:1800;
% angle3 = 1801:2700;
% angle4 = 2701:3600;

angle_Range = 90;


%% Time Difference From Arduino
% This can be automated via Matlab to Arduino interfacing
% This was a brute-force testing algorithm to ensure quality

%% Testing Data
% Method : We selected positions on the plane to test for acurate output.

% (1,1) ---------------------------------> 10.5 cm, 8.4 cm 
% TDOA1 = 0.00;  %take input from arduino
% TDOA2 = 0.000272 ; 
% TDOA3 = 0.000660;
% TDOA4 = 0.000320;

%(5,1) ---------------------------------> 24.79 cm, 9.26 cm 
% TDOA1 = 0.000372;  %take input from arduino
% TDOA2 = 0.00 ; 
% TDOA3 = 0.000340;
% TDOA4 = 0.000628;

%(5,5) ---------------------------------> 26.7 cm, 21.96 cm 
% TDOA1 = 0.000591;  %take input from arduino
% TDOA2 = 0.000375; 
% TDOA3 = 0;
% TDOA4 = 0.000347;

%(1,5) ---------------------------------> 26.7 cm, 21.96 cm 
% TDOA1 = 0.000272;  %take input from arduino
% TDOA2 = 0.000704; 
% TDOA3 = 0.000268;
% TDOA4 = 0;

%(4,4)
% TDOA1 = 0.000183;  %take input from arduino
% TDOA2 = 0.000191; 
% TDOA3 = 0;
% TDOA4 = 0.000183;

TDOA1 = 0.000384;  %take input from arduino
TDOA2 = 0.000; 
TDOA3 = 0.000428;
TDOA4 = 0.000816;





%% Converting TDOA to DDOA

% ASSUMPTION DDOA1 = 0 representing the first signal recieved

DDOA1 = TDOA1 * c_Sound;
DDOA2 = TDOA2 * c_Sound;
DDOA3 = TDOA3 * c_Sound;
DDOA4 = TDOA4 * c_Sound;

% Test 
% DDOA1 = 0;  %take input from arduino
% DDOA2 = .165 ; 
% DDOA3 = .2525;
% DDOA4 = .165;

% Test
% DDOA1 = .165;  %take input from arduino
% DDOA2 = .214;
% DDOA3 = .098;
% DDOA4 = 0;

i_test = 0;

%% Iteration through a varied radius
% IE multilateration algorithm

L = .35; % [m] Length arbitrary
% unknown radius iteration through searching circle circle

search_circ = zeros(3,90);
% [for u = 0:0.01:L]
go = true;
u = 0;
while ((u <= L) && go)
    
    circ1 = zeros(3,90); % Introducing angle ranges around microphones
    circ2 = zeros(3,90);
    circ3 = zeros(3,90);
    circ4 = zeros(3,90);
    
    for iter=1:90
        
        theta_1 = iter;         % Defining the iteration range for mics
        theta_2 = (iter+90);
        theta_3 = (iter+180);
        theta_4 = (iter+270);
        
        circ1(1,iter) = (theta_1);  % indexing the angle range
        circ2(1,iter) = (theta_2);
        circ3(1,iter) = (theta_3);
        circ4(1,iter) = (theta_4);
        
        circ1(2,iter) = (DDOA1+u)*cosd(theta_1);    % cosine componet
        circ2(2,iter) = (DDOA2+u)*cosd(theta_2);
        circ3(2,iter) = (DDOA3+u)*cosd(theta_3);
        circ4(2,iter) = (DDOA4+u)*cosd(theta_4);
        
        circ1(3,iter) = (DDOA1+u)*sind(theta_1);    % sine component
        circ2(3,iter) = (DDOA2+u)*sind(theta_2);
        circ3(3,iter) = (DDOA3+u)*sind(theta_3);
        circ4(3,iter) = (DDOA4+u)*sind(theta_4);
        
    end
    
    x1 = circ1(2,:);      % all values of x in circle 1
    y1 = circ1(3,:);      % all values of y in circle 1
    
    x2 = circ2(2,:) + L;    % math to adjust
    y2 = circ2(3,:);
    
    x3 = circ3(2,:) + L;    % math
    y3 = circ3(3,:) + L;    % math
    
    x4 = circ4(2,:);
    y4 = circ4(3,:) + L;    % math
    
    
    %     x_avg = mean([x1, x2, x3, x4]);
    %     y_avg = mean([y1, y2, y3, y4]);
    
    tol_dist = .05; % tolerance distance
    
    h = 1;
    i = 1;
    j = 1;
    k = 1;
    
    while (h <= length(x1)) && go
        while (i <= length(x2)) && go
            while (j <= length(x3)) && go
                while (k <= length(x4)) && go
                    
%                     x_avg = mean([x1(h), x2(i), x3(j), x4(k)]);
%                     y_avg = mean([y1(h), y2(i), y3(j), y4(k)]);
                    
                    x_avg = (x1(h) + x2(i) + x3(j) + x4(k))/4;
                    y_avg = (y1(h) + y2(i) + y3(j) + y4(k))/4;
                    
                    
                    x_dif1 = abs(x_avg - x1(h));
                    x_dif2 = abs(x_avg - x2(i));
                    x_dif3 = abs(x_avg - x3(j));
                    x_dif4 = abs(x_avg - x4(k));
                    
                    y_dif1 = abs(y_avg - y1(h));
                    y_dif2 = abs(y_avg - y2(i));
                    y_dif3 = abs(y_avg - y3(j));
                    y_dif4 = abs(y_avg - y4(k));
                    
                    % Threshold Testing 
                    
                    if    ((x_dif1 <= tol_dist) && (x_dif2 <= tol_dist) ...
                            && (x_dif3 <= tol_dist) && (x_dif4 <= tol_dist) ...
                            && (y_dif1 <= tol_dist) && (y_dif2 <= tol_dist) ...
                            && (y_dif3 <= tol_dist) && (y_dif4 <= tol_dist))
                        
                        %%%%%%%%%%%% store params
                        str = strcat(['here' num2str(u*100)]);
                        disp(x_avg)
                        disp(y_avg)
                        disp(str)
                        
                        h_val = h;
                        i_val = i;
                        j_val = j;
                        k_val = k;
                        u_val = u;
                        go = false;
                        toc
                        break
                        
                        %%%%%%%%%%%
                        i_test = i_test+1;
                        if i_test == 320000
                            disp('hello')
                        end
                        %%%%%%%%%%%
                    end
                    i_test = i_test+1;
                    k=k+1;
                end
                k = 1;
                j=j+1;
            end
            j = 1;
            i=i+1;
        end
        i = 1;
        h=h+1;
    end
    h = 1;
    
    u = u + 0.01;
    
    
end
disp('here')
toc


