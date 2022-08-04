function [erfOut, cAxis, probOut, pciOut] = getPsychoCurve(cc,pp,nn)
    %% compute CIs
    alpha = 0.1; % 90% CIs - optional argument? 
    [prob, pci] = binofit(round(pp.*nn), nn, alpha); % get CIs of the binomial distribution


    %% fit and plot a psychometric curve (asymmetric lapse rate)
    parstart = [mean(cc), 3, 0.05, 0.05 ]; %threshold, slope, gamma1, gamma2
    parmin = [min(cc) 0 0 0];
    parmax = [max(cc) 30 0.40 0.40];
    [ pars, L ] = mle_fit_psycho([cc; nn; pp],'erf_psycho_2gammas', parstart, parmin, parmax);
    cAxis = -max(cc):max(cc);

    probOut = prob;
    pciOut = pci;
    erfOut = erf_psycho_2gammas(pars, cAxis);

end
