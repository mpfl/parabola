/*
-------------------------------------------------------------------------
faces.scad: Generate faces for simply polyhedrons in OpenSCAD
Copyright (C) 2015 Runsun Pan (run+sun (at) gmail.com) 
Source: https://github.com/runsun/faces.scad

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program; if not, see <http://www.gnu.org/licenses/gpl-2.0.html>
-------------------------------------------------------------------------
*/

// Run showall() to see all exaples. 

function reverse(o)=
(
    [ for(i=[0:len(o)-1]) o[len(o)-1-i] ]
);

    
function joinarr(arr, _rtn=[], _i=0)= 
(
	_i>len(arr)-1? _rtn
	: joinarr( arr, concat( _rtn, arr[_i]), _i+1)   
); 
    
    
function roll(arr,count=1)=
(
    let( L= len(arr)
       , count= count<0?L+count:count
       )
 	count==0 || count>L-1? arr
	:concat( [for(i= [L-count:L-1]) arr[i]]
		   , [for(i= [0:L-count-1]) arr[i]]
		   )
); 
   
           
function transpose(mm)=
(
	[ for(c=[0:len(mm[0])-1]) 
        [for(r=[0:len(mm)-1]) 
             mm[r][c]] ]
);           

    
function faces( shape="rod" // cubesides|rod|chain|ring|tube
              , nside=6     // # of sides
              , nseg=3)=    // # of segments for chain
