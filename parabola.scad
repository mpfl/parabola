$fn = 60;

inner_x = 50;
inner_y = 210;

outer_x = 115;
outer_y = 240;

union() {
    draw_half();
    mirror([1,0,0]) draw_half();
}

module draw_half() {
    for(x = [0.1 : 0.1 : inner_x + 1]) {
        y = inner_a * pow(x,2) + inner_b * x + inner_c;
        m = -1/(2 * inner_a * x);
        c = y - m * x;

        inner_a = -inner_y/pow(inner_x,2);
        inner_b = -m;
        inner_c = inner_y - c;

        outer_a = -outer_y/pow(outer_x,2);
        outer_b = -m;
        outer_c = outer_y - c;        
        
        outer_disc = pow(-m,2) -4 * outer_a * outer_c;
        outer_int_x = (m - pow(outer_disc,0.5)) / (2 * outer_a);
        outer_int_y = (m * outer_int_x + c);
     
        cross_diameter = pow(pow((outer_int_x - x),2) + pow((outer_int_y - y),2),0.5);
      
        translate([(x + outer_int_x)/2,0,(y + outer_int_y)/2])
        rotate([0,-atan(m),0])
            cylinder(d = cross_diameter, h = 1);
    }
}
