function S = exampleSpectrum
%EXAMPLESPECTRUM Example Bretschneider spectrum with Hm0=8 and Tp=10
    p = mfilename('fullpath');
    [filepath, ~, ~] = fileparts(p);
    dataPath = fullfile(filepath, 'spectrum.mat');
    example_data = load(dataPath);
    S = example_data.S;
end
