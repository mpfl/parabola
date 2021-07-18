neopixel_inner_diameter = 31.7;
neopixel_outer_diameter = 44.5;
parabola_leg_outer_diameter = 60;
parabola_leg_inner_diameter = 50;
thickness = 6.7;
pcb_thickness = 1.7;
ledge = 1;
$fn = 360;

//case_bottom();
case_lid();

module case_bottom() {

    difference() {
        union() {
            case_shell();
            translate([-(200-57)/2,0,0])
            difference() {
                union() {
                    holder_inner();
                    //holder_outer();
                    //holder_bottom();
                }
                //cable_conduit();
            }


            translate([(200-57)/2,0,0])
            difference() {
                union() {
                    holder_inner();
                    //holder_outer();
                    //holder_bottom();
                }
                //cable_conduit();
            }
        }
    }
}

module case_lid() {

    difference() {
        union() {

            lid_shell();

            translate([-(200-57)/2,0,0])
            difference() {
                union() {
                    //holder_inner();
                    holder_outer();
                    //holder_bottom();
                }
                //cable_conduit();
            }

            translate([(200-57)/2,0,0])
            difference() {
                union() {
                    //holder_inner();
                    holder_outer();
                    //holder_bottom();
                }
                //cable_conduit();
            }
        }
    translate([-(200-57)/2,0,22])
        cylinder(d = neopixel_outer_diameter + 1, h = 4);
    translate([(200-57)/2,0,22])
        cylinder(d = neopixel_outer_diameter + 1, h = 4);

    }

}

module lid_shell() {
        translate([0,0,23])
            linear_extrude(2)
                hull() {
                    translate([-100,parabola_leg_outer_diameter/2,0])
                        circle(d=2.5);
                    translate([100,-parabola_leg_outer_diameter/2,0])
                        circle(d=2.5);
                        translate([100,parabola_leg_outer_diameter/2,0])
                    circle(d=2.5);
                        translate([-100,-parabola_leg_outer_diameter/2,0])
                    circle(d=2.5);
                }    
}

//neopixel_proxy();

module case_shell() {
    difference() {
        linear_extrude(25)
            hull() {
                translate([-100,parabola_leg_outer_diameter/2,0])
                    circle(d=5);
                translate([100,-parabola_leg_outer_diameter/2,0])
                    circle(d=5);
                    translate([100,parabola_leg_outer_diameter/2,0])
                circle(d=5);
                    translate([-100,-parabola_leg_outer_diameter/2,0])
                circle(d=5);
            }
        translate([0,0,23])
            linear_extrude(4)
                hull() {
                    translate([-100,parabola_leg_outer_diameter/2,0])
                        circle(d=3);
                    translate([100,-parabola_leg_outer_diameter/2,0])
                        circle(d=3);
                        translate([100,parabola_leg_outer_diameter/2,0])
                    circle(d=3);
                        translate([-100,-parabola_leg_outer_diameter/2,0])
                    circle(d=3);
                }
        translate([0,0,2])
            linear_extrude(25)
                hull() {
                    translate([-98,parabola_leg_outer_diameter/2-2,0])
                        circle(d=3);
                    translate([98,-parabola_leg_outer_diameter/2+2,0])
                        circle(d=3);
                        translate([98,parabola_leg_outer_diameter/2-2,0])
                    circle(d=3);
                        translate([-98,-parabola_leg_outer_diameter/2+2,0])
                    circle(d=3);
                }
    }
}


module cable_conduit() {
    translate([0,-5,2])
    cube([parabola_leg_outer_diameter / 2 + 1, 10, 20]);
}

module holder_bottom() {
    cylinder(d = parabola_leg_outer_diameter, h=5);
}

module holder_outer() {
    translate([0,0,23])
    difference() {
        cylinder(d = parabola_leg_inner_diameter, h = 5);
        translate([0,0,-1])
            cylinder(d = neopixel_outer_diameter + 1, h = 7);
    }
}

module holder_inner() {
    translate([0,0,5]) {
        holder_inner_lower();
        translate([0,0,16])
        holder_inner_upper();
    }
}

module holder_inner_lower() {
    difference() {
        cylinder(h = 20, d = neopixel_inner_diameter + 3);
            translate([0,0,3]) {
                cube([neopixel_outer_diameter, 10, 40], center = true);
                cube([10, neopixel_outer_diameter, 40], center = true);
            }
    }

}

module holder_inner_upper() {
    translate([0,0,pcb_thickness * 2])
    difference() {
        cylinder(h = pcb_thickness * 2, d = neopixel_inner_diameter);
            cube([neopixel_outer_diameter, 10, pcb_thickness * 5], center = true);
            cube([10, neopixel_outer_diameter, pcb_thickness * 5], center = true);
    }
}


module neopixel_proxy() {
    color("green")
        difference() {
            cylinder(h = thickness, d = neopixel_outer_diameter);
            translate([0,0,-1])
                cylinder(h = thickness + 2, d = neopixel_inner_diameter);
        }
}
