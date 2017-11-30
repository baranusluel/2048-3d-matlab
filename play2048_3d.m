function play2048_3d()
    importImages();
    startMenu();
end

function startMenu()
    reset();
    initializeMenu();
    generateCubesDemo();
    isLoading(false);
    animateCameraDemo();
end

function startGame()
    reset();
    initializeGame();
    %generateCubesGame();
    generateCubesTesting();
    drawArrows();
    animateCameraGame();
    isLoading(false);
end

function reset()
    clear;
    % cube_h: A 4x4x4 cell array for each cube's handles. Each cell contains
    % a cell array containing the cube's patch handle followed by its label handles.
    global cube_h;
    cube_h = cell(4,4,4);
    global cube_value;
    cube_value = zeros(4,4,4);
    global arrow_h;
    arrow_h = cell(1,6);
    global score;
    score = 0;
    global processing;
    processing = true;
    global paused;
    paused = false;
end

function menuToGame(~,~)
    quitMenu([],[]);
    startGame();
end

function gameToMenu(~,~)
    quitGame([],[]);
    startMenu();
end

function initializeGame()
    global figure_h;
    figure_h = figure('MenuBar', 'none', 'ToolBar', 'none', 'Name', ...
        '2048 in 3D by Baran Usluel', 'NumberTitle', 'off', ...
        'units', 'normalized', 'outerposition', [0.2 0.1 0.6 0.8]);
    pnl = uipanel('Position', [0, 0.8, 1, 0.2], 'BorderType', 'none', ...
        'BackgroundColor', getColor('pnl_bg'));
    uicontrol(pnl, 'Style', 'text', 'Units', 'normalized', 'Position', [0.05 0.2 1 0.8], ...
        'String', '2048', 'FontUnits', 'normalized', 'FontSize', 0.9, ...
        'FontWeight', 'bold', 'ForegroundColor', getColor('title'), ...
        'BackgroundColor', getColor('pnl_bg'), 'HorizontalAlignment', 'left');
    global score_h;
    score_h = uicontrol(pnl, 'Style', 'text', 'Units', 'normalized', 'Position', [0.35 0.2 1 0.5], ...
        'String', 'Score: 0', 'FontUnits', 'normalized', 'FontSize', 0.6, ...
        'FontWeight', 'bold', 'ForegroundColor', getColor('title'), ...
        'BackgroundColor', getColor('pnl_bg'), 'HorizontalAlignment', 'left');
    uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Quit',...
        'Units', 'normalized', 'Position', [0.8 0.2 0.15 0.6],  ...
        'Callback', @gameToMenu, 'BackgroundColor', getColor('pnl_bg'), ...
        'ForegroundColor', getColor('title'), 'FontUnits', 'normalized', 'FontSize', 0.4, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    uicontrol(pnl, 'Style', 'pushbutton', 'String', 'Pause',...
        'Units', 'normalized', 'Position', [0.6 0.2 0.15 0.6],  ...
        'Callback', @pauseGame, 'BackgroundColor', getColor('pnl_bg'), ...
        'ForegroundColor', getColor('title'), 'FontUnits', 'normalized', 'FontSize', 0.4, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    global loading_h;
    loading_h = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.05 0.05 0.2 0.05], ...
        'String', 'Loading...', 'FontUnits', 'normalized', 'FontSize', 0.7, ...
        'FontWeight', 'bold', 'ForegroundColor', getColor('title'), ...
        'BackgroundColor', getColor('bg'), 'HorizontalAlignment', 'left');
    global pause_h;
    pause_h = uipanel('Position', [0.2, 0.1, 0.6, 0.6], 'BorderType', 'none', ...
        'BackgroundColor', getColor('pnl_bg'), 'BorderType', 'beveledin', 'Visible', 'off');
    uicontrol(pause_h, 'Style', 'pushbutton', 'String', 'Resume',...
        'Units', 'normalized', 'Position', [0.35 0.2 0.3 0.2],  ...
        'Callback', @resumeGame, 'BackgroundColor', getColor('pnl_bg'), ...
        'ForegroundColor', getColor('title'), 'FontUnits', 'normalized', 'FontSize', 0.4, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    uicontrol(pause_h, 'Style', 'text', 'Units', 'normalized', 'Position', [0 0.6 1 0.2], ...
        'String', 'Game Paused', 'FontUnits', 'normalized', 'FontSize', 0.7, ...
        'FontWeight', 'bold', 'ForegroundColor', getColor('title'), ...
        'BackgroundColor', getColor('pnl_bg'), 'HorizontalAlignment', 'center');
    sp_h = subplot(2,1,2);
    sp_h.Position = [0 0.1 1 0.6];
    set(figure_h, 'color', getColor('bg'));
    hold on;
    view(3);
    rot_h = rotate3d;
    rot_h.Enable = 'on';
    xlim([-1000, 1000]);
    ylim([-1000, 1000]);
    zlim([-1000, 1000]);
    axis_h = gca;
    axis_h.Clipping = 'off';
    axis vis3d;
    axis off;
    lightangle(0,30)
    lighting flat;
    view(0,90);
    drawnow;
    
    % The following 'hack' lets you set a key press listener even though
    % the rotate3d mode is activated, by overwriting the listener manually
    % http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
    manager_h = uigetmodemanager(figure_h);
    try
        set(manager_h.WindowListenerHandles, 'Enable', 'off'); % Before R2014B
    catch
        [manager_h.WindowListenerHandles.Enabled] = deal(false); % After R2014B
    end
    set(figure_h, 'WindowKeyPressFcn', []);
    set(figure_h, 'KeyPressFcn', @keyPressed);
end

function initializeMenu()
    global menu_figure_h;
    menu_figure_h = figure('MenuBar', 'none', 'ToolBar', 'none', 'Name', ...
        '2048 in 3D by Baran Usluel', 'NumberTitle', 'off', ...
        'units', 'normalized', 'outerposition', [0.2 0.1 0.6 0.8]);
    pnl_top = uipanel('Position', [0, 0.8, 1, 0.2], 'BorderType', 'none', ...
        'BackgroundColor', getColor('pnl_bg'));
    uicontrol(pnl_top, 'Style', 'text', 'Units', 'normalized', 'Position', [0 0.2 1 0.8], ...
        'String', '2048', 'FontUnits', 'normalized', 'FontSize', 0.9, ...
        'FontWeight', 'bold', 'ForegroundColor', getColor('title'), ...
        'BackgroundColor', getColor('pnl_bg'), 'HorizontalAlignment', 'center');
    pnl_bottom = uipanel('Position', [0, 0, 1, 0.2], 'BorderType', 'none', ...
        'BackgroundColor', getColor('pnl_bg'));
    uicontrol(pnl_bottom, 'Style', 'pushbutton', 'String', 'Quit',...
        'Units', 'normalized', 'Position', [0.65 0.2 0.15 0.6],  ...
        'Callback', @quitMenu, 'BackgroundColor', getColor('pnl_bg')-10, ...
        'ForegroundColor', getColor('title'), 'FontUnits', 'normalized', 'FontSize', 0.4, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    uicontrol(pnl_bottom, 'Style', 'pushbutton', 'String', 'Play',...
        'Units', 'normalized', 'Position', [0.2 0.2 0.3 0.6],  ...
        'Callback', @menuToGame, 'BackgroundColor', getColor(8), ...
        'ForegroundColor', getColor('title'), 'FontUnits', 'normalized', 'FontSize', 0.4, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    global loading_h;
    loading_h = uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.05 0.2 0.2 0.05], ...
        'String', 'Loading...', 'FontUnits', 'normalized', 'FontSize', 0.7, ...
        'FontWeight', 'bold', 'ForegroundColor', getColor('title'), ...
        'BackgroundColor', getColor('bg'), 'HorizontalAlignment', 'left');
    sp_h = subplot(2,1,2);
    sp_h.Position = [0 0.2 1 0.6];
    set(menu_figure_h, 'color', getColor('bg'));
    hold on;
    view(3);
    xlim([-1000, 1000]);
    ylim([-1000, 1000]);
    zlim([-1000, 1000]);
    axis_h = gca;
    axis_h.Clipping = 'off';
    axis vis3d;
    axis off;
    lightangle(0,30)
    lighting flat;
    view(0,40);
    drawnow;
end

function importImages()
    global label_ims;
    label_ims = cell(1, 11);
    for n = 1:11
        [im, ~, alpha] = imread(['images/' num2str(2^n) '.png']);
        label_ims{n} = {fliplr(im), fliplr(alpha)};
    end
end

function animateCameraGame()
    global figure_h;
    pause(0.5);
    az = linspace(0, -35, 150);
    el = linspace(90, 30, 150);
    for n = 1:length(az)
        if ~ishandle(figure_h)
            break;
        end
        view(az(n), el(n));
        pause(0.01);
    end
end

function animateCameraDemo()
    global menu_figure_h;
    az = linspace(0, 359, 360);
    el = 40 + 15*sind(az);
    n = 1;
    while ishandle(menu_figure_h)
        view(az(mod(n-1,360)+1), el(mod(n-1,360)+1));
        pause(0.02);
        n = n+1;
    end
end

function isLoading(isIt)
    global processing;
    processing = isIt;
    global loading_h;
    set(loading_h, 'visible', strrep(char([isIt*'on', ~isIt*'off']), char(0), ''));
    drawnow;
end

function gameOverWin()
    global loading_h;
    set(loading_h, 'visible', 'on');
    set(loading_h, 'String', 'You Won!');
    set(loading_h, 'Position', [0.05 0.05 0.4 0.1]);
    drawnow;
    %pause(5);
    %quitGame([],[]);
end

function gameOverLose()
    global loading_h;
    set(loading_h, 'visible', 'on');
    set(loading_h, 'String', 'You Lost!');
    set(loading_h, 'Position', [0.05 0.05 0.4 0.1]);
    drawnow;
    %pause(5);
    %quitGame([],[]);
end

function quitGame(~,~)
    global figure_h;
    close(figure_h);
end

function quitMenu(~,~)
    global menu_figure_h;
    close(menu_figure_h);
end

function pauseGame(~,~)
    global pause_h;
    global paused;
    paused = true;
    showm(pause_h);
end

function resumeGame(~,~)
    global pause_h;
    global paused;
    paused = false;
    hidem(pause_h);
end

function togglePause()
    global paused
    if paused
        resumeGame([],[]);
    else
        pauseGame([],[]);
    end
end

function keyPressed(~, evt)
    global cube_value;
    global score;
    global processing;
    if processing
        return;
    end
    new_value = cube_value;
    permuted = false;
    switch upper(evt.Key)
        case 'W'
            dir = 'right';
            dir_n = 4;
        case 'S'
            dir = 'left';
            dir_n = 2;
        case 'A'
            dir = 'up';
            dir_n = 1;
        case 'D'
            dir = 'down';
            dir_n = 3;
        case 'Q'
            dir = 'down';
            dir_n = 5;
            permuted = true;
            new_value = permute(new_value, [3 2 1]);
        case 'E'
            dir = 'up';
            dir_n = 6;
            permuted = true;
            new_value = permute(new_value, [3 2 1]);
        case 'ESCAPE'
            togglePause();
            return;
        otherwise
            return;
    end
    global paused;
    if paused
        return;
    end
    isLoading(true);
    highlightArrow(dir_n, 'arrow_on');
    drawnow;
    for z = 1:4
        [layer, score] = boardSlider(new_value(:,:,z), dir, score);
        new_value(:,:,z) = layer;
    end
    if any(any(any(new_value ~= cube_value)))
        potential = find(any(any(new_value == 0)));
        for z = potential(round(length(potential)*rand(1,1)+0.5))
            new_value(:,:,z) = tileGenerator(new_value(:,:,z));
        end
        if permuted
            new_value = permute(new_value, [3 2 1]);
        end
        updateCubes(new_value);
        updateScore();
    end
    highlightArrow(dir_n, 'arrow');
    drawnow;
    isLoading(false);
    if any(any(any(new_value == 2048)))
        gameOverWin();
    elseif ~any(any(any(new_value == 0)))
        checkLose();
    end
end

function checkLose()
    global cube_value;
    for i = 1:3
        if any(any(any(diff(cube_value, 1, i) == 0)))
            return;
        end
    end
    gameOverLose();
end

function highlightArrow(dir, clr)
    global arrow_h;
    set(arrow_h{dir}, 'FaceColor', getColor(clr));
end

function updateScore()
    global score;
    global score_h;
    set(score_h, 'String', ['Score: ', num2str(score)]);
end

function generateCubesGame()
    tmp_values = zeros(4,4,4);
    for z = round(4*rand(1,2)+0.5)
        tmp_values(:,:,z) = tileGenerator(tmp_values(:,:,z));
    end
    for x = 1:4
        for y = 1:4
            for z = 1:4
                drawCube(x, y, z, tmp_values(x, y, z));
            end
        end
    end
end

function generateCubesTesting()
    for x = 1:4
        for y = 1:4
            for z = 1:4
                if mod(x+y+z, 2) == 0
                    drawCube(x,y,z,2);
                %elseif x == 1 && y == 1 && z == 1
                %    drawCube(x,y,z,2);
                else
                    drawCube(x,y,z,4);
                end
            end
        end
    end
end

function generateCubesDemo()
    for x = 1:4
        for y = 1:4
            for z = 1:4
                if x + y - z > 2
                    drawCube(x, y, z, 2^(randi(11, 1)));
                else
                    drawCube(x, y, z, 0);
                end
            end
        end
    end
end

function updateCubes(new_value)
    global cube_value;
    for x = 1:4
        for y = 1:4
            for z = 1:4
                if cube_value(x, y, z) ~= new_value(x, y, z)
                    deleteCube(x, y, z);
                    val = new_value(x, y, z);
                    drawCube(x, y, z, val);
                end
            end
        end
    end
end

function deleteCube(x, y, z)
    global cube_h;
    handles = cube_h{x, y, z};
    for n = 1:length(handles)
        delete(handles{n});
    end
end

function drawCube(x_i, y_i, z_i, val)
    global cube_h;
    global cube_value;
    pos = ([x_i, y_i, z_i] * 2 - 5) * 256;
    [x, y, z] = deal(pos(1), pos(2), pos(3));
    vert = 0.7 .* 256 .* [1 1 -1; -1 1 -1; -1 1 1; 1 1 1; -1 -1 1; 1 -1 1; 1 -1 -1; -1 -1 -1];
    fac = [1 2 3 4; 4 3 5 6; 6 7 8 5; 1 2 8 7; 6 7 1 4; 2 3 5 8];
    vert = vert + [x y z];
    if val == 0
        ph = patch('Faces', fac, 'Vertices', vert, ...
            'FaceAlpha', 0, 'EdgeColor', [0 0 0], ...
            'EdgeAlpha', 0.05, 'LineWidth', 1);
    else
        ph = patch('Faces', fac, 'Vertices', vert, ...
            'FaceColor', getColor(val), 'EdgeColor', getColor(val)-20, ...
            'EdgeAlpha', 0, 'LineWidth', 1, ...
            'AmbientStrength', 1, 'DiffuseStrength', 0.2, ...
            'SpecularStrength',0.5, 'SpecularColorReflectance', 0);
    end
    %drawnow;
    cube_value(x_i, y_i, z_i) = val;
    cube_h{x_i, y_i, z_i} = {ph};
    drawLabels(x_i, y_i, z_i, val);
end

function drawArrows()
    for n = 1:6
        midpoint = [-8 0 0];
        switch n
            case 1
                tform = eye(4);
            case 2
                tform = makehgtform('zrotate', pi/2);
            case 3
                tform = makehgtform('zrotate', pi);
            case 4
                tform = makehgtform('zrotate', -pi/2);
            case 5
                tform = makehgtform('yrotate', pi/2);
            case 6
                tform = makehgtform('yrotate', -pi/2);
        end
        tform = tform(1:3, 1:3);
        drawArrow(256 * tform * midpoint', tform, n);
    end
end

function drawArrow(midpoint, tform, n)
    global arrow_h;
    vert = 0.5 .* 256 .* ...
        [1 1 -1; -1 1 -1; -1 1 1; 1 1 1; -1 -1 1; 1 -1 1; 1 -1 -1; -1 -1 -1; 1 2 -2; 1 2 2; 1 -2 2; 1 -2 -2; 2 0 0;];
    vert = vert * -[2 0 0; 0 1 0; 0 0 1];
    vert = (tform * vert')';
    fac = [1 2 3 4; 4 3 5 6; 6 7 8 5; 1 2 8 7; 6 7 1 4; 2 3 5 8; 9 10 13 13; 9 12 13 13; 10 11 13 13; 11 12 13 13];
    vert = vert + [midpoint(1) midpoint(2) midpoint(3)];
    ph = patch('Faces', fac, 'Vertices', vert, ...
        'FaceColor', getColor('arrow'), 'EdgeColor', getColor('arrow'), ...
        'FaceAlpha', 0.15, 'EdgeAlpha', 0.1, 'LineWidth', 1, ...
        'AmbientStrength', 1, 'DiffuseStrength', 0.2, ...
        'SpecularStrength',0.5, 'SpecularColorReflectance', 0);
    arrow_h{n} = ph;
    letters = 'ASDWQE';
    text(midpoint(1), midpoint(2), midpoint(3), letters(n), 'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold', 'FontSize', 16);
    %drawnow;
end

function drawLabels(x_i, y_i, z_i, val)
    global cube_h;
    global label_ims;
    pos = ([x_i, y_i, z_i] * 2 - 5) * 256;
    [x, y, z] = deal(pos(1), pos(2), pos(3));
    if val > 2048 || val < 2
        return;
    end
    label = label_ims{log2(val)};
    for side_n = 1:6
        switch side_n
            case 1
                transf = hgtransform('Matrix',makehgtform('zrotate', pi, 'translate', [0 0 z+(256*0.7)+1]));
                im_h = image('XData', -x-128, 'YData', -y-128, 'CData', label{1}, 'Parent', transf);
                set(im_h, 'AlphaData', label{2});
            case 2
                transf1 = hgtransform('Matrix',makehgtform('translate', [0 0 y+(256*0.7)+1]));
                transf2 = hgtransform('Matrix',makehgtform('xrotate', -pi/2, 'yrotate', 0));
                transf1.Parent = transf2;
                im_h = image('XData', x-128, 'YData', -z-128, 'CData', label{1}, 'Parent', transf1);
                set(im_h, 'AlphaData', label{2});
            case 3
                transf1 = hgtransform('Matrix',makehgtform('translate', [0 0 -y+(256*0.7)+1]));
                transf2 = hgtransform('Matrix',makehgtform('xrotate', -pi/2, 'yrotate', 0));
                transf3 = hgtransform('Matrix',makehgtform('zrotate', pi));
                transf1.Parent = transf2;
                transf2.Parent = transf3;
                im_h = image('XData', -x-128, 'YData', -z-128, 'CData', label{1}, 'Parent', transf1);
                set(im_h, 'AlphaData', label{2});
            case 4
                transf1 = hgtransform('Matrix',makehgtform('translate', [0 0 x+(256*0.7)+1]));
                transf2 = hgtransform('Matrix',makehgtform('xrotate', 0, 'yrotate', pi/2));
                transf3 = hgtransform('Matrix',makehgtform('zrotate', -pi/2));
                transf1.Parent = transf3;
                transf3.Parent = transf2;
                im_h = image('XData', -y-128, 'YData', -z-128, 'CData', label{1}, 'Parent', transf1);
                set(im_h, 'AlphaData', label{2});
            case 5
                transf1 = hgtransform('Matrix',makehgtform('translate', [0 0 -x+(256*0.7)+1]));
                transf2 = hgtransform('Matrix',makehgtform('xrotate', 0, 'yrotate', pi/2));
                transf3 = hgtransform('Matrix',makehgtform('zrotate', -pi/2));
                transf4 = hgtransform('Matrix',makehgtform('zrotate', pi));
                transf1.Parent = transf3;
                transf3.Parent = transf2;
                transf2.Parent = transf4;
                im_h = image('XData', y-128, 'YData', -z-128, 'CData', label{1}, 'Parent', transf1);
                set(im_h, 'AlphaData', label{2});
            case 6
                transf1 = hgtransform('Matrix',makehgtform('translate', [0 0 z-(256*0.7)-1]));
                transf2 = hgtransform('Matrix',makehgtform('yrotate', pi));
                transf2.Parent = transf1;
                im_h = image('XData', -x-128, 'YData', y-128, 'CData', label{1}, 'Parent', transf2);
                set(im_h, 'AlphaData', label{2});
        end
        cube_h{x_i, y_i, z_i} = [cube_h{x_i, y_i, z_i} {im_h}];
    end
end

%{
function hideLabels()
    global labels_h;
    for label_h = labels_h
        hidem(label_h);
    end
end

function showLabels()
    global labels_h;
    for label_h = labels_h
        showm(label_h);
    end
end

function preRotateEvent(obj, evt)
    hideLabels();
end

function postRotateEvent(obj, evt)
    showLabels();
end
%}

function clr = getColor(id)
    switch id
        case 'bg'
            clr = hexToRGB('#cdc1b4');
        case 'border'
            clr = hexToRGB('#bbada0');
        case 'title'
            clr = hexToRGB('#786c66');
        case 'pnl_bg'
            clr = hexToRGB('#fbf8f1');
        case 'arrow'
            clr = hexToRGB('#fbf8f1');
        case 'arrow_on'
            clr = hexToRGB('#f7f977');
        case 2
            clr = hexToRGB('#ecdfc7');
        case 4
            clr = hexToRGB('#efcbac');
        case 8
            clr = hexToRGB('#f2b179');
        case 16
            clr = hexToRGB('#f59563');
        case 32
            clr = hexToRGB('#f67c5f');
        case 64
            clr = hexToRGB('#f95c30');
        case 128
            clr = hexToRGB('#edce68');
        case 256
            clr = hexToRGB('#eecd57');
        case 512
            clr = hexToRGB('#eec943');
        case 1024
            clr = hexToRGB('#eec62c');
        case 2048
            clr = hexToRGB('#eec308');
    end
end

function rgb = hexToRGB(hex)
    rgb = uint8([hex2dec(hex(2:3)), hex2dec(hex(4:5)), hex2dec(hex(6:7))]);
end