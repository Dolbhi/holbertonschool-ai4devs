function [enei, ext, sca] = get_spectra(p, pol)
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
    multiWaitbar( 'BEM solver', 0, 'Color', 'g' );
    progress( 0 );                              % reset counter
    dq = parallel.pool.DataQueue;
    afterEach( dq, @( ~ ) progress( numel( enei ) ) );
    parfor ien = 1 : length( enei )
        t = tic;
        sig = bem \ exc( p, enei( ien ) );
        sca( ien, : ) = exc.sca( sig );
        ext( ien, : ) = exc.ext( sig );
        fprintf( '%.1f nm...\t%.1fs\n', enei( ien ), toc( t ) );
        send( dq, ien );                        % tell the client
    end
    multiWaitbar( 'CloseAll' );
end
function progress( n )
    persistent k
    if n == 0, k = 0; return, end
    k = k + 1;
    multiWaitbar( 'BEM solver', k / n );
end