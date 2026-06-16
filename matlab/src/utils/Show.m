function Show(fig,I,name)
% Show an image with title
%
% Jianjiang Feng
% 2007-8

iptsetpref('ImshowBorder','tight');
figure(fig),clf
% subplot('Position',[0 0 1 1])
if isfloat(I)
    if max(I(:)>1)
        imshow(I,[])
    elseif min(I(:)<0)
        imshow(I,[])
    else
        imshow(I)
    end
else
    imshow(I)
end

if exist('name')
    set(fig,'name',name);
end

% truesize(fig)
