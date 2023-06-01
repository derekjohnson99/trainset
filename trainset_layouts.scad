// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

layout = ["A", "A", "A", "A", "A", "A", "S", "S", "C", "C", "C", "C", "C", "C", "B"];
track_width = 8;
track_length = 64;
track_height = 2;
curves_in_circle = 8;
half_w = track_width / 2;
p_w = track_length + half_w;
curve_angle = 360 / 16;
curve_length = track_length * 2 * sin(curve_angle);

module straight(start_point=([0,0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, -half_w, 0])
    cube([track_length, track_width, track_height]);
}

module a_curve(start_point=([0,0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, track_length])
    linear_extrude(track_height) {
        difference() {
            circle(track_length + half_w);
            circle(track_length - half_w);
            polygon([[0, 0], [0, -p_w], [-p_w, -p_w], [-p_w, p_w], [p_w, p_w], [p_w, 0]]);
            polygon([[0, 0], [p_w, 0], [p_w, -p_w]]);
        }
    }
}

module c_curve(start_point=([0,0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, -track_length])
    linear_extrude(track_height) {
        difference() {
            circle(track_length + half_w);
            circle(track_length - half_w);
            polygon([[0, 0], [0, p_w], [-p_w, p_w], [-p_w, -p_w], [p_w, -p_w], [p_w, 0]]);
            polygon([[0, 0], [p_w, 0], [p_w, p_w]]);
        }
    }
}

module bridge(start_point=([0,0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([0, -half_w, 0])
    cube([2*track_length, track_width, track_height]);
}

module joint(start_point=([0,0,0]), angle=0) {
    translate(start_point)
    rotate([0, 0, angle])
    translate([-0.2, -half_w, 0])
    cube([0.4, track_width, track_height + 1]);
}

$fa = 1;
$fs = 0.4;

//curr_point = [0, 0, 0];
curr_angle = 0;

sp = [ for (a = [0 : len(layout)-1])
    let (item = layout[a],
         x = track_length * floor(a / 4),
         y = track_length * (a % 4))
    [x, y, 0]];
echo(sp);

for (a = [0 : len(layout)-1])
{
    let (curr_point = [track_length * a, 
                       0,
                       0],
         curr_angle = 0)
    {
    item = layout[a];
    if (item == "A")
    {
        a_curve(sp[a], curr_angle);
        //curr_angle = curr_angle - curve_angle;
    }
    else if (item == "C")
    {
        c_curve(sp[a], curr_angle);
        //curr_angle = curr_angle + curve_angle;
    }
    else if (item == "S")
    {
        straight(sp[a], curr_angle);
    }
    else if (item == "B")
    {
        bridge(sp[a], curr_angle);
    }
    }
}

//joint();
//straight();
//joint([track_length, 0, 0]);
//c_curve([track_length, 0, 0]);
//a_curve();

//joint([curve_length * cos(curve_angle),
//       curve_length * sin(curve_angle), 0],
//       curve_angle*2);

//color("red")
//bridge([curve_length * cos(curve_angle),
//        curve_length * sin(curve_angle), 0],
//        curve_angle*2);

