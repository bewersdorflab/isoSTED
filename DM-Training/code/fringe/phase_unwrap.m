function [Phiu] = phase_unwrap(Phiw, db)

apmask = fourier_apmask(Phiw);
nstack = size(Phiw, 3);
Phiu = -inf*ones(size(Phiw));
path = [fileparts(mfilename('fullpath')), filesep(), 'unwrap.py'];

for i=1:nstack
    phiw = Phiw(:, :, i);
    phiw(~apmask) = 0;
    phiw(phiw == pi) = -pi;

    tmpid = tempname();
    tmpin = [tmpid, '.mat'];
    save(tmpin, 'phiw', 'apmask');
    clear phiw;

    if unix(sprintf('python "%s" --quiet "%s"', path, tmpin)) ~= 0
        delete(tmpin);
        error('python unwrap.py failed');
    end
    
    tmpout = [tmpid, '_unwrapped.mat'];
    load(tmpout);
    Phiu(:, :, i) = phiu;
    
    delete(tmpin, tmpout);
    
    if exist('db', 'var') && db > 0
        sfigure(db);
        clf();
        subplot(1, 2, 1);
        h = imagesc(Phiw(:, :, i));
        set(h, 'AlphaData', apmask);
        axis equal;
        axis off;
        
        subplot(1, 2, 2);
        h = imagesc(Phiu(:, :, i));
        set(h, 'AlphaData', apmask);
        axis equal;
        axis off;

        pause(.05);
    end
    
    assert(all(isfinite(Phiu(:))));
    
end
