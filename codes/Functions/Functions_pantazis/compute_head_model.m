function sFiles = compute_head_model(sFiles,meg,eeg);
% function sFiles = compute_head_model(sFiles);
%
% meg = 1: none
% meg = 3: overlapping spheres
% meg = 4: OpenMEEG BEM
% eeg = 1: none
% eeg = 2: 3-shell sphere
% eeg = 3: % OpenMEEG BEM


% Process: Compute head model
sFiles = bst_process(...
    'CallProcess', 'process_headmodel', ...
    sFiles, [], ...
    'comment', '', ...
    'sourcespace', 1, ...
    'meg', meg, ... 
    'eeg', eeg, ... 
    'ecog', 1, ...  % <none>
    'seeg', 1, ...
    'openmeeg', struct(...
         'BemFiles', {{}}, ...
         'BemNames', {{'Scalp', 'Skull', 'Brain'}}, ...
         'BemCond', [1, 0.0125, 1], ...
         'BemSelect', [1, 1, 1], ...
         'isAdjoint', 0, ...
         'isAdaptative', 1, ...
         'isSplit', 0, ...
         'SplitLength', 4000));


     