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
        
        % Blur faces
        processedImg = img;
        for i = 1:size(bbox, 1)
            face = img(bbox(i, 2):bbox(i, 2)+bbox(i, 4), bbox(i, 1):bbox(i, 1)+bbox(i, 3), :);
            blurredFace = imgaussfilt(face, 30); % Adjust the standard deviation as needed
            processedImg(bbox(i, 2):bbox(i, 2)+bbox(i, 4), bbox(i, 1):bbox(i, 1)+bbox(i, 3), :) = blurredFace;

        end
        
        imshow(processedImg, 'Parent', processedAxes);
        title(processedAxes, 'Processed Image');
    end
end