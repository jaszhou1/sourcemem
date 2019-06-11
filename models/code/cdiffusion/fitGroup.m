%Group Fits
load('groupFits.mat')
load('groupData2.mat')

filename = 'groupVP_Recog.png';
    fitplot(groupRecognised, VP_LL_Preds_Recognised{1,3});
    saveas(gcf,filename);
%     
%     filename = ['1VP_Unrecog',num2str(i),'.png'];
%     fitplot(Unrecognised {i}, VP_LL_Preds_Unrecognised{i,3});
%     saveas(gcf,filename);
    
filename = 'groupMX_Recog.png';
    fitplot(groupRecognised, MX_LL_Preds_Recognised{1,3});
    saveas(gcf,filename);
    
%     filename = ['2MX_Unrecog',num2str(i),'.png'];
%     fitplot(Unrecognised {i}, MX_LL_Preds_Unrecognised{i,3});
%     saveas(gcf,filename);