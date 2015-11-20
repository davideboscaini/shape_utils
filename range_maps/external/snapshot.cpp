/**
 * NOTE: This code is *not* optimized in any way and can be made much faster by
 *       using convenient structures such as octrees or AABB trees.
 *
 * WARNING: The epsilon parameter in the intersection code seems to have a big
 *          effect on the quality of the final rangemap. Try rescaling the surface
 *          before taking the snapshot if the rangemap is empty or contains holes.
 *
 * Written by Emanuele Rodola
 * TU Munich
 *
 * last update: 19/10/2015
 */
#include "mex.h"
#include <cmath>
#include "mesh.h"
#include <iostream>

// Moeller-Trumbore algorithm
int rayTriangleIntersection(const vec3d<double>& o, const vec3d<double>& d, const vec3d<double>& p0, const vec3d<double>& p1, const vec3d<double>& p2, double& t)
{
    const double epsilon = 1e-5; // this seems to determine the quality of the final rangemap

    const vec3d<double> e1 = p1-p0;
    const vec3d<double> e2 = p2-p0;

    const vec3d<double> q  = cross_product(d,e2);
	
	const double a = e1.x*q.x + e1.y*q.y + e1.z*q.z; // determinant of the matrix M
    
	// the vector is parallel to the plane (the intersection is at infinity)
    if (a > -epsilon && a < epsilon)
        return 0;
    
    const double f = 1./a;
    const vec3d<double> s = o-p0;
    const double u = f * ( s.x*q.x + s.y*q.y + s.z*q.z );

	// the intersection is outside of the triangle
    if (u < 0.)
		return 0;

    const vec3d<double> r = cross_product(s,e1);
    const double v = f * ( d.x*r.x + d.y*r.y + d.z*r.z );

	// the intersection is outside of the triangle
    if (v < 0. || u+v > 1.)
		return 0;

    t = f * ( e2.x*r.x + e2.y*r.y + e2.z*r.z );
	
	return 1;
}

