function SS = example8Spectra
%EXAMPLE8SPECTRA Example Bretschneider spectrum with varying HHm0s, Tps, 
%                Nbins, and range
    p = mfilename('fullpath');
    [filepath, ~, ~] = fileparts(p);
    dataPath = [filepath filesep '8spectra.mat'];
    example_data = load(dataPath);
    SS = example_data.SS;
end
