#theta inner angle, phi is the outer angle

MIN_STEP = 1e-4

"find the angles (phi, theta) of the point on the surface corresponding to the 3D point x"
function angles(R, x)
    phi = atan2(x[2], x[1])
    theta = atan2(x[3], norm(x[1:2]) - R(phi))
    return (phi, theta)
end

"find the normal at the given point in the parametrization, given the derivatives of r and R (as numbers)"
function normal(R, r, dRdphi, drdphi, drdtheta, phi, theta)
    fac1 = -r * sin(theta) + drdtheta * cos(theta)
    dtheta = [fac1 * cos(phi), fac1 * sin(phi), r * cos(theta) + drdtheta * sin(theta)]
    fac2 = dRdphi + drdphi * cos(theta)
    fac3 = R + r * cos(theta)
    dphi = [fac2 * cos(phi) - fac3 * sin(phi), fac2 * sin(phi) + fac3 * cos(phi), drdphi * sin(theta)]
    return normalize(cross(dtheta, dphi))
end

"Find the signed distance to the torus given the functions R and r, and a 3D point x"
function distance(R, r, x)
    phi, theta = angles(R, x)
    rhat = norm([x[3], norm(x[1:2]) - R(phi)])
    #println("$rhat : $(x[1])")
    return rhat - r(phi, theta)
end

function torus(R, r, phi, theta)
    rphitheta = r(phi, theta)
    fac = R(phi) + rphitheta * cos(theta)
    return [fac * cos(phi), fac * sin(phi), rphitheta * sin(theta)]
end

function toruspoints(R, r, n, m)
    pts = zeros(3, n * m)
    for i=1:n
        for j=1:m
            pts[:, (i-1) * m + j] = torus(R, r, 2*pi/n*i, 2*pi/m*j)
        end
    end
    return pts
end

function raytrace(R, r, phi, theta, dir)
    x0 = torus(R, r, phi, theta) + MIN_STEP * dir
    x = x0
    #TODO: remove this test array
    #steps = x
    #dists = zeros(0)
    nsteps = 0
    while true
        dist = distance(R, r, x)
        #dists = [dists; dist]
        if dist > 0
            break
        end
        nsteps += 1
        x0 = x
        #our distance field is NOT conservative, so divide step size by 2 for safe measure
        step = max(abs(dist)/2, MIN_STEP)
        x += step * dir
        #steps = [steps x]
    end
    #println("steps taken: $nsteps")
    return angles(R, x0)
end

function initial_cond(R, r, dRdphi, drdphi, drdtheta, phi, theta, dir, bounces)
    params = zeros(2, bounces)
    angmom = zeros(bounces)
    coses = zeros(bounces)
    for i=1:bounces
        phi, theta = raytrace(R, r, phi, theta, dir)
        params[:, i] = [phi, theta]
        n = normal(R(phi), r(phi, theta), dRdphi(phi), drdphi(phi, theta), drdtheta(phi, theta), phi, theta)
        dir = normalize(dir - 2 * dot(n, dir) * n)
        angmom[i] = cross(torus(R, r, phi, theta), dir)[3]
        coses[i] = dot(n, dir)
    end
    return params, angmom, coses
end

function plot_bounces(R, r, dRdphi, drdphi, drdtheta, phi, theta, dir, bounces)
    params, angmom, coses = initial_cond(R, r, dRdphi, drdphi, drdtheta, phi, theta, dir, bounces)
    hitpoints = zeros(3, size(params, 2) + 1)
    hitpoints[:,1] = torus(R, r, phi, theta)
    for i=1:size(params, 2)
        hitpoints[:, 1+i] = torus(R, r, params[1, i], params[2, i])
    end
    pts = toruspoints(R, r, 64, 32)
    scatter(pts[1,:], pts[2,:], pts[3,:], m=(:cyan, stroke(0)), ms = 0.5)
    path3d!(hitpoints[1,:], hitpoints[2,:], hitpoints[3,:], m=(stroke(0), :red), ms=0.5)
end

function plot_bounces2d(R, r, dRdphi, drdphi, drdtheta, phi, theta, dir, bounces)
    params, angmom, coses = initial_cond(R, r, dRdphi, drdphi, drdtheta, phi, theta, dir, bounces)
    #params = [[phi, theta] params]
    scatter(params[1,:], params[2, :], m=(stroke(0)), ms = 3, zcolor = coses)
end
