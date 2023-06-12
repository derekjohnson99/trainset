// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

layout = ["A", "A", "A", "A", "A", "A", "S", "S", "C", "C", "C", "C", "C", "C", "B"];
track_width = 8;
track_length = 64;
track_height = 2;
curves_in_circle = 8;
half_w = track_width / 2;
p_w = track_length + half_w;
curve_angle = 360 / curves_in_circle;

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
         x = track_length * (a % 4),
         y = track_length * floor(a / 4))
    [x, y, 0]];
echo(sp);

th = [ 0, for (a = [0: len(layout)-1])
   let (item = layout[a],
        angle = (item == "A") ? 
            curve_angle
        : (item == "C") ?
            -curve_angle
        : (item == "S") ?
            0
        : (item == "B") ?
            0
        :
            0
        )
        angle];

function sumv(v, i, s=0)  = (i == s ? v[i] : v[i] + sumv(v, i-1, s));

start_angles = [ for (i = [0 : len(th)-1])
    let (angle = sumv(th, i))
    angle];
echo(start_angles);

track_r_thetas = [ for (i = [0 : len(layout)-1])
    let (item = layout[i],
         length = (item == "A") ?
            2 * sin(curve_angle/2)
         : (item == "C") ?
            2 * sin(curve_angle/2)
         : (item == "S") ?
            1
         : (item == "B") ?
            2
         :
            undef,
         angle =  (item == "A") ?
            -curve_angle/2
         : (item == "C") ?
            curve_angle/2
         : (item == "S") ?
            0
         : (item == "B") ?
            0
         :
            undef
        )
        [length, angle]];
echo(track_r_thetas);

for (a = [0 : len(layout)-1])
{
    {
    item = layout[a];
    color("green")
    joint(sp[a], start_angles[a]);
    if (item == "A")
    {
        color("cyan")
        a_curve(sp[a], start_angles[a]);
    }
    else if (item == "C")
    {
        color("blue")
        c_curve(sp[a], start_angles[a]);
    }
    else if (item == "S")
    {
        color("yellow")
        straight(sp[a], start_angles[a]);
    }
    else if (item == "B")
    {
        color("red")
        bridge(sp[a], start_angles[a]);
    }
    }
}
