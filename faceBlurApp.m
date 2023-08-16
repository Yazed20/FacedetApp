function faceBlurGUI
    % Create a GUI window
    fig = figure('Name', 'Face Blur GUI', 'Position', [100, 100, 800, 400]);

    % Create buttons
    openButton = uicontrol('Style', 'pushbutton', 'String', 'Open Image',...
        'Position', [50, 350, 100, 30], 'Callback', @openButtonCallback);
    processButton = uicontrol('Style', 'pushbutton', 'String', 'Process Image',...
        'Position', [200, 350, 100, 30], 'Callback', @processButtonCallback);

    % Create axes for displaying images
    originalAxes = axes('Parent', fig, 'Position', [0.05, 0.1, 0.4, 0.7]);
    processedAxes = axes('Parent', fig, 'Position', [0.55, 0.1, 0.4, 0.7]);

    % Initialize variables
    img = [];
    processedImg = [];

    function openButtonCallback(~, ~)
        [filename, path] = uigetfile({'.jpg;.jpeg;*.png', 'Image Files (*.jpg, *.jpeg, *.png)'});
        if filename
            img = imread(fullfile(path, filename));
            imshow(img, 'Parent', originalAxes);
            title(originalAxes, 'Original Image');
            cla(processedAxes);
            processedImg = [];
        end
    end

    function processButtonCallback(~, ~)
        if isempty(img)
            return;
        end
        
        % Face detection
        faceDetector = vision.CascadeObjectDetector();
        bbox = step(faceDetector, img);
        
        % Blur faces with smaller area
        processedImg = img;
        for i = 1:size(bbox, 1)
            % Expand the face region slightly for blurring
            expansionFactor = 0.2; % You can adjust this value as needed
            expandedRegion = round(bbox(i, :) + [-expansionFactor*bbox(i, 3), -expansionFactor*bbox(i, 4), expansionFactor*bbox(i, 3)*2, expansionFactor*bbox(i, 4)*2]);
            
            % Ensure the expanded region is within image boundaries
            expandedRegion(1:2) = max(expandedRegion(1:2), [1, 1]);
            expandedRegion(3:4) = min(expandedRegion(3:4), [size(img, 2), size(img, 1)]);
            
            face = img(expandedRegion(2):expandedRegion(2)+expandedRegion(4), expandedRegion(1):expandedRegion(1)+expandedRegion(3), :);
            blurredFace = imgaussfilt(face, 5); % Adjust the standard deviation as needed
            processedImg(expandedRegion(2):expandedRegion(2)+expandedRegion(4), expandedRegion(1):expandedRegion(1)+expandedRegion(3), :) = blurredFace;
        end
        
        imshow(processedImg, 'Parent', processedAxes);
        title(processedAxes, 'Processed Image');
    end
end
