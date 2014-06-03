function [comx,comy] = gpegetcenterofmass_dt(dirarg,startno,endno,speed,nx,ny)
for i=startno:endno
    [gridx,gridy,dens,phase,potential] = gpeget2dWF(dirarg,i,speed,nx,ny);
    fprintf('read %d\n',i);
    [comx(i-startno+1),comy(i-startno+1)] = gpegetcenterofmass(dens,gridx,gridy);
end

end