(

    let (  s = nside                                
        , s2= 2*nside                              
        , s3= 3*nside
        , rng= [for (i=[0:s-1])i]
        , rng2= [for (i= [s:s2-1]) i ]
        , rngnn=[for( i= [nseg*nside:(nseg+1)*nside-1]) i ]
                //range( (nseg)*nside, (nseg+1)*nside)    
        )
        
	//==================================================
	// cubensides
    //
	//       _6-_
	//    _-' |  '-_
	// 5 '_   |     '-7
	//   | '-_|   _-'| 
	//   |    |-4'   |
	//   |   _-_|    |
	//   |_-' 2 |'-_ | 
	//  1-_     |   '-3
	//     '-_  | _-'
	//        '-.'
	//          0
	shape=="cubesides"
	? [ for(i= rng) //range(s))
		  [ i
			, i==s-1?0:i+1
			, (i==s-1?0:i+1)+s
			, i+s
		  ]
	  ]

    //==================================================
	// rod
	
    : shape=="rod"
	? concat( [ reverse(rng)]
              , [rng2] //[range(s,s2) ],
			  , faces("cubesides", s) ) 
              
    //==================================================
	// tube
	//             _6-_
	//          _-' |  '-_
	//       _-'   14-_   '-_
	//    _-'    _-'| _-15   '-_
	//   5_  13-'  _-'  |      .7
	//   | '-_ |'12_2-_ |   _-' | 
	//   |    '-_'|    '|_-'    |
	//   |   _-| '-_10_-|'-_    |
	//   |_-'  |_-| 4' _-11 '-_ | 
	//   1_   9-  | |-'       _-3
	//     '-_  '-8'|      _-'    
	//        '-_   |   _-'
	//           '-_|_-'
    //              0
    //  bottom=	 [ [0,3,11, 8]
    //			 , [1,0, 8, 9]
    //			 , [2,1, 9,10]
    //			 , [3,2,10,11] ];
    //
    //	top	=	 [ [4,5,13,12]
    //			 , [5,6,14,13]
    //			 , [6,7,15,14]
    //			 , [7,4,12,15] ]
    : shape=="tube"
	? concat( faces( "cubesides", s )  // outside sides
			, [ for(f=faces( "cubesides", s ))    // inner sides
					reverse( [ for(i=f) i+s2] )
			  ]
			, [ for(i=rng)         // bottom faces
				   [i, (i+s-1)%s, ((i+s-1)%s)+s2, i+s2 ] 
			  ]
			, [ for(i=rng2)     // top faces
				  [i, i==s2-1?s:i+1, i==s2-1?s3:i+s2+1, i+s2 ]
			  ]
			)	  

	//==================================================
	// chain                
	//       _6-_-------10------14
	//    _-' |  '-_    | '-_   | '-_
	//  2'_   |     '-5-----'9-------13
	//   | '-_|   _-'|  |    |  |    |
	//   |    |-1'   |  |    |  |    |
	//   |   _-_|----|-11_---|--15   |
	//   |_-' 7 |'-_ |    '-_|    '-_| 
	//  3-_     |   '-4------8-------12
	//     '-_  | _-'
	//        '-.'
	//          0
	//
	:shape=="chain"
	? concat( [ reverse(rng)] // starting face
			, [[for(i=[ nseg*s: (nseg+1)*s-1])i]] // ending face
			, joinarr( [ for(c= [0:nseg-1]) 
				 [ for(f=faces("cubesides", nside))
					[ for(i=f) i+c*nside]
				 ]
			  ])
			)  
                    
    //==================================================
	// ring 
 	/*  
        ring is a chain-like shape with the beg
        and end faces joined.
                    
        A ring with nseg=6, nside=4            
    
               13-------------9
             _-`|`-_______10-` `-_
          _-'   _-`|       |`-_   `-_ 
      17.'____.' -_|_____11|   `-6____.5
        |`-_  |`-_-`        `-_-`| _-`| 
        |   `-_ _-`-22____2_-`  _-`   | 
      16|_____|`-_/_|______|\_-` |7__ |4
         `-_   21|  |      | |1 `  _-`
            `-_  |  |23___3| |  _-`
               `-|-/________\|-`
                 20          0
    
        Using a faces("chain", nside=4, count=5) ### NOTE: count=5
        and:
        
        joining faces:
        fj= [ [ 0,1,21,20 ]
            , [ 1,2,22,21 ]
            , [ 2,3,23,22 ]
            , [ 3,0,20,23 ]
            ]
            
        ref: roll([0,1,2,3],-1)= [1,2,3,0]
            
        Transposed 
        fjt=[ [  0, 1, 2, 3 ]  range(nside) = A
            , [  1, 2, 3, 0 ]  roll( A ,-1)
            , [ 21,22,23,20 ]  roll( B ,-1)
            , [ 20,21,22,23 ]  range( (nseg-1)*nside, nseg*nside) = B
            ]
        
    */
    
           
    : shape=="ring"  
	? concat( transpose(
               [ rng 
               , roll( rng, -1)
               , roll( rngnn,-1)
               , rngnn
               ] 
              )
            , joinarr( [ for(c= [0:nseg-1])
				 [ for(f=faces("cubesides", nside))
					[ for(i=f) i+c*nside]
				 ]
			  ])
			)
                   
    //------------------------------------                
	:[]
);
  
module header(mod,color){
    echo(str("<span style='color:"
             , color, "'>", mod, " ( \"",color,"\" )"
             , "</span>"));
}    
    
                      

module cubesides_faces(color){  

    header(parent_module(1),color);
    
    pts0 = [ [-0.214054, 1.26998, -0.239369]
    , [-2.74931, 2.63763, 2.56388]
    , [-2.99255, -1.0968, 4.16585]
    , [-0.457295, -2.46445, 1.3626]
    , [-1.76143, 0.856897, -1.43728]
    , [-4.29668, 2.22455, 1.36597]
    , [-4.53993, -1.50988, 2.96794]
    , [-2.00467, -2.87753, 0.164688]
    ];
    pts = [ for( p=pts0 ) p+[-1,3,-3] ];
     
    //echo(pts = arrprn(pts,dep=3) );                    
   
    faces=faces("cubesides",nside=4);
    //echo(pts=pts,"<br/>", faces=faces);
    
    color( color, .5)
    polyhedron( points = pts, faces=faces );
}
//cubesides_faces();

module rod_faces1(color){

    header(parent_module(1),color);

