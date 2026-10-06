function [enei, ext, sca] = get_spectra(p, pol, par)
    %%  initialization
    op = bemoptions( 'sim', 'ret', 'interp', 'curv' );
    
    %  table of dielectric functions
    epsb  = epsconst( 1.33 ^ 2 );
    epsau = epstable( 'custom_gold.dat' );
    epstab = { epsb, epsau };

    p = comparticle( epstab, p, [2 1], 1, op );

    %%  plane wave excitation
    exc = planewave( pol, [ 0, 0, 1 ], op );
    %  light wavelength in vacuum
    enei = linspace( 400, 700, 100 );

    %%  BEM simulation
    bem = bemsolver( p, op );

    %  scattering spectrum
    sca = zeros( length( enei ), 1 );
    %  extinction cross section
    ext = zeros( length( enei ), 1 );

    %  main loop over different excitation wavelengths
    multiWaitbar( 'BEM solver', 0, 'Color', 'g', 'CanCancel', 'on' );
    parfor ien = 1 : length( enei )
        tic;
        sig = bem \ exc( p, enei( ien ) );
        sca( ien, : ) = exc.sca( sig );
        ext( ien, : ) = exc.ext( sig );
        fprintf('%d...\t%ds\n', enei(ien), toc);
        multiWaitbar( 'BEM solver', ien / numel( enei ) );
    end
    close waitbar
    multiWaitbar( 'CloseAll' );
end