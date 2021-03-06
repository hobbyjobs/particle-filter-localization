function [ q,laser_hit_p ] = beam_range_finder_model( zt, xt, map, laser_max_range, std_dev_hit, lambda_short, zParams, occupied_threshold, map_resolution,num_interval )
%beam_range_finder_model Summary of this function goes here
%   Detailed explanation goes here

% zt:
%   A 180-by-1 vector of laser range values reported from the sensor

% xt:
%   A 3-by-1 vector for the robot's position and orientation

% map:
%   The occupancy grid map to localize within

% global laser_max_range std_dev_hit lambda_short zParams occupied_threshold map_resolution

q = 1;

zHit = zParams(1);
zShort = zParams(2);
zMax = zParams(3);
zRand = zParams(4);


numLaserScans = length(zt);

robot_angle_rad = xt(3);
robot_angle_deg = robot_angle_rad * 180/pi;
robot_position_m = xt(1:2);
laser_position_m = robot_position_m + [ 0.25*cosd(robot_angle_deg); 
                                        0.25*sind(robot_angle_deg)];

[z_expected,laser_hit_p] = findExpectedRange_(robot_angle_deg, laser_position_m', map, laser_max_range, occupied_threshold, map_resolution,num_interval);

count = 1;
for k = 1:num_interval:numLaserScans

    pHit = calcProbHit(zt(k), z_expected(count), laser_max_range, std_dev_hit);
    pShort = calcProbShort(zt(k), z_expected(count), laser_max_range, lambda_short);
    pMax = calcProbMax(zt(k), z_expected(count), laser_max_range);
    pRand = calcProbRand(zt(k), z_expected(count), laser_max_range);
    
    p = zHit*pHit + zShort*pShort + zMax*pMax + zRand*pRand;
    
    q = q*p;
    count = count + 1;
end

% q = q^(1/10);
% figure, plot(z_expected, '.');
end