    pts0 = [ [-0.214054, 1.26998, -0.239369]
    , [-2.74931, 2.63763, 2.56388]
    , [-2.99255, -1.0968, 4.16585]
    , [-0.457295, -2.46445, 1.3626]
    , [-1.76143, 0.856897, -1.43728]
    , [-4.29668, 2.22455, 1.36597]
    , [-4.53993, -1.50988, 2.96794]
    , [-2.00467, -2.87753, 0.164688]
    ];
    pts = [ for( p=pts0 ) p+[-2.5,4.5,3] ];
               
    //echo(pts = arrprn(pts,dep=3) );                    
    
    faces=faces("rod",nside=4);
    //echo(faces=faces);
    
    color( color, 0.9)
    polyhedron( points = pts, faces=faces );
}

//rod_faces1();

module rod_faces2(color){ 
    
  header(parent_module(1),color);
  
    pts = [ [-0.452198, -1.10886, 1.47902]
, [-1.72335, -1.61183, 0.0191524]
, [-3.60949, -2.10785, 0.462376]
, [-4.22447, -2.10091, 2.36546]
, [-2.95332, -1.59794, 3.82533]
, [-1.06718, -1.10192, 3.3821]
, [0.0945813, -3.02388, 1.6627]
, [-1.17657, -3.52685, 0.202832]
, [-3.06271, -4.02287, 0.646056]
, [-3.67769, -4.01592, 2.54914]
, [-2.40654, -3.51296, 4.00901]
, [-0.520406, -3.01694, 3.56578]
];
//    echo(pts = arrprn(pts,dep=3) );                    

    color( color, 0.9)
    polyhedron( points = pts
              , faces=faces("rod",nside=6) );
}

//rod_faces2();

module tube_faces(color){ 

    header(parent_module(1),color);

