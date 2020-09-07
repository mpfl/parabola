/*

Draws an arch based on two parabolae

Uses Naca_sweep.scad and faces.scad

*/


use <Naca_sweep.scad>
use <faces.scad>

inner_x_int = 50;
inner_y_int = 210;

outer_x_int = 110;
outer_y_int = 240;

order = 360;
x_step = 0.1;

inner_a = -(inner_y_int / pow(inner_x_int, 2));
inner_c = inner_y_int;

outer_a = -(outer_y_int / pow(outer_x_int, 2));
outer_c = outer_y_int;

draw_arc();

module draw_arc() {
    coords = half_arc_coords_r(inner_a, inner_c, inner_x_int, inner_y_int, outer_a, outer_c, outer_x_int, outer_y_int, 0, x_step, order);
    f = faces("chain", nside=order, nseg=(len(coords) / order) - 1);
    difference() {
        union() {
            polyhedron(points = coords, faces = f);
            mirror([1,0,0]) polyhedron(points = coords, faces = f);
        }
    translate([0,0,-outer_y_int])
        cylinder(r = outer_x_int, h = outer_y_int);
    }
}

module draw_half_old() {
    for(x = [1 : 1 : inner_x_int + 1]) {
        y = (inner_a * pow(x,2) + inner_c); // This is the Y of the left point of the slice;
        m_inner = (2 * inner_a * x);
        m_slice = (-1/m_inner);
        slice_angle = (-atan(-1/(2 * inner_a * x))); // This is the angle of the slice at x;
        c_slice = (y - (m_slice * x));

        prime_a = (outer_a);
        prime_b = (-m_slice);
        prime_c = (outer_c - c_slice);
        
        prime_disc = (prime_b * prime_b - 4 * prime_a * prime_c);
        
        x_prime = (-prime_b - pow(prime_disc, 0.5)) / (2 * prime_a);
        y_prime = (m_slice * x_prime + c_slice);

        slice_centre_x = ((x + x_prime) / 2);
        slice_centre_y = ((y + y_prime) / 2);

        slice_centre = [slice_centre_x, 0, slice_centre_y];
        slice_diameter = pow(pow((x_prime - x),2)+pow((y_prime - y),2),0.5);

        //translate(slice_center) rotate([0,slice_angle,0]) cylinder(d = slice_diameter, height = 1);

        draw_slice(c = slice_centre, a = slice_angle, d = slice_diameter);

    }
}

function circle_angles(order) = [ for (i = [0:order-1]) i*(360/order) ];

function circle_coords(angles, r) = [ for (th = angles) [r*cos(th), r*sin(th)] ];

function slice_angle(i_a, x) = atan(-1/(2 * i_a * x));

function slice_centre(i_a, i_c, o_a, o_c, x) = [(x + (-(-(-1/(2 * i_a * x))) - pow(((-(-1/(2 * i_a * x))) * (-(-1/(2 * i_a * x))) - 4 * (o_a) * (o_c - ((i_a * pow(x,2) + inner_c) - ((-1/(2 * i_a * x)) * x)))), 0.5)) / (2 * (o_a))) / 2, 0, ((i_a * pow(x,2) + i_c) + ((-1/(2 * i_a * x)) * (-(-(-1/(2 * i_a * x))) - pow(((-(-1/(2 * i_a * x))) * (-(-1/(2 * i_a * x))) - 4 * (o_a) * (o_c - ((i_a * pow(x,2) + i_c) - ((-1/(2 * i_a * x)) * x)))), 0.5)) / (2 * (o_a)) + ((i_a * pow(x,2) + i_c) - ((-1/(2 * i_a * x)) * x)))) / 2];

function slice_ceiling(i_a, i_c, o_a, o_c, x) = ((-1/(2 * i_a * x)) * (-(-(-1/(2 * i_a * x))) - pow(((-(-1/(2 * i_a * x))) * (-(-1/(2 * i_a * x))) - 4 * (o_a) * (o_c - ((i_a * pow(x,2) + i_c) - ((-1/(2 * i_a * x)) * x)))), 0.5)) / (2 * (o_a)) + ((i_a * pow(x,2) + i_c) - ((-1/(2 * i_a * x)) * x)));

function slice_diameter(i_a, i_c, o_a, o_c, x) = pow(pow(((-(-(-1/(2 * i_a * x))) - pow(((-(-1/(2 * i_a * x))) * (-(-1/(2 * i_a * x))) - 4 * (o_a) * (o_c - ((i_a * pow(x,2) + i_c) - ((-1/(2 * i_a * x)) * x)))), 0.5)) / (2 * (o_a)) - x),2)+pow((((-1/(2 * i_a * x)) * (-(-(-1/(2 * i_a * x))) - pow(((-(-1/(2 * i_a * x))) * (-(-1/(2 * i_a * x))) - 4 * (o_a) * (o_c - ((i_a * pow(x,2) + i_c) - ((-1/(2 * i_a * x)) * x)))), 0.5)) / (2 * (o_a)) + ((i_a * pow(x,2) + i_c) - ((-1/(2 * i_a * x)) * x))) - (i_a * pow(x,2) + i_c)),2),0.5);

function slice_radius(i_a, i_c, o_a, o_c, x) = slice_diameter(i_a, i_c, o_a, o_c, x)/2;

function slice_coords(i_a, i_c, i_y, o_a, o_c, o_y, x, order) =
        x == 0
    ?
        T( z = (o_y + i_y)/2, v = R(y = 90, v = vec3D(v = circle_coords(circle_angles(order), (o_y - i_y)/2))))
    :
        T( x=slice_centre(inner_a, inner_c, outer_a, outer_c, x)[0], y = slice_centre(inner_a, inner_c, outer_a, outer_c, x)[1], z=slice_centre(inner_a, inner_c, outer_a, outer_c, x)[2], v =R(y = slice_angle(i_a, x), v = vec3D(v = circle_coords(circle_angles(order), slice_radius(inner_a, inner_c, outer_a, outer_c, x)))))
    ;

function half_arc_coords(i_a, i_c, i_x, i_y, o_a, o_c, o_x, o_y, order) = [ for (x = [0 : 1 : i_x + 1]) slice_coords(i_a, i_c, i_y, o_a, o_c, o_y, x, order)];

function half_arc_coords_r(i_a, i_c, i_x, i_y, o_a, o_c, o_x, o_y, start = 0, step = 1, order) =
        slice_ceiling(i_a, i_c, o_a, o_c, start) < 0
    ?
        slice_coords(i_a, i_c, i_y, o_a, o_c, o_y, start, order)
    :
        concat(slice_coords(i_a, i_c, i_y, o_a, o_c, o_y, start, order), half_arc_coords_r(i_a, i_c, i_x, i_y, o_a, o_c, o_x, o_y, start+step, step, order))
    ;

module draw_slice(c, a, r) {
    translate(c) rotate([0,a,0]) cylinder(r = r, h = 1);
}