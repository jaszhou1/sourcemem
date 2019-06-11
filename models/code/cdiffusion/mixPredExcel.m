Fit_Data = Treatment_Simple;

Recognised = Fit_Data(:,1);
Unrecognised = Fit_Data(:,2);

participants = [1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,18,19,20];

for i = participants
VPpreds(i,:)=VP_LL_Preds_Recognised{i,4};
Mixpreds(i,:)=MX_LL_Preds_Recognised{i,4};
end

for i = participants
    filename = ['VP_Recog',num2str(i),'.png'];
    fitplot(Recognised {i}, VP_LL_Preds_Recognised{i,3});
    saveas(gcf,filename);
%     
%     filename = ['1VP_Unrecog',num2str(i),'.png'];
%     fitplot(Unrecognised {i}, VP_LL_Preds_Unrecognised{i,3});
%     saveas(gcf,filename);
    
    filename = ['MX_Recog',num2str(i),'.png'];
    fitplot(Recognised {i}, MX_LL_Preds_Recognised{i,3});
    saveas(gcf,filename);
    
%     filename = ['2MX_Unrecog',num2str(i),'.png'];
%     fitplot(Unrecognised {i}, MX_LL_Preds_Unrecognised{i,3});
%     saveas(gcf,filename);
end    