    // [out_bot, out_top, in_bot, in_top ] 
    ptgroups=
      [   [ [2.52951, -1.67042, -1.05641]
          , [2.38087, -1.8313, -1.17754]
          , [2.2724, -1.9642, -1.3598]
          , [2.21471, -2.05613, -1.58534]
          , [2.21346, -2.09807, -1.8321]
          , [2.26876, -2.08594, -2.0759]
          , [2.37521, -2.0209, -2.2929]
          , [2.52238, -1.90933, -2.46184]
          , [2.69586, -1.76216, -2.5662]
          , [2.87868, -1.59378, -2.59575]
          , [3.05294, -1.42068, -2.5476]
          , [3.20158, -1.2598, -2.42647]
          , [3.31005, -1.12689, -2.24422]
          , [3.36773, -1.03497, -2.01867]
          , [3.36898, -0.993022, -1.77192]
          , [3.31368, -1.00516, -1.52811]
          , [3.20723, -1.0702, -1.31112]
          , [3.06007, -1.18176, -1.14217]
          , [2.88658, -1.32894, -1.03782]
          , [2.70376, -1.49732, -1.00827]
          ]
        , [ [-0.202443, 1.21224, -1.5326]
          , [-0.351082, 1.05136, -1.65373]
          , [-0.459553, 0.918454, -1.83598]
          , [-0.517237, 0.826529, -2.06153]
          , [-0.518489, 0.784582, -2.30828]
          , [-0.463185, 0.796721, -2.55209]
          , [-0.356739, 0.861756, -2.76908]
          , [-0.209571, 0.973322, -2.93803]
          , [-0.0360863, 1.1205, -3.04238]
          , [0.146733, 1.28888, -3.07193]
          , [0.32099, 1.46198, -3.02379]
          , [0.46963, 1.62286, -2.90266]
          , [0.5781, 1.75576, -2.7204]
          , [0.635785, 1.84769, -2.49486]
          , [0.637036, 1.88963, -2.2481]
          , [0.581732, 1.8775, -2.0043]
          , [0.475286, 1.81246, -1.7873]
          , [0.328118, 1.70089, -1.61836]
          , [0.154634, 1.55372, -1.514]
          , [-0.0281853, 1.38534, -1.48445]
          ]
        , [ [2.62765, -1.62359, -1.33601]
          , [2.53475, -1.72414, -1.41172]
          , [2.46696, -1.80721, -1.52563]
          , [2.4309, -1.86466, -1.66659]
          , [2.43012, -1.89088, -1.82081]
          , [2.46469, -1.88329, -1.97319]
          , [2.53121, -1.84264, -2.10882]
          , [2.62319, -1.77291, -2.21441]
          , [2.73162, -1.68093, -2.27963]
          , [2.84588, -1.57569, -2.2981]
          , [2.95479, -1.4675, -2.26801]
          , [3.04769, -1.36696, -2.1923]
          , [3.11549, -1.28389, -2.07839]
          , [3.15154, -1.22644, -1.93742]
          , [3.15232, -1.20022, -1.7832]
          , [3.11776, -1.20781, -1.63082]
          , [3.05123, -1.24845, -1.4952]
          , [2.95925, -1.31818, -1.38961]
          , [2.85082, -1.41017, -1.32439]
          , [2.73656, -1.5154, -1.30592]
          ]
        , [ [-0.104299, 1.25906, -1.81219]
          , [-0.197199, 1.15852, -1.8879]
          , [-0.264993, 1.07545, -2.00181]
          , [-0.301046, 1.018, -2.14278]
          , [-0.301828, 0.991779, -2.297]
          , [-0.267263, 0.999366, -2.44938]
          , [-0.200734, 1.04001, -2.585]
          , [-0.108754, 1.10974, -2.69059]
          , [-0.000326299, 1.20173, -2.75581]
          , [0.113936, 1.30696, -2.77428]
          , [0.222847, 1.41515, -2.74419]
          , [0.315746, 1.5157, -2.66848]
          , [0.38354, 1.59877, -2.55457]
          , [0.419593, 1.65622, -2.41361]
          , [0.420375, 1.68244, -2.25939]
          , [0.38581, 1.67485, -2.10701]
          , [0.319281, 1.6342, -1.97138]
          , [0.227301, 1.56447, -1.86579]
          , [0.118874, 1.47249, -1.80057]
          , [0.00461182, 1.36725, -1.7821]
          ]
    ];
    //echo(len=len(ptgroups), ptgroups = arrprn(ptgroups,dep=3) );  

    pts = concat( ptgroups[0]
                , ptgroups[1]
                , ptgroups[2]
                , ptgroups[3]);
    
    color( color, 1)
    polyhedron( points = pts
              , faces=faces("tube",nside= len(ptgroups[0])) );
}

//tube_faces();

module chain_faces(color){ 
    
   header(parent_module(1),color);
 
   // slice_pts: 
   
    slpts = [ [ [-2.6513, 1.65721, 1.11746]
  , [-2.64199, 2.34868, 1.06966]
  , [-2.33418, 2.30173, 0.450336]
  , [-2.34349, 1.61026, 0.498133]
  ]
, [ [-0.667631, 1.69843, 2.1002]
  , [-0.850301, 2.38591, 1.9573]
  , [-0.804771, 2.33351, 1.20804]
  , [-0.622101, 1.64603, 1.35095]
  ]
, [ [1.16845, 2.71612, 1.25665]
  , [0.871355, 3.34019, 1.16631]
  , [0.511409, 3.06304, 0.603344]
  , [0.808503, 2.43897, 0.693682]
  ]
, [ [1.69493, 2.76762, 0.578666]
  , [1.66078, 3.41741, 0.149718]
  , [1.21488, 3.13185, -0.302555]
  , [1.24903, 2.48207, 0.126393]
  ]
, [ [2.02477, 2.48809, 0.494697]
  , [2.26931, 2.90169, -0.00519821]
  , [2.09034, 2.38992, -0.525424]
  , [1.8458, 1.97632, -0.0255294]
  ]
, [ [3.53821, 2.2697, 1.10687]
  , [3.7974, 2.68119, 0.612901]
  , [3.88484, 2.13098, 0.20044]
  , [3.62565, 1.71949, 0.694411]
  ]
];

