// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

track_width = 8;
track_length = 64;
track_height = 2;
curves_in_circle = 8;
half_w = track_width / 2;
p_w = track_length + half_w;
curve_angle = 360 / 8;

module straight(start_point=([0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, -half_w, 0])
    cube([track_length, track_width, track_height]);
}

module a_curve(start_point=([0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, track_length])
    linear_extrude(track_height) {
        difference() {
            circle(track_length + half_w);
            circle(track_length - half_w);
            polygon([[0, 0], [0, -p_w], [-p_w, -p_w], [-p_w, p_w], [p_w, p_w], [p_w, 0]]);
            polygon([[0, 0], [2*p_w, 0], [2*p_w, -2*p_w]]);
        }
    }
}

module c_curve(start_point=([0,0]), angle=0) {
    mirror([0, 1, 0])
    a_curve(start_point, angle);
}

module bridge(start_point=([0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    straight();
}

module joint(start_point=([0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    difference() {
        cube(3);
        cube(1);
    }
}

$fa = 1;
$fs = 0.4;

straight();
joint([track_length, 40]);
c_curve([track_length, 0]);
a_curve();
//straight([20,20], 30);
//curve([-50, -50], -60);
bridge([-track_length, -40], 60);