/**
 * projection can be either 'orthographic' or 'perspective'.
 * only the first character will be checked, so you can simply pass 'o' or 'p' if you like.
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
	if (nrhs != 6 || nlhs > 2)
		mexErrMsgTxt("Usage: [rangemap,matches] = snapshot(vertices, triangles, [w h], projection, f, ccd_width).");

	const double* const pts = mxGetPr(prhs[0]);
	const int np = int( mxGetN(prhs[0]) );
	const double* const tri = mxGetPr(prhs[1]);
	const int nt = int( mxGetN(prhs[1]) );
	const int range_w = static_cast<int>(mxGetPr(prhs[2])[0]);
	const int range_h = static_cast<int>(mxGetPr(prhs[2])[1]);
	const char* projection = mxArrayToString(prhs[3]);
	const double f = *mxGetPr(prhs[4]);
	const double ccd_width = *mxGetPr(prhs[5]);
	
	if (np == 3)
		mexErrMsgTxt("It seems like you only have 3 vertices. Please try to transpose the input matrix.");
		
	if (nt == 3)
		mexErrMsgTxt("It seems like you only have 3 triangles. Please try to transpose the input matrix.");
		
	if (ccd_width <= 0)
		mexErrMsgTxt("The CCD width must be a positive scalar number.");
	
	bool is_ortho = false;
	
	if (projection[0] == 'o')
		is_ortho = true;
	else if (projection[0] != 'p')
		mexErrMsgTxt("Projection method must be either orthographic or perspective.");

	//std::cout << np << " vertices, " << nt << " triangles" << std::endl;
	
	// Load the mesh

	mesh_t mesh;
	
	std::vector< vec3d<double> > vertices(np);
	
	for (int i=0; i<np; ++i)
	{
		vec3d<double>& pt = vertices[i];
		pt.x = pts[i*3];
		pt.y = pts[i*3+1];
		pt.z = pts[i*3+2];
		//std::cout << pt << std::endl;
	}
	
	mesh.put_vertices(vertices);
	
	for (int i=0; i<nt; ++i)
	{
		int a, b, c;
		a = tri[i*3] - 1; // 1-based to 0-based
		b = tri[i*3+1] - 1;
		c = tri[i*3+2] - 1;
		mesh.add_triangle(a,b,c);
		//std::cout << a << " " << b << " " << c << std::endl;
	}
	
	plhs[0] = mxCreateDoubleMatrix(range_h, range_w, mxREAL);
	double* rangemap = mxGetPr(plhs[0]);
	
	double* matches = 0;
	if (nlhs==2)
	{
		plhs[1] = mxCreateDoubleMatrix(range_h, range_w, mxREAL);
		matches = mxGetPr(plhs[1]);
	}
	
	std::cout << "Image resolution: " << range_w << "x" << range_h << std::endl;
	std::cout << (is_ortho?"Orthographic":"Perspective") << " projection" << std::endl;
	
	std::cout << "Taking snapshot... " << std::flush;

	// fill rangemap with NaN
	const double nan = *mxGetPr(mxCreateDoubleScalar(mxGetNaN()));
	std::fill(rangemap, rangemap+range_h*range_w, nan);
	
	if (matches)
		std::fill(matches, matches+range_h*range_w, nan);
	
	const double ccd_height = ccd_width * range_h / range_w;
	
	double min_x = -ccd_width/2., max_x = ccd_width/2.;
	double min_y = -ccd_height/2., max_y = ccd_height/2.;
	
	const double step_x = (max_x - min_x) / (range_w-1);
	const double step_y = (max_y - min_y) / (range_h-1);

	int yr = 0, xr;
	for (double y=min_y; y<max_y; y += step_y, ++yr)
	{
		xr = 0;
		for (double x=min_x; x<max_x; x += step_x, ++xr)
		{
			//std::cout << "(" << yr << "," << xr << ") " << std::flush;
			
			const vec3d<double> image_point(x, y, -f);
			
			vec3d<double> dir = (is_ortho ? vec3d<double>(0,0,-1) : image_point / std::sqrt(x*x + y*y + f*f));
			vec3d<double> C = (is_ortho ? image_point : vec3d<double>(0,0,0));
			
			double best_sol = nan, closest_match = nan;
			bool found = false;
			
			for (int i=0; i<nt; ++i)
            {
				const vec3d<double>& v1 = mesh.vertices[ mesh.triangles[i].p0 ].p;
				const vec3d<double>& v2 = mesh.vertices[ mesh.triangles[i].p1 ].p;
				const vec3d<double>& v3 = mesh.vertices[ mesh.triangles[i].p2 ].p;

				double t;
				const int flag = rayTriangleIntersection(C, dir, v1, v2, v3, t);
            
				if (flag)
				{
					const double intersection = C.z + t*dir.z;
					
					double match = nan;
					if (matches) // pick the closest vertex as a match
					{
						const vec3d<double> new_vert = C + t*dir;
						
						const double d1 = magnitude(new_vert-v1);
						const double d2 = magnitude(new_vert-v2);
						const double d3 = magnitude(new_vert-v3);
						
						if (d1 < d2)
						{
							if (d1 < d3)
								match = mesh.triangles[i].p0;
							else
								match = mesh.triangles[i].p2;
						}
						else
						{
							if (d2 < d3)
								match = mesh.triangles[i].p1;
							else
								match = mesh.triangles[i].p2;
						}
					}
					
					if (!found)
					{
						best_sol = intersection;
						closest_match = match;
						found = true;
						//std::cout << "#";
					}
					else
					{
						if (intersection > best_sol)
						{
							best_sol = intersection;
							closest_match = match;
							//std::cout << "#";
						}
					}
				}
			}
			//std::cout << std::endl;
			
			rangemap[xr*range_h + yr] = best_sol;
			
			if (matches)
				matches[xr*range_h + yr] = closest_match + 1;
		}
	}
	
	std::cout << "done." << std::endl;
}
