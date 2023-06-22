// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

layouts = [
    "BAASSAAAACCAAAA",
    "BAAAAAASSCCCCCC",
    "BAAAASSACAAAAAC",
    "BAAAASACSAAAAAC",
    "BAAAAACSSAAAAAC",
    "BAASSAAACAACAAA",
    "BAAAASSCAAAAACA",
    "BAAAASCASAAAACA",
    "BAAAACASSAAAACA",
    "BAAACAASSAAACAA"
];
layout = layouts[1];
track_width = 8;
track_length = 64;
track_height = 4;
curves_in_circle = 8;
half_w = track_width / 2;
p_w = track_length + half_w;
curve_angle = 360 / curves_in_circle;
origin = [0, 0, 0];

module straight() {
    translate([0, -half_w, 0])
    cube([track_length, track_width, track_height]);
}

module a_curve() {
    translate([0, track_length])
    linear_extrude(track_height) {
        intersection() {
            polygon([[0, 0], [p_w, -p_w], [0, -p_w]]);
            difference() {
                circle(track_length + half_w);
                circle(track_length - half_w);
            }
        }
    }
}

module c_curve() {
    translate([0, -track_length])
    linear_extrude(track_height) {
        intersection() {
            polygon([[0, 0], [p_w, p_w], [0, p_w]]);
            difference() {
                circle(track_length + half_w);
                circle(track_length - half_w);
            }
        }
    }
}

module bridge() {
    let (
        rad_o = 62,
        rad_i = 16,
        cent_o = 12
    )
    translate([0, half_w, 0])
    rotate([90, 0, 0])
    linear_extrude(track_width) {
        difference() {
            union() {
                square([2*track_length, 20]);
                difference() {
                    translate([track_length, track_height, 0])
                    circle(20);
                    translate([0, -track_length, 0])
                    square([2*track_length, track_length]);
                }
            }
            translate([cent_o, rad_o, 0])
            circle(rad_o - track_height);
            translate([0, track_height, 0])
            square(cent_o);
            translate([2*track_length-cent_o, rad_o, 0])
            circle(rad_o - track_height);
            translate([2*track_length-cent_o, track_height, 0])
            square(cent_o);
            translate([track_length-rad_i, 0, 0])
            square([rad_i*2, track_height]);
            translate([track_length, track_height, 0])
            circle(rad_i);
        }
    }
}

module joint() {
    translate([-0.2, -half_w, 0])
    cube([0.4, track_width, track_height + 1]);
}

$fa = 1;
$fs = 0.4;

// Function to return the length and angle of each type of track piece
function piece_details(piece) = (
    let (
        length = piece == "A" ?
            track_length * 2 * sin(curve_angle/2)
        : piece == "C" ?
            track_length * 2 * sin(curve_angle/2)
        : piece == "S" ?
            track_length * 1
        : piece == "B" ?
            track_length * 2
        :
            undef,
        angle = piece == "A" ?
            curve_angle / 2
        : piece == "C" ?
            -curve_angle / 2
        : piece == "S" ?
            0
        : piece == "B" ?
            0
        :
            undef
    )
    [length, angle]
);

// Function to find the new cursor position (x, y and angle) given the
// original cursor postion, and the details of the track piece
function new_cursor(cursor, piece) = (
    let (
        piece_detail = piece_details(piece),
        p_len = piece_detail[0],
        p_angle = piece_detail[1],
        x = cursor[0] + p_len * cos(cursor[2] + p_angle),
        y = cursor[1] + p_len * sin(cursor[2] + p_angle),
        angle = cursor[2] + 2 * p_angle
    )
    [x, y, angle]
);

// Function to give the final cursor position (x, y and angle) of the
// given piece number in the layout
function place_piece(i) = (
    i == 0 ?
        new_cursor(origin, layout[i])
    :
        new_cursor(place_piece(i-1), layout[i])
);

// Vector of all the track positions for the given track layout
positions = [
    origin,
    for (i = [0 : len(layout)-1])
        place_piece(i)
];

for (i = [0 : len(layout)-1])
{
    pos = positions[i];
    start_point = [pos[0], pos[1], 0];
    angle = pos[2];
    translate(start_point)
    rotate([0, 0, angle])
    {
        color("black")
        joint();

        piece = layout[i];
        if (piece == "A")
        {
            color("blue")
            a_curve();
        }
        else if (piece == "C")
        {
            color("magenta")
            c_curve();
        }
        else if (piece == "S")
        {
            color("lime")
            straight();
        }
        else if (piece == "B")
        {
            color("red")
            bridge();
        }
    }
}
