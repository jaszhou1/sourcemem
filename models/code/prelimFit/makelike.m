function like = makelike(Data, Datb)
% =========================================================================
% Return two pairs of ntrials x 2 matrices giving theta (error) and RT
% for each response. 
%      like = makelike(Data, Datb)
% =========================================================================
lika = makeliki(Data);
likb = makeliki(Datb);
like{1} = lika;
like{2} = likb;
end


function liki = makeliki(Datai)
% =========================================================================
% Make a fittable RT structure from an individual subject's source memory
% data.
%      liki = makeliki(Datai)
% =========================================================================
sz = size(Datai);
if ~(all(size(Datai) == [280,6]) || all(size(Datai) == [280,6]))
    disp('Wrong size data structure')
    return
end
ntrials = sz(1); % Number of trials

rtx = 4;   % Column indices
errx = 6;
[~, Ix] = sort(abs(Datai(:,errx)));
Theta = Datai(Ix, errx);
RT = Datai(Ix,rtx);
liki = [Theta,RT];
end 