    nseg= len(slpts)-1;
    nside= len(slpts[0]);
    
    pts = joinarr(slpts);
    //echo(ptslen=len(pts), pts = arrprn(pts,dep=3) );                    

    faces = faces("chain",nside=nside,nseg=nseg);
    //echo(faces = faces);
    //echo( faceslen=len(faces), faces= arrprn(faces,dep=3));
    color( color, 1)
    polyhedron( points = pts
              , faces=faces );
}

//chain_faces();

module ring_faces(color){ 
    
    header(parent_module(1),color);

pts=[ [ [-5.67712, -0.0981671, -6.21628]
  , [-5.31215, 0.76187, -4.44791]
  , [-4.64341, -0.983785, -3.73694]
  , [-5.00839, -1.84382, -5.50531]
  ]
, [ [-8.35792, -1.67811, -4.8946]
  , [-7.99295, -0.818073, -3.12623]
  , [-6.43061, -2.03708, -2.85582]
  , [-6.79559, -2.89712, -4.62419]
  ]
, [ [-9.55063, -4.41913, -3.31535]
  , [-9.18566, -3.55909, -1.54698]
  , [-7.22575, -3.86443, -1.80299]
  , [-7.59072, -4.72446, -3.57136]
  ]
, [ [-8.87656, -7.45098, -1.97995]
  , [-8.51159, -6.59094, -0.211583]
  , [-6.77637, -5.88566, -0.912722]
  , [-7.14135, -6.7457, -2.68109]
  ]
, [ [-6.54974, -9.81106, -1.31237]
  , [-6.18477, -8.95102, 0.455998]
  , [-5.22516, -7.45904, -0.467668]
  , [-5.59013, -8.31908, -2.23604]
  ]
, [ [-3.30891, -10.7501, -1.52456]
  , [-2.94394, -9.89002, 0.243807]
  , [-3.0646, -8.08505, -0.609129]
  , [-3.42958, -8.94508, -2.3775]
  ]
, [ [-0.18301, -9.96986, -2.54916]
  , [0.181961, -9.10983, -0.780787]
  , [-0.980672, -7.56492, -1.29219]
  , [-1.34564, -8.42495, -3.06056]
  ]
, [ [1.83551, -7.71817, -4.06085]
  , [2.20048, -6.85814, -2.29248]
  , [0.365006, -6.06379, -2.29999]
  , [3.40909e-05, -6.92383, -4.06836]
  ]
, [ [2.10577, -4.70988, -5.5797]
  , [2.47075, -3.84985, -3.81133]
  , [0.545184, -4.05826, -3.31255]
  , [0.180213, -4.9183, -5.08092]
  ]
, [ [0.541986, -1.90011, -6.62347]
  , [0.906957, -1.04007, -4.8551]
  , [-0.497341, -2.18508, -4.0084]
  , [-0.862313, -3.04511, -5.77677]
  ]
, [ [-2.35937, -0.180924, -6.86078]
  , [-1.9944, 0.679113, -5.09241]
  , [-2.43158, -1.03896, -4.16661]
  , [-2.79655, -1.89899, -5.93498]
  ]
];    

     nseg = len(pts)-1;
     nside = len(pts[0]);
     //echo( nseg=nseg, nside=nside );
     //echo( len=len(pts), pts = arrprn(pts,dep=3) );   
     faces = faces("ring", nside=4, nseg=10);
     
     //echo( lenfaces=len(faces)
     //    , faces = faces );
  
     color(color,1)   
     polyhedron( points= joinarr(pts), faces=faces);   
    
}

//ring_faces();

module showall(){
    echo("");
    cubesides_faces("olive");
    rod_faces1("olive");
    rod_faces2("red");
    tube_faces("green");
    chain_faces("darkcyan");
    ring_faces("darkslategray");
    echo("");
}    

showall();
