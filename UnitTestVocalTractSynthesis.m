%% Unit Test Vocal Tract Synthesis
% Unit testing for the VocalTractSynthesis function
% Author: Michael Seaborg
% Date: 04/02/2024

%% Test error conditions
% The "Beach Boys" test
goodExcitation = zeros(500, 1);
badExcitation = zeros(500, 2);

goodACoeffs = zeros(200, 21);
badACoeffs = zeros(21, 200);

% Test bad 'hopLen' arguments
try
    y = VocalTractSynthesis(goodExcitation, goodACoeffs, -20);
catch ME
    fprintf('Error caught: %s, %s\n', ME.identifier, ME.message);
end

try 
    y = VocalTractSynthesis(goodExcitation, goodACoeffs, [1 4]);
catch ME
    fprintf('Error caught: %s, %s\n', ME.identifier, ME.message);
end

% Test bad 'aCoeffs' argument
try 
    y = VocalTractSynthesis(goodExcitation, badACoeffs, 100);
catch ME
    fprintf('Error caught: %s, %s\n', ME.identifier, ME.message);
end

% Test bad 'excitation' argument
try 
    y = VocalTractSynthesis(badExcitation, goodACoeffs, 100);
catch ME
    fprintf('Error caught: %s, %s\n', ME.identifier, ME.message);
end

%% Run VocalTractSynthesis on a test example
