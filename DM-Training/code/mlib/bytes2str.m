function str = bytes2str(NumBytes)
% BYTES2STR Private function to take integer bytes and convert it to
% scale-appropriate size.
% from: http://stackoverflow.com/questions/4845561/

scale = floor(log(NumBytes)/log(1024));
switch scale
    case 0
        str = [sprintf('%6.2f',NumBytes) '   B'];
    case 1
        str = [sprintf('%6.2f',NumBytes/(1024)) ' KiB'];
    case 2
        str = [sprintf('%6.2f',NumBytes/(1024^2)) ' MiB'];
    case 3
        str = [sprintf('%6.2f',NumBytes/(1024^3)) ' GiB'];
    case 4
        str = [sprintf('%6.2f',NumBytes/(1024^4)) ' TiB'];
    case 5
        str = [sprintf('%6.2f',NumBytes/(1024^5)) ' PiB'];
    case -inf
        str = '?????????   B';
    otherwise
        str = [sprintf('%6.2f',NumBytes/(1024^5)) ' PiB'];
end
