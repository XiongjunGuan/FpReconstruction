function MINU = LoadMntVF12(fname)
data = textread(fname);
nums = data(3:5,1);

MINU_start = 5 + nums(1)+nums(2);
MINU = zeros(nums(3),4);
for i = 1:nums(3)
    MINU(i,:) = data(MINU_start+i,1:4);
    MINU(i,3) = 360 - MINU(i,3);
end
end