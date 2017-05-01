function screen = fixcross(screen)
% Define fixation cross

%Fixation Cross
f_c_size = 38;
fw       = 1;

%set up fixation cross
f_c         = screen.bgcolor*ones(f_c_size);
vert_center = f_c_size/2; % x location of vertical bar (the pixel .5 px left of center)
horz_center = f_c_size/2; % y location of vertical bar (the pixel .5 px above center)
f_c(:, vert_center - fw: vert_center + 1 + fw) = screen.darkgray;
f_c(horz_center - fw: horz_center + 1 + fw,:)  = screen.darkgray;
screen.cross = Screen('MakeTexture', screen.window , f_c);

