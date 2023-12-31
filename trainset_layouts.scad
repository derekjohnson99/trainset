// OpenSCAD file to display all possible layouts of Ikea Lillabo 20-piece basic trainset

layouts = [
    "BAAAAAASSCCCCCC",
    "BAASSAAAACCAAAA",
    "BAAAASSACAAAAAC",
    "BAAAASACSAAAAAC",
    "BAAAAACSSAAAAAC",
    "BAASSAAACAACAAA",
    "BAAAASSCAAAAACA",
    "BAAAASCASAAAACA",
    "BAAAACASSAAAACA",
    "BAAACAASSAAACAA"
];

track_width = 7;
track_length = 56;
track_height = 2;
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
        inner_radius = 12,
        bridge_shape = [
            [0, 0],
            for (i = [0 : 2 * track_length])
            let (
                height_range = 8,
                t_ratio = 360 / (track_length * 2)
            )
            [i, height_range + track_height - cos(i * t_ratio) * height_range],
            [track_length * 2, 0]
        ],
        side_arch_distance = track_length / 2 + 4
    )
    translate([0, half_w, 0])
    rotate([90, 0, 0])
    linear_extrude(track_width) {
        difference() {
            polygon(bridge_shape);
            // Inner arch
            translate([track_length, track_height, 0])
            circle(inner_radius);
            translate([track_length - inner_radius, 0, 0])
            square([inner_radius * 2, track_height]);
            // Side arches
            translate([side_arch_distance, 0, 0])
            circle(8);
            translate([2 * track_length - side_arch_distance, 0, 0])
            circle(8);
        }
    }
}

module joint() {
    translate([-0.2, -half_w - 0.2, 0])
    cube([0.4, track_width + 0.4, track_height]);
}

module train_engine() {
    translate([0, -4, 1])
    cube([8, 8, 6]);
    translate([8, 0, 3.5])
    rotate([0, 90, 0])
    cylinder(7, 2.5, 2.5);
    // smokestack
    translate([13, 0, 5])
    cylinder(5, 1, 1);
    // back wheels
    translate([4, -half_w, 2])
    rotate([90, 0, 0])
    cylinder(0.5, 2, 2);
    translate([4, half_w, 2])
    rotate([90, 0, 0])
    cylinder(0.5, 2, 2);
    // front wheels
    translate([13, -3, 2])
    rotate([90, 0, 0])
    cylinder(0.5, 2, 2);
    translate([13, 3, 2])
    rotate([90, 0, 0])
    cylinder(0.5, 2, 2);
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

// Function to find the new cursor position ([x, y, z] and angle) given
// the original cursor postion, and the details of the track piece
function new_cursor(cursor, piece) = (
    let (
        piece_detail = piece_details(piece),
        p_len = piece_detail[0],
        p_angle = piece_detail[1],
        coord = cursor[0],
        c_angle = cursor[1],
        x = coord.x + p_len * cos(c_angle + p_angle),
        y = coord.y + p_len * sin(c_angle + p_angle),
        z = coord.z,
        angle = c_angle + 2 * p_angle
    )
    [[x, y, z], angle]
);

// Function to give the final cursor position ([x, y, z] and angle) of
// the given piece number in the layout
function place_piece(layout_no, piece_no) = (
    let (
        piece = layouts[layout_no][piece_no]
    )
    piece_no == 0 ?
        new_cursor([[0, 0, 0], 0], piece)
    :
        new_cursor(place_piece(layout_no, piece_no-1), piece)
);

for (l = [0 : len(layouts)-1])
{
    piece_count = len(layouts[l]);
    layout_angle = l == 0 ? 0 : 40 * l;
    //layout_angle = 0;
    radius = 6 * track_length;
    layout_point = l == 0 ? [-track_length, 0, 0] :
        [radius * cos(layout_angle), radius * sin(layout_angle), 0];
    //layout_point = [-track_length, 0, 0];
    piece_position = [
        [[0, 0, 0,], 0],
        for (p = [0 : piece_count-1])
            place_piece(l, p)
    ];

    translate(layout_point)
    rotate(layout_angle)

    for (p = [0 : piece_count-1])
    {
        piece = layouts[l][p];
        piece_start = piece_position[p][0];
        piece_angle = piece_position[p][1];
        piece_colour = piece == "B" ? "red" : p % 2 == 0 ? "navy" : "yellow";
        translate(piece_start)
        rotate(piece_angle)
        {
            color("black")
            joint();

            color(piece_colour)
            if (piece == "A")
            {
                a_curve();
            }
            else if (piece == "C")
            {
                c_curve();
            }
            else if (piece == "S")
            {
                straight();
            }
            else if (piece == "B")
            {
                bridge();
            }
        }
    }
}

color("green")
rotate(90)
translate([28, 0, track_height])
train_engine();