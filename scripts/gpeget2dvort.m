function [xlocs,ylocs,pol] = gpeget2dvort(dens,ophase,gridx,gridy,potential)
    disp(['Grid spacing is ',num2str(gridx(2)-gridx(1)),'.']);

    gf = 1.0; %Gaussian filter width. Smooths out noise.
    disp(['Using gaussian filter of width ',num2str(gf),'.']);

    li = 2; %Line integral size. Set around the number of grid points in a vortex core radius
    disp(['Doing line integrals over ',num2str(li),' points.']);

    th = 2; %threshold value. This can be freely tweaked as a way to control "sensitivity".
    disp(['Using a threshold value of ',num2str(th),'.']);
    
    scale = 1.0;
    dens = imresize(dens,scale, 'nearest');
    ophase = imresize(ophase,scale, 'nearest');
    potential = imresize(potential,scale, 'nearest');
    gridx = imresize(gridx,scale, 'nearest');
    gridy = imresize(gridy,scale, 'nearest');
    %figure()
    %imagesc(ophase)
    xlocs=[];
    ylocs=[];
    pol=[];

    dims = size(dens);
    dspace=(gridx(2)-gridx(1));
    velx(dims(1),dims(2)) = 0;
    vely(dims(1),dims(2)) = 0;
    presort = 0.*dens;

    phase = ophase;
    for i = 2:dims(1)-1
    for j = 2:dims(2)-1
        temp1 = anglediff(phase(i+1,j),phase(i-1,j));
        velx(i,j) = real(temp1)/(2*dspace);
     end
    end

    for i = 2:dims(1)-1
    for j = 2:dims(2)-1
        temp1 = anglediff(phase(i,j+1),phase(i,j-1));
        vely(i,j) = real(temp1)/(2*dspace);
    end
    end
    
    %hd = fspecial('gaussian', size(presort), 7.5);
    %densg = imfilter(dens, hd);
    %g=figure();
    %imagesc(gridx,gridy,densg);
    %maxdens = max(densg(:));
    lineint = @LINEINTVF;
    xxx=dims(1);
    yyy=dims(2);
    parfor i = li:xxx-li
        for j = li:yyy-li
              presort(i,j)=lineint(velx,vely,i-li/2,i+li/2,j-li/2,j+li/2);
              if(potential(i,j) > 0.9)
                  presort(i,j) = 0;
              end
        end
    end
    h = fspecial('gaussian', size(presort), gf);
    presort = imfilter(presort, h);
    negareas = bwlabel(presort<-th);
    posareas = bwlabel(presort>th);

    for i = 1:max(max(posareas))
        [r,c] = find(posareas== i);
        if(length(r) > 1)
            xlocs = [xlocs,mean(gridx(c))];
            ylocs = [ylocs,mean(gridy(r))+dspace/2];
            pol = [pol,1];
        end
    end

    for i = 1:max(max(negareas))
        [r,c] = find(negareas== i);
        if(length(r) > 1)
            xlocs = [xlocs,mean(gridx(c))];
            ylocs = [ylocs,mean(gridy(r)+dspace/2)];
            pol = [pol,-1];
        end
    end
%      h=figure();
%     imagesc(gridx,gridy,presort);
%      imagesc(gridx,gridy,dens);
%      colormap(gray);
%      axis image;
%      axis xy;
%      hold on;
%      g = gscatter(xlocs,ylocs,pol,['b','r'],['^','o'],5,'off');
%             if(length(g)==1 && pol(1)==1)
%                 set(g(1), 'MarkerFaceColor', 'r')
%                 set(g(1),'Marker','o');
%                 set(g(1),'MarkerEdgeColor','none');
%             end
%             if(length(g)==1 && pol(1)==-1)
%                 set(g(1), 'MarkerFaceColor', 'b')
%                 set(g(1),'Marker','^');
%                 set(g(1),'MarkerEdgeColor','none');
%             end
%             if(length(g)>1)
%                 set(g(1),'MarkerEdgeColor','none');
%                 set(g(1), 'MarkerFaceColor', 'b')
%                 set(g(2),'MarkerEdgeColor','none');
%                 set(g(2), 'MarkerFaceColor', 'r')
%             end
%     xlabel('', 'FontSize',16);
%     ylabel('', 'FontSize',16);
%     ax = findobj(h,'type','axes','Tag','');
%     set(ax,'FontSize',16)
%     axis([170 405 -40 40])
%     axis normal

    function ret = LINEINTVF(fieldx,fieldy,x,ex,y,ey)
        l1 = trapz(fieldy(x,y:ey));
        l2 = trapz(fieldx(x:ex,y));
        l3 = trapz(fieldy(ex,y:ey));
        l4 = trapz(fieldx(x:ex,ey));
        ret = dspace*(-l2-l3+l4+l1);
    end

    function d = anglediff(th1, th2)
        d = atan2(sin(th1-th2), cos(th1-th2));
    end
end