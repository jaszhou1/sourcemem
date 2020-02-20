function like = makelike_simple(Low, High, size1, size2)
% =========================================================================
% Return two pairs of ntrials x 2 matrices giving theta (error) and RT
% for each response. 
%      like = makelike(Data, Datb)
% =========================================================================
lik_low = makeliki(Low);
lik_high = makeliki(High);
like{1} = lik_low;
like{2} = lik_high;
end


function liki = makeliki(Datai)
% =========================================================================
% Make a fittable RT structure from an individual subject's source memory
% data.
%      liki = makeliki(Datai)
% =========================================================================
sz = size(Datai);
ntrials = sz(1); % Number of trials

rtx = 4;   % Column indices
errx = 6;
[~, Ix] = sort(abs(Datai(:,errx)));
Theta = Datai(Ix, errx);
RT = Datai(Ix,rtx);
liki = [Theta,RT];
end 
