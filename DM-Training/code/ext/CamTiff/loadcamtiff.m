function [ out ] = loadcamtiff(filename, varargin)
%LOADCAMTIFF Load a camtiff file
%
%

  %% Parse the input options
  options = parseinputs(filename, varargin{:});

  %% Set states
  mode = setmode(options);

  %% Allocate basic data structure
  image_stack = struct;
  json = struct;

  %% Get the info structs on each of the files.
  info = imfinfo(filename);
  xmp_exists = isfield(info, 'XMP');
  camtiff = false;

  %% Find the width and height of the images.
  height = info(1).Height;
  width  = info(1).Width;

  %% Find the number of pages in each of the files.
  pages = numel(info);

  %% Set top metadata package
  if mode.binfo
    image_stack.binfo = info(1);
  end

  if mode.einfo && xmp_exists
    einfo_start = loadjson(info(1).XMP);

    if isfield(einfo_start, 'CamTIFF_Version')
      camtiff = true;

      if mode.stack
        json = loadjson([info.XMP]);
        image_stack.einfo = json{1};
      else
        json = loadjson(info(1).XMP);
        image_stack.einfo = json;
      end % if mode.stack

    end % if camtiff
  end % if mode.einfo

  %% Allocate space for average image
  if mode.average
    image = zeros(height, width);
  end

  %% TODO: Test if this allocates space per page.
  if mode.stack
    % Does not appear to improve performance.
    %[ image_stack.stack(1:pages).image ] = deal(zeros(height, width));

    % FIXME: set binfo for every page in stack.
    %if mode.binfo
      %[ image_stack.stack(1:pages).binfo ] = {info};
    %end

    if mode.einfo && camtiff
      [ image_stack.stack(1:pages).einfo ] = json{:};
    end
  end

  %% Go through the pages
  for k = 1:pages
    A = double(imread(filename, k, 'Info', info));
    if mode.average
      image = image + (A./pages);
    end

    if mode.stack
      image_stack.stack(k).image = A;
      image_stack.stack(k).binfo = info(k);
    end % if mode.stack
  end % end for

  %% Assign average image
  if mode.average
    image_stack.image = image;
  end

  %% Output
  if ~mode.any_info && (mode.average && ~mode.stack)
      out = image_stack.image;
  else
      out = image_stack;
  end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : setmode
%
function [ mode ] = setmode(options)
  if strcmp(options.mode, 'stack')
    mode.stack = true;
    mode.average = false;
  elseif strcmp(options.mode, 'average')
    mode.stack = false;
    mode.average = true;
  elseif strcmp(options.mode, 'both')
    mode.stack = true;
    mode.average = true;
  end

  if strcmp(options.info, 'none')
    mode.binfo = false;
    mode.einfo = false;
  elseif strcmp(options.info, 'basic')
    mode.binfo = true;
    mode.einfo = false;
  elseif strcmp(options.info, 'extended')
    mode.binfo = false;
    mode.einfo = true;
  elseif strcmp(options.info, 'all')
    mode.binfo = true;
    mode.einfo = true;
  end

  mode.any_info = mode.binfo || mode.einfo;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : parseinputs
%
function [ results ] = parseinputs(filename, varargin)
  p = inputParser;

  default_mode = 'average';
  % TODO: Add modes sum, first, slice?
  valid_modes = { 'average', 'stack', 'both' };
  checkMode = @(x) any(validatestring(x,valid_modes));

  default_info = 'none';
  valid_info = { 'none', 'basic', 'extended' , 'all' };
  checkInfo = @(x) any(validatestring(x,valid_info));

  addRequired(p,'filename',@ischar);
  addOptional(p,'mode',default_mode, checkMode);
  addOptional(p,'info',default_info, checkInfo);

  parse(p, filename, varargin{:})
  results = p.Results;
end
