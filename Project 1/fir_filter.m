% Specifications
fs = 1; % Normalized frequency
delta_w = 0.03*pi; % Transition width
A = 80; % Stopband attenuation

% Kaiser window parameters
if A > 50
    beta = 0.1102 * (A - 8.7);
elseif A >= 21
    beta = 0.5842 * (A - 21)^0.4 + 0.07886 * (A - 21);
else
    beta = 0;
end

N = ceil((A - 8) / (2.285 * delta_w)) + 1; % Filter length

% Increase N to next odd number if necessary to ensure 100 taps
N = max(N, 101);
N = 100;

display(N);

% Desired cutoff frequency (midway in the transition band)
fc = (0.2*pi + 0.23*pi) / (2*pi);

% Design filter
hd = fir1(N-1, 2*fc, kaiser(N, beta), 'noscale');

% Frequency response
[H,f] = freqz(hd,1,1024,fs);

% Plot
figure;
plot(f*fs,20*log10(abs(H)));
grid on;
xlabel('Frequency (normalized)');
ylabel('Magnitude (dB)');
title('100-Tap Low-Pass FIR Filter Response');

% Plot specifications for reference
hold on;
line([0 0.2],[0 0], 'Color', 'red', 'LineStyle', '--');
line([0.23 0.5],[-80 -80], 'Color', 'red', 'LineStyle', '--');


% Define fixed-point properties
wordLength = 16; % Total number of bits for fixed-point representation
fracLength = 15; % Number of fractional bits in the fixed-point representation

% Convert the filter coefficients to fixed-point using the fi function
hdFixed = fi(hd, 1, wordLength, fracLength); % 1 indicates signed number

% Assuming hdFixed is an array of fi objects
for i = 1:5
    coeff = hdFixed(i); % Access each fi object individually
    disp(bin(coeff)); % Use the bin function to display the binary representation
end

% Optionally, analyze the quantization effect on the filter response
[H_quantized,f_quantized] = freqz(double(hdFixed), 1, 1024, fs);
figure;
plot(f_quantized*fs, 20*log10(abs(H_quantized)));
grid on;
xlabel('Frequency (normalized)');
ylabel('Magnitude (dB)');
title('Quantized 100-Tap Low-Pass FIR Filter Response');

% Add the specification lines for visual comparison
hold on;
line([0 0.2],[0 0], 'Color', 'red', 'LineStyle', '--');
line([0.23 0.5],[-80 -80], 'Color', 'red', 'LineStyle', '--');



% Assuming hdFixed is correctly defined as a fi object array
numCoeffs = length(hdFixed); % Number of coefficients

display(numCoeffs);

% Begin the Verilog parameter array definition
coeffStr = "parameter signed [31:0] h[" + (numCoeffs-1) + ":0] = '{";

% Loop through the coefficients and append each to the string
for i = 1:numCoeffs
    % Directly access each coefficient's integer value
    intVal = int(hdFixed(i));
    coeffStr = coeffStr + sprintf("32'sd%d", intVal);
    if i < numCoeffs
        coeffStr = coeffStr + ", ";
    else
        coeffStr = coeffStr + "};";
    end
end

% Display the formatted coefficient string
disp(coeffStr);




