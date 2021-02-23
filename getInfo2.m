function [userrss, usert, userber, usermag, userpha] = getInfo2(user)

userrss = table2array(user(:,end));
usert = table2array(user(:,1));
userber = table2array(user(:,2));
usermag = table2array(user(:,3:2:65));
userpha = table2array(user(:,4:2:66));
